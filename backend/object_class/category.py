from database_manager.database import Base
from sqlalchemy import Column, Integer, String, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field
from typing import Optional

class CategoryModel(Base):
    """Modelo para las categorias de productos"""
    __tablename__ = "categories"

    category_id = Column(Integer, primary_key=True, autoincrement=True)
    category_name = Column(String(100), unique=True, nullable=False)
    category_description = Column(Text, nullable=True)
    category_active = Column(Boolean, default=True)

    # Relacion muchos a muchos con productos
    products = relationship("ProductModel", secondary="category_products", back_populates="categories")

class CategoryProductModel(Base):
    """Tabla intermedia para relacionar productos y categorias"""
    __tablename__ = "category_products"

    category_product_id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(Integer, ForeignKey("categories.category_id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.product_id"), nullable=False)

class CategoryBase(BaseModel):
    category_name: str = Field(..., max_length=100)
    category_description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(BaseModel):
    category_name: Optional[str] = None
    category_description: Optional[str] = None
    category_active: Optional[bool] = None

class CategoryResponse(CategoryBase):
    category_id: int
    category_active: bool

    class Config:
        orm_mode = True