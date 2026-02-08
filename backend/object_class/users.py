from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from database_manager.database import Base

class UserModel(Base):
    """User table with assigned service for staff """
    __tablename__ = "usuarios"

    usuario_id = Column(Integer, primary_key=True, autoincrement=True)
    nombre_usuario = Column(String, nullable=False)
    correo = Column(String, unique=True, nullable=False)
    contraseña = Column(String, nullable=False)
    # New field for staff assignment 
    usuario_servicio = Column(String(20), nullable=True) # cafeteria, restaurante, reposteria

    # Relations
    orders = relationship("OrderModel", back_populates="user")