from database_manager.database import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field, validator
from typing import List, Optional
from datetime import datetime


# --- DATABASE MODELS (SQLAlchemy) ---

class OrderModel(Base):
    """Table to store general order information"""
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("usuarios.usuario_id"), nullable=False)  # FK adjusted to your table
    order_date_time = Column(DateTime, default=datetime.now)
    # New Task 6 fields
    order_pickup_time = Column(DateTime, nullable=True)  #
    order_service = Column(String(20), nullable=True)  # cafeteria, restaurante, reposteria
    order_staff_seen = Column(Boolean, default=False)  # For new order indicator

    order_status = Column(String(20), default="pendiente")
    order_total = Column(Numeric(10, 2), nullable=False)
    order_notes = Column(String, nullable=True)

    # Relations
    details = relationship("OrderDetailModel", back_populates="order", cascade="all, delete-orphan")
    user = relationship("UserModel", back_populates="orders")


class OrderDetailModel(Base):
    """Table to store each product inside an order"""
    __tablename__ = "order_details"

    detail_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.product_id"), nullable=False)
    detail_quantity = Column(Integer, nullable=False)
    detail_unit_price = Column(Numeric(10, 2), nullable=False)
    detail_subtotal = Column(Numeric(10, 2), nullable=False)

    order = relationship("OrderModel", back_populates="details")


# --- VALIDATION SCHEMAS (Pydantic) ---

class CartDetailBase(BaseModel):
    product_id: int
    quantity: int = Field(..., gt=0, le=50)


class OrderCreate(BaseModel):
    items: List[CartDetailBase]
    order_notes: Optional[str] = None
    order_pickup_time: Optional[datetime] = None  # Added for Task 6


class OrderStatusUpdate(BaseModel):
    order_status: str

    @validator('order_status')
    def CheckValidStatus(cls, v):
        # Valid states for staff according to task
        valid_states = ['pendiente', 'en_preparacion', 'listo', 'entregado', 'cancelado']
        if v not in valid_states:
            raise ValueError(f"Estado no permitido. Use: {valid_states}")
        return v


class OrderResponse(BaseModel):
    order_id: int
    user_id: int
    order_date_time: datetime
    order_status: str
    order_total: float
    order_notes: Optional[str]
    order_service: Optional[str]

    class Config:
        orm_mode = True


# New schema for staff view
class OrderStaffResponse(OrderResponse):
    user_name: str
    is_new: bool  # Calculated from order_staff_seen
    order_pickup_time: Optional[datetime]


class OrderListResponse(BaseModel):
    order_id: int
    order_date_time: datetime
    order_status: str
    order_total: float
    items_count: int

    class Config:
        orm_mode = True