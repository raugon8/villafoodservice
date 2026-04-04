from sqlalchemy import Column, Integer, String, Numeric, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from backend.database_manager.database import Base


class OrderModel(Base):
    """Tabla principal de pedidos. Cada fila representa un pedido completo."""
    __tablename__ = "orders"

    order_id        = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id         = Column(Integer, ForeignKey("usuarios.usuario_id"), nullable=False)
    order_date_time = Column(DateTime, default=datetime.now, nullable=False)
    order_status    = Column(String(20), default="pendiente", nullable=False)
    order_total     = Column(Numeric(10, 2), nullable=False)
    order_notes     = Column(Text, nullable=True)
    # Hora de recogida solicitada por el cliente.
    order_pickup_time = Column(DateTime, nullable=True)
    # Servicio: Cafeteria, restaurante, reposteria. El pedido será de la categoría del primer producto al confirmar el pedido.
    order_service   = Column(String(20), nullable=True)
    # Indica si el dependiente ya vio el pedido.
    order_staff_seen = Column(Boolean, default=False, nullable=False)

    # Uso cascade="all, delete-orphan" para que si se borra el pedido, se borren también sus detalles(son tablas diferentes).
    details = relationship("OrderDetailModel", back_populates="order", cascade="all, delete-orphan")
    user    = relationship("User", back_populates="orders")


class OrderDetailModel(Base):
    """Tabla de líneas de pedido. Cada fila representa un producto dentro de un pedido."""
    __tablename__ = "order_details"

    detail_id   = Column(Integer, primary_key=True, index=True, autoincrement=True)
    order_id    = Column(Integer, ForeignKey("orders.order_id", ondelete="CASCADE"), nullable=False)
    product_id  = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)
    detail_quantity = Column(Integer, nullable=False)
    # El precio se guarda en el momento del pedido para que cambios futuros de precio no afecten al historial.
    detail_unit_price = Column(Numeric(10, 2), nullable=False)
    detail_subtotal   = Column(Numeric(10, 2), nullable=False)

    order = relationship("OrderModel", back_populates="details")