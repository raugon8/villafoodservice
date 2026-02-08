from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from database_manager.database import get_db
from object_class.orders import (
    OrderCreate, OrderResponse, OrderListResponse,
    OrderStatusUpdate, CartDetailBase, OrderStaffResponse
)
from services import order_service, order_staff_service # Adan's new service

router = APIRouter(prefix="/pedidos", tags=["pedidos"])

# --- CLIENT ENDPOINTS ---

@router.post("/validar-carrito")
def ValidateCart(items: List[CartDetailBase], db: Session = Depends(get_db)):
    return order_service.validate_cart(db, items)

@router.post("/crear", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def CreateOrder(order_data: OrderCreate, user_id: int, db: Session = Depends(get_db)):
    return order_service.create_order(db, user_id, order_data)

# --- STAFF ENDPOINTS (NEW TASK 6) ---

@router.get("/staff", response_model=List[OrderStaffResponse])
def GetStaffOrders(
    service: str,
    status: Optional[str] = None,
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """List orders filtered by service for dependants """
    return order_staff_service.listar_pedidos_staff(db, service, status, search, skip, limit)

@router.get("/staff/{order_id}", response_model=OrderStaffResponse)
def GetStaffOrderDetail(order_id: int, service: str, db: Session = Depends(get_db)):
    """Get full order detail for staff """
    return order_staff_service.obtener_pedido_staff_detalle(db, order_id, service)

@router.patch("/staff/{order_id}/estado", response_model=OrderStaffResponse)
def UpdateStaffOrderStatus(
    order_id: int,
    status_data: OrderStatusUpdate,
    service: str,
    db: Session = Depends(get_db)
):
    """Update order status validating allowed transitions """
    try:
        return order_staff_service.actualizar_estado_pedido_staff(db, order_id, status_data.order_status, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- COMMON ENDPOINTS ---

@router.get("/{order_id}", response_model=OrderResponse)
def GetOrderById(order_id: int, db: Session = Depends(get_db)):
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
    return order_service.list_orders(db, user_id, status, skip, limit)