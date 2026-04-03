from sqlalchemy import Column, Integer, String, Boolean, Numeric
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base

class Ingrediente(Base):
    __tablename__ = "ingredientes"

    ingrediente_id          = Column(Integer, primary_key=True, index=True, autoincrement=True)
    ingrediente_nombre      = Column(String(100), unique=True, nullable=False)
    ingrediente_stockActual  = Column(Numeric(10, 2), nullable=False)
     # El stock mínimo sirve como umbral de alerta (bajo/crítico), no bloquea pedidos.
    ingrediente_stockMinimo  = Column(Numeric(10, 2), nullable=False)
    # Unidad del stock: kg, g, L, ml.
    ingrediente_unidadMedida = Column(String(20), nullable=False)
    ingrediente_precioUnitario = Column(Numeric(10, 2), nullable=False)
    # Soft delete.
    ingrediente_activo      = Column(Boolean, default=True)

    # Relación con la tabla intermedia ProductoIngrediente.
    # Permite verificar si el ingrediente está en uso antes de desactivarlo.
    productos_vinculados = relationship("ProductoIngrediente", back_populates="ingrediente")