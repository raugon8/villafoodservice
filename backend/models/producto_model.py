from sqlalchemy import Column, Integer, String, Boolean, Numeric, Text, ForeignKey
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base


class Producto(Base):
    __tablename__ = "productos"

    producto_id             = Column(Integer, primary_key=True, index=True, autoincrement=True)
    producto_nombre         = Column(String(100), unique=True, nullable=False)
    producto_descripcion    = Column(Text, nullable=True)
    producto_precioUnitario = Column(Numeric(10, 2), nullable=False)
    # Valores válidos para el schema Pydantic: Cafetería, Restaurante, Repostería.
    producto_categoria      = Column(String(50), nullable=False)
    # Soft delete: Si es False el producto no aparece en el catálogo pero se conserva en la BD.
    producto_activo         = Column(Boolean, default=True)

    # Usamos cascade="all, delete-orphan" para que si se elimina el producto, se eliminan sus relaciones con ingredientes.
    productos_ingredientes = relationship(
        "ProductoIngrediente",
        back_populates="producto",
        cascade="all, delete-orphan"
    )


class ProductoIngrediente(Base):
    """Tabla intermedia entre Producto e Ingrediente (relación muchos-a-muchos).
    Además de la relación, guarda la cantidad necesaria del ingrediente para elaborar el producto, útil para la disponibilidad."""
    __tablename__ = "productos_ingredientes"

    productoIngrediente_id          = Column(Integer, primary_key=True, index=True, autoincrement=True)
    productoIngrediente_productoId  = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)
    productoIngrediente_ingredienteId = Column(Integer, ForeignKey("ingredientes.ingrediente_id"), nullable=False)
    # Cantidad del ingrediente necesaria para elaborar una unidad del producto.
    productoIngrediente_cantidad    = Column(Numeric(10, 2), nullable=False)

    producto    = relationship("Producto", back_populates="productos_ingredientes")
    ingrediente = relationship("Ingrediente", back_populates="productos_vinculados")

    # PENDIENTE: activar UniqueConstraint al migrar a PostgreSQL para evitar ingredientes duplicados.
    # __table_args__ = (UniqueConstraint('productoIngrediente_productoId', 'productoIngrediente_ingredienteId', name='uix_producto_ingrediente'),)
    __table_args__ = (
        {'sqlite_autoincrement': True},
    )