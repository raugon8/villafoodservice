from sqlalchemy import Column, Integer, String, Boolean, Numeric
from sqlalchemy.orm import relationship
from database_manager.db_setup import Base #ajustar según la conexión

class Ingrediente(Base):
    __tablename__ = "ingredientes"

    ingrediente_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    ingrediente_nombre = Column(String(100), unique=True, nullable=False)
    ingrediente_stockActual = Column(Numeric(10, 2), nullable=False)
    ingrediente_stockMinimo = Column(Numeric(10, 2), nullable=False)
    ingrediente_unidadMedida = Column(String(20), nullable=False)
    ingrediente_precioUnitario = Column(Numeric(10, 2), nullable=False)
    ingrediente_activo = Column(Boolean, default=True)

    #relacion para verificar uso antes de eliminar (lo usará Adán)
    productos_vinculados = relationship("ProductoIngrediente", back_populates="ingrediente")