"""
Order Staff Service
Business logic for staff/dependiente order management
backend/services/order_staff_service.py
"""
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

from backend.models.pedido_model import OrderModel, OrderDetailModel
from backend.models.producto_model import Producto
from backend.models.user_model import User
from backend.object_class.orders import VALID_STAFF_TRANSITIONS


# ============================================================================
# FUNCTION 1: List orders for staff
# ============================================================================

def listar_pedidos_staff(
    db: Session,
    service: str,
    status: Optional[str] = None,
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 20
) -> List[dict]:

    query = db.query(OrderModel).filter(OrderModel.order_service == service)

    if status:
        query = query.filter(OrderModel.order_status == status)

    if search:
        # search by order_id or client name
        try:
            order_id = int(search)
            query = query.filter(OrderModel.order_id == order_id)
        except ValueError:
            matching_users = db.query(User).filter(
                User.nombre_usuario.ilike(f"%{search}%")
            ).all()
            user_ids = [u.usuario_ID for u in matching_users]
            query = query.filter(OrderModel.user_id.in_(user_ids))

    # Order by status priority then date (oldest first within each status)
    status_order = {"pendiente": 0, "en_preparacion": 1, "listo": 2}
    orders = query.order_by(OrderModel.order_date_time.asc()).all()
    orders.sort(key=lambda o: (status_order.get(o.order_status, 99), o.order_date_time))

    # Apply pagination after sorting
    orders = orders[skip: skip + limit]

    result = []
    for order in orders:
        user = db.query(User).filter(User.usuario_ID == order.user_id).first()
        items_count = db.query(OrderDetailModel).filter(
            OrderDetailModel.order_id == order.order_id
        ).count()

        result.append({
            "order_id":         order.order_id,
            "user_id":          order.user_id,
            "user_name":        user.nombre_usuario if user else "Unknown",
            "order_date_time":  order.order_date_time,
            "order_status":     order.order_status,
            "order_total":      order.order_total,
            "order_notes":      order.order_notes,
            "order_service":    order.order_service,
            "order_pickup_time": order.order_pickup_time,
            "is_new":           not order.order_staff_seen,
            "items_count":      items_count,
            "details":          []
        })

    # Mark all returned orders as seen
    for order in orders:
        order.order_staff_seen = True
    db.commit()

    return result


# ============================================================================
# FUNCTION 2: Get staff order detail
# ============================================================================

def obtener_pedido_staff_detalle(db: Session, order_id: int, service: str) -> dict:
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Order {order_id} not found")

    if order.order_service != service:
        raise HTTPException(status_code=403, detail="This order does not belong to your service")

    user = db.query(User).filter(User.usuario_ID == order.user_id).first()
    details = db.query(OrderDetailModel).filter(
        OrderDetailModel.order_id == order_id
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

    # Mark as seen
    order.order_staff_seen = True
    db.commit()

    items_count = len(details_list)

    return {
        "order_id":          order.order_id,
        "user_id":           order.user_id,
        "user_name":         user.nombre_usuario if user else "Unknown",
        "order_date_time":   order.order_date_time,
        "order_status":      order.order_status,
        "order_total":       order.order_total,
        "order_notes":       order.order_notes,
        "order_service":     order.order_service,
        "order_pickup_time": order.order_pickup_time,
        "is_new":            False,
        "items_count":       items_count,
        "details":           details_list
    }


# ============================================================================
# FUNCTION 3: Update order status (staff)
# ============================================================================

def actualizar_estado_pedido_staff(
    db: Session,
    order_id: int,
    nuevo_estado: str,
    service: str
) -> dict:
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail=f"Order {order_id} not found")

    if order.order_service != service:
        raise HTTPException(status_code=403, detail="This order does not belong to your service")

    current_status = order.order_status
    allowed = VALID_STAFF_TRANSITIONS.get(current_status, [])

    if nuevo_estado not in allowed:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Cannot transition from '{current_status}' to '{nuevo_estado}'. "
                f"Allowed: {allowed}"
            )
        )

    order.order_status = nuevo_estado
    db.commit()
    db.refresh(order)

    return obtener_pedido_staff_detalle(db, order_id, service)