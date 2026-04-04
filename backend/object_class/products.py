from pydantic import BaseModel, Field, validator
from typing import Optional, List
from decimal import Decimal


class AlergenoResponse(BaseModel):
    """Schema para la respuesta de alérgenos"""
    alergeno_id: int
    nombre: str

    class Config:
        from_attributes = True


class ProductoBase(BaseModel):
    producto_nombre: str = Field(..., max_length=100)
    producto_descripcion: Optional[str] = None
    producto_precioUnitario: Decimal = Field(..., gt=0)
    # Valores válidos: Cafetería, Restaurante, Repostería.
    producto_categoria: str = Field(..., max_length=50)
    image_url: Optional[str] = None  # Campo para la imagen

    @validator('producto_categoria')
    def validar_categoria(cls, v):
        categorias_validas = ['Cafetería', 'Restaurante', 'Repostería']
        if v not in categorias_validas:
            raise ValueError(f'Categoría debe ser una de: {categorias_validas}')
        return v


# Todos los campos de ProductoBase que son obligatorios al crear un producto.
class ProductoCreate(ProductoBase):
    alergeno_ids: Optional[List[int]] = None  # Permite asignar alérgenos en la creación


class ProductoUpdate(BaseModel):
    producto_nombre: Optional[str] = Field(None, max_length=100)
    producto_descripcion: Optional[str] = None
    producto_precioUnitario: Optional[Decimal] = Field(None, gt=0)
    producto_categoria: Optional[str] = Field(None, max_length=50)
    image_url: Optional[str] = None  # Permite actualizar la imagen
    alergeno_ids: Optional[List[int]] = None  # Lista de IDs para actualizar alérgenos

    @validator('producto_categoria')
    def validar_categoria(cls, v):
        # El if v is not None es necesario por si el campo es opcional.
        # Sin él, no mandar categoría lanzaría un error de validación innecesario.
        if v is not None:
            categorias_validas = ['Cafetería', 'Restaurante', 'Repostería']
            if v not in categorias_validas:
                raise ValueError(f'Categoría debe ser una de: {categorias_validas}')
        return v


class ProductoResponse(ProductoBase):
    producto_id: int
    producto_activo: bool
    # Campos calculados por disponibilidad_service, no existen en la BD.
    unidades_disponibles: int
    disponible: bool
    alergenos: List[AlergenoResponse] = []  # Lista de alérgenos en la respuesta

    class Config:
        from_attributes = True


class ProductoIngredienteBase(BaseModel):
    """Datos necesarios para añadir un ingrediente a un producto."""
    ingrediente_id: int = Field(..., gt=0)
    cantidad_necesaria: Decimal = Field(..., gt=0)


class IngredienteDetalleEnProducto(BaseModel):
    """Detalle de un ingrediente dentro de un producto.
    Incluye cuántas unidades del producto se pueden hacer con este ingrediente
    y si ese el ingrediente limita la disponibilidad total."""
    ingrediente_id: int
    ingrediente_nombre: str
    cantidad_necesaria: Decimal
    unidad_medida: Optional[str] = None
    stock_disponible: Decimal
    unidades_posibles: int
    # True si este ingrediente es el que limita la disponibilidad total del producto.
    es_limitante: bool


class ProductoDetalleResponse(ProductoResponse):
    """Detalle completo de un producto incluyendo análisis de disponibilidad por ingrediente."""
    ingredientes: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None

    class Config:
        from_attributes = True


class DisponibilidadDetalleResponse(BaseModel):
    """Análisis de disponibilidad de un producto desglosado por ingrediente."""
    producto_id: int
    producto_nombre: str
    unidades_disponibles: int
    disponible: bool
    ingredientes_detalle: List[IngredienteDetalleEnProducto]
    ingrediente_limitante: Optional[str] = None


# ============================================================================
# Schemas para búsqueda y filtros
# ============================================================================

class ProductSearchFilters(BaseModel):
    """Filtros disponibles para la búsqueda avanzada de productos."""
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
    """Respuesta de búsqueda: lista de productos, total encontrado y filtros aplicados."""
    products: List[ProductoResponse]
    total_count: int
    filters_applied: ProductSearchFilters