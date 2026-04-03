from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base


class User(Base):
    __tablename__ = "usuarios"

    usuario_ID     = Column(Integer, primary_key=True, autoincrement=True)
    nombre_usuario = Column(String, nullable=False)
    correo         = Column(String, unique=True, nullable=False)
    contraseña     = Column(String, nullable=False)
    # Servicio asignado al dependiente: Cafeteria, restaurante, reposteria; para el resto de roles es None.
    usuario_servicio = Column(String(20), nullable=True)

    # Relaciones con latabla de pedidos y roles.
    orders = relationship("OrderModel", back_populates="user")
    roles  = relationship("RoleModel", secondary="user_roles", back_populates="users")