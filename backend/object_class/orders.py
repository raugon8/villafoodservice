from database_manager.database import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field, validator
from typing import List, Optional
from datetime import datetime

# --- DATABASE MODELS (SQLAlchemy) ---

class OrderModel(Base):
    """Table to store general order information"""
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.usuario_id"), nullable=False)
    order_date_time = Column(DateTime, default=datetime.now)
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

    # Relation with main order
    order = relationship("OrderModel", back_populates="details")

# --- VALIDATION SCHEMAS (Pydantic) ---

class CartDetailBase(BaseModel):
    """Schema for products added to the cart"""
    product_id: int
    quantity: int = Field(..., gt=0, le=50) # Validates quantity between 1 and 50

class OrderCreate(BaseModel):
    """Schema to create a new order"""
    items: List[CartDetailBase]
    order_notes: Optional[str] = None

class OrderStatusUpdate(BaseModel):
    """Schema to change the status of an order"""
    order_status: str

    @validator('order_status')
    def CheckValidStatus(cls, v):
        valid_states = ['pendiente', 'en_preparacion', 'listo', 'entregado', 'cancelado']
        if v not in valid_states:
            raise ValueError(f"Estado no permitido. Use: {valid_states}")
        return v

class OrderResponse(BaseModel):
    """Detailed order info for response"""
    order_id: int
    user_id: int
    order_date_time: datetime
    order_status: str
    order_total: float
    order_notes: Optional[str]

    class Config:
        orm_mode = True

class OrderListResponse(BaseModel):
    """Summary of an order for lists"""
    order_id: int
    order_date_time: datetime
    order_status: str
    order_total: float
    items_count: int

    class Config:
        orm_mode = True