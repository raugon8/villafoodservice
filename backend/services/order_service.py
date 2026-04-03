# Lógica de negocio para la validación del carrito y la gestión de pedidos.

from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

from backend.models.pedido_model import OrderModel, OrderDetailModel
from backend.models.producto_model import Producto, ProductoIngrediente
from backend.models.ingredient_model import Ingrediente
from backend.models.user_model import User
from backend.services.disponibilidad_service import calcular_unidades_disponibles
from backend.object_class.orders import VALID_TRANSITIONS, VALID_STATES

# Se usa al crear un pedido para asignar order_service automáticamente.
SERVICE_MAP = {
    'Cafetería': 'cafeteria',
    'Restaurante': 'restaurante',
    'Repostería': 'reposteria'
}


def validate_cart(db: Session, items: list) -> List[dict]:
    """Comprueba la disponibilidad de todos los productos del carrito.
    Acumula todos los errores antes de lanzar la excepción, para informar al cliente de todos los problemas a la vez.
    No modifica el stock."""
    result = []
    errors = []

    for item in items:
        product = db.query(Producto).filter(
            Producto.producto_id == item.product_id,
            Producto.producto_activo == True
        ).first()

        if not product:
            errors.append(f"Producto ID {item.product_id} no encontrado o no disponible")
            continue

        stock_available = calcular_unidades_disponibles(db, item.product_id)
        available = stock_available >= item.quantity

        if not available:
            errors.append(
                f"'{product.producto_nombre}': solicitadas {item.quantity}, "
                f"disponibles {stock_available}"
            )

        price = Decimal(str(product.producto_precioUnitario))
        subtotal = price * item.quantity

        result.append({
            "product_id":        product.producto_id,
            "product_name":      product.producto_nombre,
            "product_price":     price,
            "quantity":          item.quantity,
            "subtotal":          subtotal,
            "available":         available,
            "stock_available":   stock_available,
            "product_categoria": product.producto_categoria
        })

    if errors:
        raise HTTPException(
            status_code=400,
            detail={"message": "Algunos productos no están disponibles", "errors": errors}
        )

    return result


