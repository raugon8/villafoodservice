from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base

class User(Base):
    __tablename__ = "usuarios"

    usuario_ID     = Column(Integer, primary_key=True, autoincrement=True)
    nombre_usuario = Column(String, nullable=False)
    correo         = Column(String, unique=True, nullable=False)
    contraseña     = Column(String, nullable=False)

    # Relation with orders table (added in Tarea 5)
    orders = relationship("OrderModel", back_populates="user")