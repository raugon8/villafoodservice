from sqlalchemy import Column, Integer, String, Boolean, Text, ForeignKey
from backend.database_manager.database import Base


class CategoryModel(Base):
    """Categorías de productos disponibles en el sistema."""
    __tablename__ = "categories"

    category_id          = Column(Integer, primary_key=True, autoincrement=True)
    category_name        = Column(String(100), unique=True, nullable=False)
    category_description = Column(Text, nullable=True)
    # Soft delete: Si es False la categoría no aparece en el sistema pero se conserva en la BD.
    category_active      = Column(Boolean, default=True)


class CategoryProductModel(Base):
    """Tabla intermedia entre categorías y productos (relación muchos-a-muchos)."""
    __tablename__ = "category_products"

    category_product_id = Column(Integer, primary_key=True, autoincrement=True)
    category_id         = Column(Integer, ForeignKey("categories.category_id"), nullable=False)
    product_id          = Column(Integer, ForeignKey("productos.producto_id"), nullable=False)