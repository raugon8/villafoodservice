"""
Modelos de base de datos para Productos
Define las tablas: Productos y ProductosIngredientes (relación muchos-a-muchos)
"""
from sqlalchemy import Column, Integer, String, Boolean, Numeric, Text, ForeignKey
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base


class Producto(Base):
    """Modelo para la tabla productos"""
    __tablename__ = "productos"

    # Campos de la tabla
    producto_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    producto_nombre = Column(String(100), unique=True, nullable=False)
    producto_descripcion = Column(Text, nullable=True)
    producto_precioUnitario = Column(Numeric(10, 2), nullable=False)
    producto_categoria = Column(String(50), nullable=False)  # Cafetería, Restaurante, Repostería
    producto_activo = Column(Boolean, default=True)

    # Relaciones
    # Relación con ProductosIngredientes (un producto tiene múltiples ingredientes)
    productos_ingredientes = relationship(
        "ProductoIngrediente", 
        back_populates="producto",
        cascade="all, delete-orphan"  # Si se elimina producto, se eliminan sus ingredientes
    )


class ProductoIngrediente(Base):
    """
    Modelo para la tabla intermedia productos_ingredientes
    Relación muchos-a-muchos entre Productos e Ingredientes
    """
    __tablename__ = "productos_ingredientes"

    # Campos de la tabla
    productoIngrediente_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    productoIngrediente_productoId = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)
    productoIngrediente_ingredienteId = Column(Integer, ForeignKey("ingredientes.ingrediente_id"), nullable=False)
    productoIngrediente_cantidad = Column(Numeric(10, 2), nullable=False)  # Cantidad necesaria del ingrediente

    # Relaciones
    # Relación con Producto
    producto = relationship("Producto", back_populates="productos_ingredientes")
    
    # Relación con Ingrediente
    ingrediente = relationship("Ingrediente", back_populates="productos_vinculados")

    # IMPORTANTE: Constraint único para evitar duplicados
    # No se puede añadir el mismo ingrediente dos veces al mismo producto
    __table_args__ = (
        {'sqlite_autoincrement': True},
    )
    # Nota: En producción con PostgreSQL, añadir UniqueConstraint:
    # from sqlalchemy import UniqueConstraint
    # __table_args__ = (UniqueConstraint('productoIngrediente_productoId', 'productoIngrediente_ingredienteId', name='uix_producto_ingrediente'),)