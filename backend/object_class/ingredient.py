from pydantic import BaseModel, Field, validator
from typing import Optional
from decimal import Decimal

class IngredienteBase(BaseModel):
    ingrediente_nombre: str = Field(..., max_length=100)
    ingrediente_stockActual: Decimal
    ingrediente_stockMinimo: Decimal
    ingrediente_unidadMedida: str
    ingrediente_precioUnitario: Decimal

    @validator('ingrediente_unidadMedida')
    def validar_unidad(cls, v):
        unidades_validas = ['kg', 'g', 'L', 'ml', 'unidades']
        if v not in unidades_validas:
            raise ValueError(f"Unidad debe ser una de: {unidades_validas}")
        return v

class IngredienteCreate(IngredienteBase):
    pass # Todos los campos de Base son obligatorios aquí [cite: 33]

class IngredienteUpdate(BaseModel):
    ingrediente_nombre: Optional[str] = None
    ingrediente_stockActual: Optional[Decimal] = None
    ingrediente_stockMinimo: Optional[Decimal] = None
    ingrediente_unidadMedida: Optional[str] = None
    ingrediente_precioUnitario: Optional[Decimal] = None

class IngredienteResponse(IngredienteBase):
    ingrediente_id: int
    ingrediente_activo: bool
    estado_stock: str # Campo calculado ("crítico"/"bajo"/"normal")

    class Config:
        orm_mode = True