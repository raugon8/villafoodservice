from pydantic import BaseModel, Field, validator
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

# Estados válidos para cualquier pedido.
VALID_STATES = ['pendiente', 'en_preparacion', 'listo', 'entregado', 'cancelado']

# Estados válidos para el dependiente; no puede cancelar ni marcar como entregado.
VALID_STAFF_STATES = ['pendiente', 'en_preparacion', 'listo']

# El cliente puede cancelar (pendiente → cancelado) y confirmar recepción (listo → entregado).
VALID_TRANSITIONS = {
    'pendiente':      ['en_preparacion', 'cancelado'],
    'en_preparacion': ['listo'],
    'listo':          ['entregado'],
    'entregado':      [],
    'cancelado':      []
}

# Transiciones de estado permitidas para el dependiente: pendiente → en_preparacion → listo. El dependiente también puede cancelar.
VALID_STAFF_TRANSITIONS = {
    'pendiente':      ['en_preparacion', 'cancelado'],
    'en_preparacion': ['listo', 'cancelado'],
    'listo':          ['entregado'],
}


# ============================================================================
# SCHEMAS DE ENTRADA
# ============================================================================

class CartDetailBase(BaseModel):
    """Un producto dentro del carrito con su cantidad."""
    product_id: int = Field(..., gt=0)
    quantity: int = Field(..., gt=0, le=50, description="Entre 1 y 50 unidades")


class CartCreate(BaseModel):
    """Carrito completo para validar disponibilidad antes de confirmar.
    No descuenta stock — solo comprueba si los productos están disponibles."""
    items: List[CartDetailBase]

    @validator('items')
    def validate_items(cls, v):
        if not v:
            raise ValueError("El carrito no puede estar vacío")
        return v


class OrderCreate(BaseModel):
    """Datos necesarios para crear un pedido. Al confirmarse, descuenta stock de ingredientes."""
    items: List[CartDetailBase]
    order_notes: Optional[str] = None
    order_pickup_time: Optional[datetime] = None

    @validator('items')
    def validate_items(cls, v):
        if not v:
            raise ValueError("El pedido debe tener al menos un producto")
        return v


class OrderStatusUpdate(BaseModel):
    """Schema para actualizar el estado de un pedido. Valida que el estado sea uno de los permitidos."""
    order_status: str

    @validator('order_status')
    def validate_status(cls, v):
        if v not in VALID_STATES:
            raise ValueError(f"Estado no válido. Debe ser uno de: {VALID_STATES}")
        return v


# ============================================================================
# SCHEMAS DE RESPUESTA
# ============================================================================

class ValidatedCartItemResponse(BaseModel):
    """Resultado de validar un producto del carrito. Incluye si está disponible y cuántas unidades hay."""
    product_id: int
    product_name: str
    product_price: Decimal
    quantity: int
    subtotal: Decimal
    available: bool
    stock_available: int

    class Config:
        from_attributes = True


class OrderDetailResponse(BaseModel):
    """Una línea de pedido: producto, cantidad y precios en el momento de la compra."""
    detail_id: int
    product_id: int
    product_name: Optional[str] = None
    detail_quantity: int
    detail_unit_price: Decimal
    detail_subtotal: Decimal

    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    """Respuesta completa de un pedido para el cliente, incluyendo sus líneas de detalle."""
    order_id: int
    user_id: int
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    order_notes: Optional[str] = None
    order_service: Optional[str] = None
    order_pickup_time: Optional[datetime] = None
    # Nota de cancelación escrita por el dependiente — visible para el cliente.
    cancel_reason: Optional[str] = None
    details: List[OrderDetailResponse] = []

    class Config:
        from_attributes = True


class OrderListResponse(BaseModel):
    """Respuesta resumida de un pedido para listados. No incluye el detalle de líneas."""
    order_id: int
    user_id: int
    # Opcional: el cliente no siempre necesita ver el nombre, el admin sí.
    user_name: Optional[str] = None
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    items_count: int

    class Config:
        from_attributes = True


class OrderStaffResponse(BaseModel):
    """Respuesta de pedido para el dependiente.
    Incluye is_new (si el dependiente aún no ha visto) y user_name obligatorio."""
    order_id: int
    user_id: int
    user_name: str
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    order_notes: Optional[str] = None
    order_service: Optional[str] = None
    order_pickup_time: Optional[datetime] = None
    # Nota de cancelación escrita por el dependiente — visible para el cliente.
    cancel_reason: Optional[str] = None
    is_new: bool
    items_count: int
    details: List[OrderDetailResponse] = []

    class Config:
        from_attributes = True


# --- NUEVOS SCHEMAS PARA TAREA 19 (Historial y Repetir Pedido) ---

class HistorialProducto(BaseModel):
    producto_id: int
    nombre: str
    cantidad: int
    precio_unitario: Decimal

class HistorialPedido(BaseModel):
    pedido_id: int
    fecha: datetime
    estado: str
    total: Decimal
    # Nota de cancelación escrita por el dependiente — visible para el cliente en su historial.
    cancel_reason: Optional[str] = None
    productos: List[HistorialProducto]

class ProductoDisponible(BaseModel):
    producto_id: int
    nombre: str
    cantidad: int
    precio_unitario: Decimal

class ProductoNoDisponible(BaseModel):
    producto_id: int
    nombre: str
    motivo: str

class RepetirPedidoResponse(BaseModel):
    productos_disponibles: List[ProductoDisponible]
    productos_no_disponibles: List[ProductoNoDisponible]

# Schema para la cancelación de un pedido por el dependiente — la nota es opcional.
class CancelOrderStaffRequest(BaseModel):
    cancel_reason: Optional[str] = None