"""
Order SQLAlchemy Models
backend/models/pedido_model.py
"""
from sqlalchemy import Column, Integer, String, Numeric, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.database_manager.database import Base


class OrderModel(Base):
    """Table to store general order information"""
    __tablename__ = "orders"

    order_id        = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id         = Column(Integer, ForeignKey("usuarios.usuario_ID"), nullable=False)
    order_date_time = Column(DateTime, default=datetime.now, nullable=False)
    order_status    = Column(String(20), default="pendiente", nullable=False)
    order_total     = Column(Numeric(10, 2), nullable=False)
    order_notes     = Column(Text, nullable=True)

    # Relations
    details = relationship("OrderDetailModel", back_populates="order", cascade="all, delete-orphan")
    user    = relationship("User", back_populates="orders")


class OrderDetailModel(Base):
    """Table to store each product inside an order"""
    __tablename__ = "order_details"

    detail_id         = Column(Integer, primary_key=True, index=True, autoincrement=True)
    order_id          = Column(Integer, ForeignKey("orders.order_id", ondelete="CASCADE"), nullable=False)
    product_id        = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)
    detail_quantity   = Column(Integer, nullable=False)
    detail_unit_price = Column(Numeric(10, 2), nullable=False)
    detail_subtotal   = Column(Numeric(10, 2), nullable=False)

    # Relation with main order
    order = relationship("OrderModel", back_populates="details")