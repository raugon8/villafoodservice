from sqlalchemy import Column, Integer, String, Boolean, Numeric, Text, ForeignKey
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base


class AlergenoModel(Base):
    """14 alérgenos de declaración obligatoria en Europa. Listado fijo, no gestionable por el admin."""
    __tablename__ = "alergenos"

    alergeno_id = Column(Integer, primary_key=True, autoincrement=True)
    nombre      = Column(String(100), unique=True, nullable=False)


class ProductoAlergenoModel(Base):
    """Tabla intermedia M:N entre Producto y AlergenoModel."""
    __tablename__ = "producto_alergenos"

    producto_alergeno_id = Column(Integer, primary_key=True, autoincrement=True)
    producto_id          = Column(Integer, ForeignKey("productos.producto_id", ondelete="CASCADE"), nullable=False)
    alergeno_id          = Column(Integer, ForeignKey("alergenos.alergeno_id", ondelete="CASCADE"), nullable=False)


class Producto(Base):
    __tablename__ = "productos"

    producto_id             = Column(Integer, primary_key=True, index=True, autoincrement=True)
    producto_nombre         = Column(String(100), unique=True, nullable=False)
    producto_descripcion    = Column(Text, nullable=True)
    producto_precioUnitario = Column(Numeric(10, 2), nullable=False)
    # Valores válidos: Cafetería, Restaurante, Repostería.
    producto_categoria      = Column(String(50), nullable=False)
    # Soft delete: Si es False el producto no aparece en el catálogo pero se conserva en la BD.
    producto_activo         = Column(Boolean, default=True)
    # URL pública de la imagen en Supabase Storage. Null si no tiene imagen.
    image_url               = Column(String(255), nullable=True)

    # Relación con ingredientes. cascade="all, delete-orphan": si se elimina el producto, se eliminan sus relaciones.
    productos_ingredientes = relationship(
        "ProductoIngrediente",
        back_populates="producto",
        cascade="all, delete-orphan"
    )

    # Relación M:N con alérgenos a través de la tabla intermedia.
    alergenos = relationship(
        "AlergenoModel",
        secondary="producto_alergenos"
    )


class ProductoIngrediente(Base):
    """Tabla intermedia entre Producto e Ingrediente (M:N).
    Guarda la cantidad del ingrediente necesaria para elaborar una unidad del producto."""
    __tablename__ = "productos_ingredientes"

    productoIngrediente_id            = Column(Integer, primary_key=True, index=True, autoincrement=True)
    productoIngrediente_productoId    = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)
    productoIngrediente_ingredienteId = Column(Integer, ForeignKey("ingredientes.ingrediente_id"), nullable=False)
    # Cantidad del ingrediente necesaria para elaborar una unidad del producto.
    productoIngrediente_cantidad      = Column(Numeric(10, 2), nullable=False)

    producto    = relationship("Producto", back_populates="productos_ingredientes")
    ingrediente = relationship("Ingrediente", back_populates="productos_vinculados")