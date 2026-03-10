"""
Orders - Pydantic schemas
backend/object_class/orders.py
"""
from pydantic import BaseModel, Field, validator
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

# Valid order states
VALID_STATES = ['pendiente', 'en_preparacion', 'listo', 'entregado', 'cancelado']

# Valid states for staff (cannot cancel or mark as delivered)
VALID_STAFF_STATES = ['pendiente', 'en_preparacion', 'listo']

# Allowed state transitions
VALID_TRANSITIONS = {
    'pendiente':      ['en_preparacion', 'cancelado'],
    'en_preparacion': ['listo'],
    'listo':          ['entregado'],
    'entregado':      [],
    'cancelado':      []
}

# Staff-only transitions (más restringido, pero el dependiente puede marcar como entregado desde el escáner QR)
VALID_STAFF_TRANSITIONS = {
    'pendiente':      ['en_preparacion'],
    'en_preparacion': ['listo'],
    'listo':          ['entregado'],
}

# ============================================================================
# PYDANTIC SCHEMAS - Input
# ============================================================================

class CartDetailBase(BaseModel):
    """Schema for a single product in the cart"""
    product_id: int = Field(..., gt=0)
    quantity: int = Field(..., gt=0, le=50, description="Between 1 and 50 units")

class CartCreate(BaseModel):
    """Schema to validate a full cart"""
    items: List[CartDetailBase]

    @validator('items')
    def validate_items(cls, v):
        if not v:
            raise ValueError("Cart cannot be empty")
        return v

class OrderCreate(BaseModel):
    """Schema to create a new order"""
    items: List[CartDetailBase]
    order_notes: Optional[str] = None
    order_pickup_time: Optional[datetime] = None  # Task 6

    @validator('items')
    def validate_items(cls, v):
        if not v:
            raise ValueError("Order must have at least one product")
        return v

class OrderStatusUpdate(BaseModel):
    """Schema to update order status"""
    order_status: str

    @validator('order_status')
    def validate_status(cls, v):
        if v not in VALID_STATES:
            raise ValueError(f"Invalid status. Must be one of: {VALID_STATES}")
        return v

# ============================================================================
# PYDANTIC SCHEMAS - Output
# ============================================================================

class ValidatedCartItemResponse(BaseModel):
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
    detail_id: int
    product_id: int
    product_name: Optional[str] = None
    detail_quantity: int
    detail_unit_price: Decimal
    detail_subtotal: Decimal

    class Config:
        from_attributes = True

class OrderResponse(BaseModel):
    order_id: int
    user_id: int
    user_name: Optional[str] = None
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    order_notes: Optional[str] = None
    order_service: Optional[str] = None
    order_pickup_time: Optional[datetime] = None
    details: List[OrderDetailResponse] = []

    class Config:
        from_attributes = True

class OrderListResponse(BaseModel):
    order_id: int
    user_id: int
    user_name: Optional[str] = None
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    items_count: int

    class Config:
        from_attributes = True

class OrderStaffResponse(BaseModel):
    """Order response for staff/dependiente view"""
    order_id: int
    user_id: int
    user_name: str
    order_date_time: datetime
    order_status: str
    order_total: Decimal
    order_notes: Optional[str] = None
    order_service: Optional[str] = None
    order_pickup_time: Optional[datetime] = None
    is_new: bool
    items_count: int
    details: List[OrderDetailResponse] = []

    class Config:
        from_attributes = True