from pydantic import BaseModel, Field, validator
from typing import Optional
from decimal import Decimal


class IngredienteBase(BaseModel):
    ingrediente_nombre: str = Field(..., max_length=100)
    ingrediente_stockActual: Decimal
    ingrediente_stockMinimo: Decimal
    # Unidad de medida del stock: kg, g, L, ml, unidades.
    ingrediente_unidadMedida: str
    ingrediente_precioUnitario: Decimal

    @validator('ingrediente_unidadMedida')
    def validar_unidad(cls, v):
        # Rechaza cualquier valor que no sea exactamente uno de los permitidos.
        unidades_validas = ['kg', 'g', 'L', 'ml', 'unidades']
        if v not in unidades_validas:
            raise ValueError(f"Unidad debe ser una de: {unidades_validas}")
        return v

# Todos los campos de IngredienteBase son obligatorios al crear un ingrediente.
class IngredienteCreate(IngredienteBase):
    pass


# Todos los campos opcionales para permitir actualizaciones parciales.
class IngredienteUpdate(BaseModel):
    ingrediente_nombre: Optional[str] = None
    ingrediente_stockActual: Optional[Decimal] = None
    ingrediente_stockMinimo: Optional[Decimal] = None
    ingrediente_unidadMedida: Optional[str] = None
    ingrediente_precioUnitario: Optional[Decimal] = None


class IngredienteResponse(IngredienteBase):
    ingrediente_id: int
    ingrediente_activo: bool
    # Campo calculado en el service comparando stockActual con stockMinimo.
    # No existe en la BD, tiene como valores posibles: "crítico", "bajo", "normal".
    estado_stock: str

    class Config:
        from_attributes = True