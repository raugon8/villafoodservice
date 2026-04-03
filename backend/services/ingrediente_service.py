from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

from backend.models.ingredient_model import Ingrediente
from backend.models.producto_model import ProductoIngrediente


def calcular_estado_stock(stock_actual: Decimal, stock_minimo: Decimal) -> str:
    """Devuelve el estado del stock: crítico (0), bajo (por debajo del mínimo), o normal."""
    if stock_actual == 0:
        return "crítico"
    elif stock_actual < stock_minimo:
        return "bajo"
    else:
        return "normal"


def get_ingredientes(db: Session, skip: int = 0, limit: int = 100) -> List[dict]:
    ingredientes = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_activo == True
    ).offset(skip).limit(limit).all()

    resultado = []
    for ing in ingredientes:
        estado = calcular_estado_stock(ing.ingrediente_stockActual, ing.ingrediente_stockMinimo)
        ingrediente_dict = {
            "ingrediente_id": ing.ingrediente_id,
            "ingrediente_nombre": ing.ingrediente_nombre,
            "ingrediente_stockActual": ing.ingrediente_stockActual,
            "ingrediente_stockMinimo": ing.ingrediente_stockMinimo,
            "ingrediente_unidadMedida": ing.ingrediente_unidadMedida,
            "ingrediente_precioUnitario": ing.ingrediente_precioUnitario,
            "ingrediente_activo": ing.ingrediente_activo,
            "estado_stock": estado
        }
        resultado.append(ingrediente_dict)

    return resultado


def get_ingrediente(db: Session, ingrediente_id: int) -> Optional[dict]:
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()

    if not ingrediente:
        return None

    estado = calcular_estado_stock(ingrediente.ingrediente_stockActual, ingrediente.ingrediente_stockMinimo)

    return {
        "ingrediente_id": ingrediente.ingrediente_id,
        "ingrediente_nombre": ingrediente.ingrediente_nombre,
        "ingrediente_stockActual": ingrediente.ingrediente_stockActual,
        "ingrediente_stockMinimo": ingrediente.ingrediente_stockMinimo,
        "ingrediente_unidadMedida": ingrediente.ingrediente_unidadMedida,
        "ingrediente_precioUnitario": ingrediente.ingrediente_precioUnitario,
        "ingrediente_activo": ingrediente.ingrediente_activo,
        "estado_stock": estado
    }


def create_ingrediente(db: Session, ingrediente_data) -> dict:
    # Convierte el objeto Pydantic a dict si es necesario, antes de trabajar con él.
    if hasattr(ingrediente_data, 'model_dump'):
        ingrediente_data = ingrediente_data.model_dump()

    existe = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_nombre == ingrediente_data["ingrediente_nombre"]
    ).first()

    if existe:
        raise HTTPException(status_code=400, detail="Ya existe un ingrediente con ese nombre")

    nuevo_ingrediente = Ingrediente(**ingrediente_data)
    db.add(nuevo_ingrediente)
    db.commit()
    db.refresh(nuevo_ingrediente)

    estado = calcular_estado_stock(nuevo_ingrediente.ingrediente_stockActual, nuevo_ingrediente.ingrediente_stockMinimo)

    return {
        "ingrediente_id": nuevo_ingrediente.ingrediente_id,
        "ingrediente_nombre": nuevo_ingrediente.ingrediente_nombre,
        "ingrediente_stockActual": nuevo_ingrediente.ingrediente_stockActual,
        "ingrediente_stockMinimo": nuevo_ingrediente.ingrediente_stockMinimo,
        "ingrediente_unidadMedida": nuevo_ingrediente.ingrediente_unidadMedida,
        "ingrediente_precioUnitario": nuevo_ingrediente.ingrediente_precioUnitario,
        "ingrediente_activo": nuevo_ingrediente.ingrediente_activo,
        "estado_stock": estado
    }


def update_ingrediente(db: Session, ingrediente_id: int, ingrediente_data) -> Optional[dict]:
    # exclude_unset=True: solo incluye los campos enviados, evita sobreescribir con None.
    if hasattr(ingrediente_data, 'model_dump'):
        ingrediente_data = ingrediente_data.model_dump(exclude_unset=True)

    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()

    if not ingrediente:
        return None

    if "ingrediente_nombre" in ingrediente_data:
        # Busca duplicados excluyendo el propio ingrediente que se está editando.
        existe_otro = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_nombre == ingrediente_data["ingrediente_nombre"],
            Ingrediente.ingrediente_id != ingrediente_id
        ).first()

        if existe_otro:
            raise HTTPException(status_code=400, detail="Ya existe un ingrediente con ese nombre")

    for key, value in ingrediente_data.items():
        setattr(ingrediente, key, value)

    db.commit()
    db.refresh(ingrediente)

    estado = calcular_estado_stock(ingrediente.ingrediente_stockActual, ingrediente.ingrediente_stockMinimo)

    return {
        "ingrediente_id": ingrediente.ingrediente_id,
        "ingrediente_nombre": ingrediente.ingrediente_nombre,
        "ingrediente_stockActual": ingrediente.ingrediente_stockActual,
        "ingrediente_stockMinimo": ingrediente.ingrediente_stockMinimo,
        "ingrediente_unidadMedida": ingrediente.ingrediente_unidadMedida,
        "ingrediente_precioUnitario": ingrediente.ingrediente_precioUnitario,
        "ingrediente_activo": ingrediente.ingrediente_activo,
        "estado_stock": estado
    }


def delete_ingrediente(db: Session, ingrediente_id: int) -> bool:
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()

    if not ingrediente:
        return False

    # Comprueba que el ingrediente no esté asignado a ningún producto antes de desactivarlo.
    en_uso = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()

    if en_uso:
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar: el ingrediente está siendo usado en productos"
        )

    # Soft delete: No se borra el registro, solo se marca como inactivo.
    ingrediente.ingrediente_activo = False
    db.commit()

    return True


def verificar_stock_bajo(db: Session) -> List[dict]:
    """Devuelve todos los ingredientes activos cuyo stock está por debajo del mínimo."""
    ingredientes = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_activo == True,
        Ingrediente.ingrediente_stockActual < Ingrediente.ingrediente_stockMinimo
    ).all()

    resultado = []
    for ing in ingredientes:
        estado = calcular_estado_stock(ing.ingrediente_stockActual, ing.ingrediente_stockMinimo)
        ingrediente_dict = {
            "ingrediente_id": ing.ingrediente_id,
            "ingrediente_nombre": ing.ingrediente_nombre,
            "ingrediente_stockActual": ing.ingrediente_stockActual,
            "ingrediente_stockMinimo": ing.ingrediente_stockMinimo,
            "ingrediente_unidadMedida": ing.ingrediente_unidadMedida,
            "ingrediente_precioUnitario": ing.ingrediente_precioUnitario,
            "ingrediente_activo": ing.ingrediente_activo,
            "estado_stock": estado
        }
        resultado.append(ingrediente_dict)

    return resultado