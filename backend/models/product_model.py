from sqlalchemy import Column, Integer, String, Boolean, Numeric, Text, ForeignKey
from sqlalchemy.orm import relationship
from backend.database_manager.database import Base

class AlergenoModel(Base):
    __tablename__ = "alergenos"
    alergeno_id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(100), unique=True, nullable=False)

class ProductoAlergenoModel(Base):
    __tablename__ = "producto_alergenos"
    producto_alergeno_id = Column(Integer, primary_key=True, autoincrement=True)
    producto_id = Column(Integer, ForeignKey("products.product_id", ondelete="CASCADE"), nullable=False)
    alergeno_id = Column(Integer, ForeignKey("alergenos.alergeno_id", ondelete="CASCADE"), nullable=False)

class ProductModel(Base):
    __tablename__ = "products"

    product_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    product_name = Column(String(100), unique=True, nullable=False)
    product_description = Column(Text, nullable=True)
    product_price = Column(Numeric(10, 2), nullable=False)
    product_category = Column(String(50), nullable=False)
    product_active = Column(Boolean, default=True)
    image_url = Column(String(255), nullable=True) # Nuevo campo para la imagen

    # Relaciones
    product_ingredients = relationship("ProductIngredientModel", back_populates="product")
    alergenos = relationship("AlergenoModel", secondary="producto_alergenos") # Relación M:N