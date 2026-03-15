from sqlalchemy import Column, Integer, String
# Importamos la configuración del archivo anterior
from backend.database_manager.database import Base

class User(Base):
    # Nombre de la tabla en la base de datos
    __tablename__ = "usuarios"

    # Columnas exactas que pide el PDF
    usuario_ID = Column(Integer, primary_key=True, autoincrement=True)
    nombre_usuario = Column(String, nullable=False)
    correo = Column(String, unique=True, nullable=False)
    contraseña = Column(String, nullable=False)
    rol = Column(String, default="usuario")
