from pydantic import BaseModel, Field
from typing import Optional


class CategoryBase(BaseModel):
    category_name: str = Field(..., max_length=100)
    category_description: Optional[str] = None

# Hereda todos los campos de CategoryBase.
class CategoryCreate(CategoryBase):
    pass

# Todos los campos opcionales para permitir actualizaciones parciales.
class CategoryUpdate(BaseModel):
    category_name: Optional[str] = None
    category_description: Optional[str] = None
    category_active: Optional[bool] = None

# Añade category_id y category_active, que solo existen tras guardar en BD.
class CategoryResponse(CategoryBase):
    category_id: int
    category_active: bool

    class Config:
        from_attributes = True