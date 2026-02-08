from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from database_manager.database import get_db
from object_class.orders import (
    OrderCreate, OrderResponse, OrderListResponse, OrderStatusUpdate, CartDetailBase
)
# We will import Adan's services once he creates them
from services import order_service

router = APIRouter(prefix="/pedidos", tags=["pedidos"])

@router.post("/validar-carrito")
def ValidateCart(items: List[CartDetailBase], db: Session = Depends(get_db)):
    """Checks if products in cart are available"""
    return order_service.validate_cart(db, items)

@router.post("/crear", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def CreateOrder(order_data: OrderCreate, user_id: int, db: Session = Depends(get_db)):
    """Creates a new order and updates stock"""
    return order_service.create_order(db, user_id, order_data)

@router.get("/{order_id}", response_model=OrderResponse)
def GetOrderById(order_id: int, db: Session = Depends(get_db)):
    """Gets all details of a specific order"""
    order = order_service.get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return order

@router.get("/", response_model=List[OrderListResponse])
def ListOrders(
    user_id: Optional[int] = None,
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Lists orders with optional filters"""
    return order_service.list_orders(db, user_id, status, skip, limit)

@router.patch("/{order_id}/estado", response_model=OrderResponse)
def UpdateOrderStatus(order_id: int, status_data: OrderStatusUpdate, db: Session = Depends(get_db)):
    """Changes order status (e.g., from pending to ready)"""
    return order_service.update_order_status(db, order_id, status_data.order_status)

@router.delete("/{order_id}/cancelar")
def CancelOrder(order_id: int, user_id: int, db: Session = Depends(get_db)):
    """Cancels an order and restores stock"""
    return order_service.cancel_order(db, order_id, user_id)