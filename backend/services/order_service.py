"""
Order Service
Business logic for cart validation and order management
backend/services/order_service.py
"""
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


# ============================================================================
# FUNCTION 1: Validate cart
# ============================================================================

def validate_cart(db: Session, items: list) -> List[dict]:
    result = []
    errors = []

    for item in items:
        product = db.query(Producto).filter(
            Producto.producto_id == item.product_id,
            Producto.producto_activo == True
        ).first()

        if not product:
            errors.append(f"Product ID {item.product_id} not found or unavailable")
            continue

        stock_available = calcular_unidades_disponibles(db, item.product_id)
        available = stock_available >= item.quantity

        if not available:
            errors.append(
                f"'{product.producto_nombre}': requested {item.quantity}, "
                f"available {stock_available}"
            )

        price = Decimal(str(product.producto_precioUnitario))
        subtotal = price * item.quantity

        result.append({
            "product_id":      product.producto_id,
            "product_name":    product.producto_nombre,
            "product_price":   price,
            "quantity":        item.quantity,
            "subtotal":        subtotal,
            "available":       available,
            "stock_available": stock_available
        })

    if errors:
        raise HTTPException(
            status_code=400,
            detail={"message": "Some products are not available", "errors": errors}
        )

    return result


# ============================================================================
# FUNCTION 2: Create order
# ============================================================================

def create_order(db: Session, user_id: int, order_data) -> dict:
    try:
        user = db.query(User).filter(User.usuario_ID == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        validated_items = validate_cart(db, order_data.items)
        total = sum(item["subtotal"] for item in validated_items)

        new_order = OrderModel(
            user_id=user_id,
            order_status="pendiente",
            order_total=total,
            order_notes=order_data.order_notes
        )
        db.add(new_order)
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
        raise HTTPException(status_code=500, detail=f"Error creating order: {str(e)}")


# ============================================================================
# FUNCTION 3: Get order by ID
# ============================================================================

def get_order_by_id(db: Session, order_id: int) -> dict:
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Order {order_id} not found")

    return _build_order_response(db, order)


# ============================================================================
# FUNCTION 4: List orders
# ============================================================================

def list_orders(
    db: Session,
    user_id: Optional[int] = None,
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 20
) -> List[dict]:
    if status and status not in VALID_STATES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {VALID_STATES}"
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
            "user_name":       user.nombre_usuario if user else "Unknown",
            "order_date_time": order.order_date_time,
            "order_status":    order.order_status,
            "order_total":     order.order_total,
            "items_count":     items_count
        })

    return result


# ============================================================================
# FUNCTION 5: Update order status
# ============================================================================

def update_order_status(db: Session, order_id: int, new_status: str) -> dict:
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Order {order_id} not found")

    current_status = order.order_status
    allowed_transitions = VALID_TRANSITIONS.get(current_status, [])

    if new_status not in allowed_transitions:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Cannot transition from '{current_status}' to '{new_status}'. "
                f"Allowed from '{current_status}': {allowed_transitions}"
            )
        )

    order.order_status = new_status
    db.commit()
    db.refresh(order)

    return _build_order_response(db, order)


# ============================================================================
# FUNCTION 6: Cancel order
# ============================================================================

def cancel_order(db: Session, order_id: int, user_id: int) -> dict:
    try:
        order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

        if not order:
            raise HTTPException(status_code=404, detail=f"Order {order_id} not found")

        if order.user_id != user_id:
            raise HTTPException(status_code=403, detail="You do not have permission to cancel this order")

        if order.order_status != "pendiente":
            raise HTTPException(
                status_code=400,
                detail=f"Only 'pendiente' orders can be cancelled. Current status: '{order.order_status}'"
            )

        details = db.query(OrderDetailModel).filter(
            OrderDetailModel.order_id == order_id
        ).all()

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
        raise HTTPException(status_code=500, detail=f"Error cancelling order: {str(e)}")


# ============================================================================
# PRIVATE HELPER FUNCTIONS
# ============================================================================

def _deduct_ingredient_stock(db: Session, product_id: int, quantity_ordered: int) -> None:
    """Deducts ingredient stock when an order is confirmed."""
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
                    detail=f"Insufficient stock for ingredient '{ingredient.ingrediente_nombre}'"
                )


def _restore_ingredient_stock(db: Session, product_id: int, quantity_ordered: int) -> None:
    """Restores ingredient stock when an order is cancelled."""
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
    """Builds the full response dict for an order including its details."""
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