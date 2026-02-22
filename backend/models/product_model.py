from sqlalchemy import Column, Integer, String, Boolean, Numeric, Text
from sqlalchemy.orm import relationship
from database_manager.database import Base

class ProductModel(Base):
    __tablename__ = "products"

    product_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    product_name = Column(String(100), unique=True, nullable=False)
    product_description = Column(Text, nullable=True)
    product_price = Column(Numeric(10, 2), nullable=False)
    product_category = Column(String(50), nullable=False)
    product_active = Column(Boolean, default=True)


    product_ingredients = relationship("ProductIngredientModel", back_populates="product")