from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from database_manager.database import Base

class UserModel(Base):
    __tablename__ = "usuarios"

    # Columns using snake_case
    usuario_id = Column(Integer, primary_key=True, autoincrement=True)
    nombre_usuario = Column(String, nullable=False)
    correo = Column(String, unique=True, nullable=False)
    contraseña = Column(String, nullable=False)

    # Relation with orders table
    orders = relationship("OrderModel", back_populates="user")