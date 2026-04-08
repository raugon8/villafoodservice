from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from backend.object_class.orders import (
    CartCreate,
    OrderCreate,
    OrderResponse,
    OrderListResponse,
    OrderStatusUpdate,
    OrderStaffResponse,
    ValidatedCartItemResponse,
    HistorialPedido,
    RepetirPedidoResponse,
    CancelOrderStaffRequest
)
from backend.services import order_service, order_staff_service
from backend.database_manager.database import get_db
from backend.middleware.auth_middleware import RequireRole

router = APIRouter(prefix="/pedidos", tags=["pedidos"])


# ============================================================================
# ENDPOINTS DE CLIENTE (sin order_id en la ruta)
# ============================================================================

@router.post("/validar-carrito", response_model=List[ValidatedCartItemResponse])
def validate_cart(
    cart: CartCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Comprueba la disponibilidad de los productos del carrito antes de confirmar el pedido."""
    RequireRole(["cliente", "admin"])
    return order_service.validate_cart(db, cart.items)


@router.post("/crear", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    order_data: OrderCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Crea un pedido y descuenta el stock de ingredientes."""
    RequireRole(["cliente", "admin"])
    return order_service.create_order(db, user_id, order_data)


@router.get("/", response_model=List[OrderListResponse])
def list_orders(
    # user_id es opcional: el cliente manda su ID y ve sus pedidos, el admin no lo manda y los ve todos.
    user_id: Optional[int] = Query(None),
    current_role: str = Query(...),
    status: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Lista pedidos con filtros opcionales de usuario y estado."""
    RequireRole(["cliente", "admin"])
    return order_service.list_orders(db, user_id, status, skip, limit)


@router.get("/historial", response_model=List[HistorialPedido])
def get_historial(
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Devuelve todos los pedidos anteriores del cliente autenticado, del más reciente al más antiguo."""
    RequireRole(["cliente"])
    return order_service.obtener_historial(db, user_id)


@router.post("/repetir/{pedido_id}", response_model=RepetirPedidoResponse)
def repetir_pedido(
    pedido_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Comprueba si los productos de un pedido anterior siguen disponibles para volver a añadirlos al carrito."""
    RequireRole(["cliente"])
    return order_service.repetir_pedido(db, pedido_id, user_id)


# ============================================================================
# ENDPOINTS DE STAFF — deben definirse antes que /{order_id}.
# Si estuvieran después, FastAPI interpretaría "staff" como un order_id entero y fallaría.
# ============================================================================

@router.get("/staff", response_model=List[OrderStaffResponse])
def list_staff_orders(
    service: str = Query(..., description="Servicio: cafeteria, restaurante, reposteria"),
    user_id: int = Query(...),
    current_role: str = Query(...),
    status: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Lista los pedidos del servicio asignado al dependiente."""
    RequireRole(["dependiente", "admin"])
    return order_staff_service.listar_pedidos_staff(db, service, status, search, skip, limit)


@router.get("/staff/{order_id}", response_model=OrderStaffResponse)
def get_staff_order_detail(
    order_id: int,
    service: str = Query(..., description="Servicio del dependiente"),
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Obtiene el detalle completo de un pedido para el dependiente."""
    RequireRole(["dependiente", "admin"])
    return order_staff_service.obtener_pedido_staff_detalle(db, order_id, service)


@router.patch("/staff/{order_id}/estado", response_model=OrderStaffResponse)
def update_staff_order_status(
    order_id: int,
    status_data: OrderStatusUpdate,
    service: str = Query(..., description="Servicio del dependiente"),
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Actualiza el estado de un pedido con las transiciones permitidas para el dependiente."""
    RequireRole(["dependiente", "admin"])
    return order_staff_service.actualizar_estado_pedido_staff(
        db, order_id, status_data.order_status, service
    )


@router.post("/staff/{order_id}/cancelar", response_model=OrderStaffResponse)
def cancel_staff_order(
    order_id: int,
    cancel_data: CancelOrderStaffRequest,
    service: str = Query(..., description="Servicio del dependiente"),
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Cancela un pedido desde el lado del dependiente.
    Solo se pueden cancelar pedidos en estado pendiente o en_preparacion.
    Restaura el stock de ingredientes y guarda la nota de cancelación opcional."""
    RequireRole(["dependiente", "admin"])
    return order_staff_service.cancelar_pedido_staff(
        db, order_id, service, cancel_data.cancel_reason
    )


# ============================================================================
# ENDPOINTS DE CLIENTE con {order_id} — Al final para evitar conflictos de ruta de endpoint.
# ============================================================================

@router.get("/{order_id}", response_model=OrderResponse)
def get_order_by_id(
    order_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Obtiene el detalle completo de un pedido específico."""
    RequireRole(["cliente", "admin"])
    return order_service.get_order_by_id(db, order_id)


@router.patch("/{order_id}/estado", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    status_data: OrderStatusUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Cambia el estado de un pedido respetando las transiciones válidas."""
    RequireRole(["cliente", "admin"])
    return order_service.update_order_status(db, order_id, status_data.order_status)


@router.delete("/{order_id}/cancelar", response_model=OrderResponse)
def cancel_order(
    order_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Cancela un pedido y restaura el stock de ingredientes."""
    RequireRole(["cliente", "admin"])
    return order_service.cancel_order(db, order_id, user_id)