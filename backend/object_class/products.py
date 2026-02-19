"""
Schemas Pydantic para Productos
"""
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from decimal import Decimal

class ProductoBase(BaseModel):
    producto_nombre: str = Field(..., max_length=100)
    producto_descripcion: Optional[str] = None
    producto_precioUnitario: Decimal = Field(..., gt=0)
    producto_categoria: str = Field(..., max_length=50)

    @validator('producto_categoria')
    def validar_categoria(cls, v):
        categorias_validas = ['Cafetería', 'Restaurante', 'Repostería']
        if v not in categorias_validas:
            raise ValueError(f"Categoría debe ser una de: {categorias_validas}")
        return v

class ProductoCreate(ProductoBase):
    pass

class ProductoUpdate(BaseModel):
    producto_nombre: Optional[str] = Field(None, max_length=100)
    producto_descripcion: Optional[str] = None
    producto_precioUnitario: Optional[Decimal] = Field(None, gt=0)
    producto_categoria: Optional[str] = Field(None, max_length=50)

    @validator('producto_categoria')
    def validar_categoria(cls, v):
        if v is not None:
            categorias_validas = ['Cafetería', 'Restaurante', 'Repostería']
            if v not in categorias_validas:
                raise ValueError(f"Categoría debe ser una de: {categorias_validas}")
        return v

class ProductoResponse(ProductoBase):
    producto_id: int
    producto_activo: bool
    unidades_disponibles: int
    disponible: bool

    class Config:
        from_attributes = True

class ProductoIngredienteBase(BaseModel):
    ingrediente_id: int = Field(..., gt=0)
    cantidad_necesaria: Decimal = Field(..., gt=0)

class IngredienteDetalleEnProducto(BaseModel):
    ingrediente_id: int
    ingrediente_nombre: str
    cantidad_necesaria: Decimal
    unidad_medida: Optional[str] = None  # ✅ opcional — evita el error 500
    stock_disponible: Decimal
    unidades_posibles: int
    es_limitante: bool

class ProductoDetalleResponse(ProductoResponse):
    ingredientes: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None

    class Config:
        from_attributes = True

class DisponibilidadDetalleResponse(BaseModel):
    producto_id: int
    producto_nombre: str
    unidades_disponibles: int
    disponible: bool
    ingredientes_detalle: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None