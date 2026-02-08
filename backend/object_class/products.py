from pydantic import BaseModel, Field, validator
from typing import Optional, List
from decimal import Decimal

class ProductBase(BaseModel):
    name: str = Field(..., max_length=100)
    description: Optional[str] = None
    price: Decimal = Field(..., gt=0) # [cite: 388]
    category: str

    @validator('category')
    def CheckCategory(cls, v):
        valid_categories = ["Cafetería", "Restaurante", "Repostería"]
        if v not in valid_categories:
            raise ValueError(f"Categoría inválida. Use: {valid_categories}")
        return v

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = None
    category: Optional[str] = None

class ProductIngredientBase(BaseModel):
    ingredient_id: int
    quantity: Decimal = Field(..., gt=0)

class ProductResponse(ProductBase):
    product_id: int
    product_active: bool
    units_available: int
    is_available: bool 

    class Config:
        orm_mode = True