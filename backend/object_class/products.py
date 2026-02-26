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
            raise ValueError(f'Categoría debe ser una de: {categorias_validas}')
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
                raise ValueError(f'Categoría debe ser una de: {categorias_validas}')
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
    unidad_medida: Optional[str] = None
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


# ============================================================================
# Schemas para búsqueda y filtros (Tarea 9)
# ============================================================================

class ProductSearchFilters(BaseModel):
    """Filtros disponibles para la búsqueda de productos"""
    search_query: Optional[str] = None
    service: Optional[str] = None
    category_id: Optional[int] = None
    available_only: bool = False
    min_price: Optional[Decimal] = None
    max_price: Optional[Decimal] = None
    active_only: bool = True
    sort_by: Optional[str] = "name_asc"
    skip: int = 0
    limit: int = 20


class ProductSearchResponse(BaseModel):
    """Respuesta con resultados de búsqueda y metadatos"""
    products: List[ProductoResponse]
    total_count: int
    filters_applied: ProductSearchFilters