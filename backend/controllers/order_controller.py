"""
Order Controller
REST endpoints for cart and order management
backend/controllers/order_controller.py
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from backend.object_class.orders import (
    CartCreate,
    OrderCreate,
    OrderResponse,
    OrderListResponse,
    OrderStatusUpdate,
    ValidatedCartItemResponse
)
from backend.services import order_service
from backend.database_manager.database import get_db

router = APIRouter(prefix="/pedidos", tags=["pedidos"])


@router.post("/validar-carrito", response_model=List[ValidatedCartItemResponse])
def validate_cart(cart: CartCreate, db: Session = Depends(get_db)):
    """Checks if products in cart are available"""
    return order_service.validate_cart(db, cart.items)


@router.post("/crear", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    order_data: OrderCreate,
    user_id: int = Query(..., description="ID of the user placing the order"),
    db: Session = Depends(get_db)
):
    """Creates a new order and updates ingredient stock"""
    return order_service.create_order(db, user_id, order_data)


@router.get("/{order_id}", response_model=OrderResponse)
def get_order_by_id(order_id: int, db: Session = Depends(get_db)):
    """Gets all details of a specific order"""
    return order_service.get_order_by_id(db, order_id)


@router.get("/", response_model=List[OrderListResponse])
def list_orders(
    user_id: Optional[int] = Query(None),
    status: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Lists orders with optional filters"""
    return order_service.list_orders(db, user_id, status, skip, limit)


@router.patch("/{order_id}/estado", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    status_data: OrderStatusUpdate,
    db: Session = Depends(get_db)
):
    """Changes order status (e.g., from pending to in preparation)"""
    return order_service.update_order_status(db, order_id, status_data.order_status)


@router.delete("/{order_id}/cancelar", response_model=OrderResponse)
def cancel_order(
    order_id: int,
    user_id: int = Query(..., description="ID of the user who owns the order"),
    db: Session = Depends(get_db)
):
    """Cancels an order and restores ingredient stock"""
    return order_service.cancel_order(db, order_id, user_id)