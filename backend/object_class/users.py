from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from database_manager.database import Base


class UserModel(Base):
    """Modelo de la tabla usuarios con soporte para roles y servicios"""
    __tablename__ = "usuarios"

    # Columnas principales del usuario
    usuario_id = Column(Integer, primary_key=True, autoincrement=True)  #
    nombre_usuario = Column(String, nullable=False)  #
    correo = Column(String, unique=True, nullable=False)  #
    contraseña = Column(String, nullable=False)  #

    # Campo para asignar el servicio al personal de staff
    usuario_servicio = Column(String(20), nullable=True)  # cafeteria, restaurante, reposteria

    # Relacion uno a muchos con pedidos
    orders = relationship("OrderModel", back_populates="user")  # [cite: 529]

    # Relacion muchos a muchos con roles mediante la tabla intermedia
    roles = relationship("RoleModel", secondary="user_roles", back_populates="users")  #