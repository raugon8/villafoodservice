"""
Schemas Pydantic para Productos
Define las estructuras de datos para validación y respuesta de la API
"""
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from decimal import Decimal


# ============================================================================
# SCHEMAS PARA PRODUCTOS
# ============================================================================

class ProductoBase(BaseModel):
    """Schema base con campos comunes de productos"""
    producto_nombre: str = Field(..., max_length=100)
    producto_descripcion: Optional[str] = None
    producto_precioUnitario: Decimal = Field(..., gt=0, description="Precio debe ser mayor a 0")
    producto_categoria: str = Field(..., max_length=50)
    
    @validator('producto_categoria')
    def validar_categoria(cls, v):
        categorias_validas = ['Cafetería', 'Restaurante', 'Repostería']
        if v not in categorias_validas:
            raise ValueError(f"Categoría debe ser una de: {categorias_validas}")
        return v


class ProductoCreate(ProductoBase):
    """Schema para crear un producto nuevo"""
    pass  # Hereda todos los campos obligatorios de ProductoBase


class ProductoUpdate(BaseModel):
    """Schema para actualizar un producto (todos los campos opcionales)"""
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
    """Schema de respuesta con datos calculados"""
    producto_id: int
    producto_activo: bool
    unidades_disponibles: int  # Campo calculado en tiempo real
    disponible: bool  # True si unidades_disponibles > 0
    
    class Config:
        from_attributes = True


# ============================================================================
# SCHEMAS PARA INGREDIENTES DE PRODUCTOS
# ============================================================================

class ProductoIngredienteBase(BaseModel):
    """Schema para añadir/actualizar ingrediente en producto"""
    ingrediente_id: int = Field(..., gt=0)
    cantidad_necesaria: Decimal = Field(..., gt=0, description="Cantidad debe ser mayor a 0")


class IngredienteDetalleEnProducto(BaseModel):
    """Detalle de un ingrediente dentro de un producto"""
    ingrediente_id: int
    ingrediente_nombre: str
    cantidad_necesaria: Decimal
    unidad_medida: str
    stock_disponible: Decimal
    unidades_posibles: int  # Cuántas unidades del producto se pueden hacer con este ingrediente
    es_limitante: bool  # True si es el que limita la disponibilidad


class ProductoDetalleResponse(ProductoResponse):
    """Respuesta detallada con información de ingredientes"""
    ingredientes: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None  # Nombre del ingrediente que limita
    
    class Config:
        from_attributes = True


# ============================================================================
# SCHEMA PARA RESPUESTA DE DISPONIBILIDAD DETALLADA
# ============================================================================

class DisponibilidadDetalleResponse(BaseModel):
    """Respuesta con análisis detallado de disponibilidad"""
    producto_id: int
    producto_nombre: str
    unidades_disponibles: int
    disponible: bool
    ingredientes_detalle: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None