def create_order(db: Session, user_id: int, order_data) -> dict:
    """Crea un pedido: Valida el carrito, descuenta stock de ingredientes y guarda en BD.
    Usa rollback si cualquier paso falla."""
    try:
        user = db.query(User).filter(User.usuario_ID == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")

        validated_items = validate_cart(db, order_data.items)
        total = sum(item["subtotal"] for item in validated_items)

        # El servicio se deriva de la categoría del primer producto del carrito.
        first_categoria = validated_items[0]["product_categoria"] if validated_items else None
        derived_service = SERVICE_MAP.get(first_categoria, 'restaurante')

        new_order = OrderModel(
            user_id=user_id,
            order_status="pendiente",
            order_total=total,
            order_notes=order_data.order_notes,
            order_service=derived_service
        )
        db.add(new_order)
        # flush() genera el order_id sin confirmar la transacción; necesario para usarlo en los OrderDetailModel de las siguientes líneas.
        db.flush()

        for item in validated_items:
            detail = OrderDetailModel(
                order_id=new_order.order_id,
                product_id=item["product_id"],
                detail_quantity=item["quantity"],
                detail_unit_price=item["product_price"],
                detail_subtotal=item["subtotal"]
            )
            db.add(detail)
            _deduct_ingredient_stock(db, item["product_id"], item["quantity"])

        db.commit()
        db.refresh(new_order)

        return _build_order_response(db, new_order)

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al crear el pedido: {str(e)}")


def get_order_by_id(db: Session, order_id: int) -> dict:
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Pedido {order_id} no encontrado")

    return _build_order_response(db, order)


def list_orders(
    db: Session,
    user_id: Optional[int] = None,
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 20
) -> List[dict]:
    """Lista pedidos con filtros opcionales.
    Si user_id es None devuelve todos los pedidos (uso del admin)."""
    if status and status not in VALID_STATES:
        raise HTTPException(
            status_code=400,
            detail=f"Estado no válido. Debe ser uno de: {VALID_STATES}"
        )

    query = db.query(OrderModel)

    if user_id is not None:
        query = query.filter(OrderModel.user_id == user_id)
    if status is not None:
        query = query.filter(OrderModel.order_status == status)

    orders = query.order_by(OrderModel.order_date_time.desc()).offset(skip).limit(limit).all()

    result = []
    for order in orders:
        user = db.query(User).filter(User.usuario_ID == order.user_id).first()
        items_count = db.query(OrderDetailModel).filter(
            OrderDetailModel.order_id == order.order_id
        ).count()

        result.append({
            "order_id":        order.order_id,
            "user_id":         order.user_id,
            "user_name":       user.nombre_usuario if user else "Desconocido",
            "order_date_time": order.order_date_time,
            "order_status":    order.order_status,
            "order_total":     order.order_total,
            "items_count":     items_count
        })

    return result


def update_order_status(db: Session, order_id: int, new_status: str) -> dict:
    """Actualiza el estado de un pedido respetando las transiciones válidas definidas en VALID_TRANSITIONS."""
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Pedido {order_id} no encontrado")

    current_status = order.order_status
    allowed_transitions = VALID_TRANSITIONS.get(current_status, [])

    if new_status not in allowed_transitions:
        raise HTTPException(
            status_code=400,
            detail=(
                f"No se puede pasar de '{current_status}' a '{new_status}'. "
                f"Transiciones permitidas desde '{current_status}': {allowed_transitions}"
            )
        )

    order.order_status = new_status
    db.commit()
    db.refresh(order)

    return _build_order_response(db, order)


def cancel_order(db: Session, order_id: int, user_id: int) -> dict:
    """Cancela un pedido y restaura el stock de ingredientes.
    Solo el cliente puede cancelar mientras el pedido está en estado pendiente.
    Usa rollback si cualquier paso falla."""
    try:
        order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

        if not order:
            raise HTTPException(status_code=404, detail=f"Pedido {order_id} no encontrado")

        if order.user_id != user_id:
            raise HTTPException(status_code=403, detail="No tienes permiso para cancelar este pedido")

        if order.order_status != "pendiente":
            raise HTTPException(
                status_code=400,
                detail=f"Solo se pueden cancelar pedidos en estado 'pendiente'. Estado actual: '{order.order_status}'"
            )

        details = db.query(OrderDetailModel).filter(
            OrderDetailModel.order_id == order_id
        ).all()

        # Restaurar el stock de cada ingrediente antes de marcar como cancelado.
        for detail in details:
            _restore_ingredient_stock(db, detail.product_id, detail.detail_quantity)

        order.order_status = "cancelado"
        db.commit()
        db.refresh(order)

        return _build_order_response(db, order)

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al cancelar el pedido: {str(e)}")


def _deduct_ingredient_stock(db: Session, product_id: int, quantity_ordered: int) -> None:
    """Descuenta el stock de ingredientes al confirmar un pedido."""
    relations = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == product_id
    ).all()

    for relation in relations:
        ingredient = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_id == relation.productoIngrediente_ingredienteId
        ).first()

        if ingredient:
            amount_to_deduct = Decimal(str(relation.productoIngrediente_cantidad)) * quantity_ordered
            ingredient.ingrediente_stockActual -= amount_to_deduct

            if ingredient.ingrediente_stockActual < 0:
                raise HTTPException(
                    status_code=400,
                    detail=f"Stock insuficiente para el ingrediente '{ingredient.ingrediente_nombre}'"
                )


def _restore_ingredient_stock(db: Session, product_id: int, quantity_ordered: int) -> None:
    """Restaura el stock de ingredientes al cancelar un pedido."""
    relations = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == product_id
    ).all()

    for relation in relations:
        ingredient = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_id == relation.productoIngrediente_ingredienteId
        ).first()

        if ingredient:
            amount_to_restore = Decimal(str(relation.productoIngrediente_cantidad)) * quantity_ordered
            ingredient.ingrediente_stockActual += amount_to_restore


def _build_order_response(db: Session, order: OrderModel) -> dict:
    """Construye el listado de respuesta completo de un pedido con sus líneas de detalle."""
    details = db.query(OrderDetailModel).filter(
        OrderDetailModel.order_id == order.order_id
    ).all()

    details_list = []
    for d in details:
        product = db.query(Producto).filter(Producto.producto_id == d.product_id).first()
        details_list.append({
            "detail_id":         d.detail_id,
            "product_id":        d.product_id,
            "product_name":      product.producto_nombre if product else None,
            "detail_quantity":   d.detail_quantity,
            "detail_unit_price": d.detail_unit_price,
            "detail_subtotal":   d.detail_subtotal
        })

    return {
        "order_id":        order.order_id,
        "user_id":         order.user_id,
        "order_date_time": order.order_date_time,
        "order_status":    order.order_status,
        "order_total":     order.order_total,
        "order_notes":     order.order_notes,
        "details":         details_list
    }