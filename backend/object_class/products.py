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

class ProductSearchFilters(BaseModel):
    """Filtros disponibles para la busqueda de productos"""
    search_query: Optional[str] = None
    service: Optional[str] = None # cafeteria, restaurante, reposteria
    category_id: Optional[int] = None
    available_only: bool = False
    min_price: Optional[Decimal] = None
    max_price: Optional[Decimal] = None
    active_only: bool = True
    sort_by: Optional[str] = "name_asc" # name_asc, price_desc, popularity, etc.
    skip: int = 0
    limit: int = 20

class ProductSearchResponse(BaseModel):
    """Respuesta con resultados de busqueda y metadatos"""
    products: List[ProductResponse]
    total_count: int
    filters_applied: ProductSearchFilters