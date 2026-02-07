"""
Servicio para Ingredientes
Lógica de negocio para la gestión de ingredientes
"""
"""
Servicio para Ingredientes
Lógica de negocio para la gestión de ingredientes
"""
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

# Imports de los modelos
from backend.models.ingredient_model import Ingrediente
from backend.models.producto_model import ProductoIngrediente


# ============================================================================
# FUNCIÓN 1: Calcular si el stock está crítico/bajo/normal
# ============================================================================
def calcular_estado_stock(stock_actual: Decimal, stock_minimo: Decimal) -> str:
    """Calcula el estado del stock según nivel actual vs mínimo"""
    if stock_actual == 0:
        return "crítico"
    elif stock_actual < stock_minimo:
        return "bajo"
    else:
        return "normal"


# ============================================================================
# FUNCIÓN 2: Listar todos los ingredientes activos
# ============================================================================
def get_ingredientes(db: Session, skip: int = 0, limit: int = 100) -> List[dict]:
    """Obtiene lista de ingredientes activos"""
    
    # Query: buscar solo ingredientes activos
    ingredientes = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_activo == True
    ).offset(skip).limit(limit).all()
    
    # Para cada ingrediente, calcular su estado de stock y convertir a dict
    resultado = []
    for ing in ingredientes:
        estado = calcular_estado_stock(ing.ingrediente_stockActual, ing.ingrediente_stockMinimo)
        
        # Convertir a dict y añadir campo calculado
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


# ============================================================================
# FUNCIÓN 3: Obtener un ingrediente específico por ID
# ============================================================================
def get_ingrediente(db: Session, ingrediente_id: int) -> Optional[dict]:
    """Busca un ingrediente específico por ID (solo activos)"""
    
    # Query: buscar por ID y que esté activo
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()
    
    # Si no existe, retornar None
    if not ingrediente:
        return None
    
    # Calcular estado de stock
    estado = calcular_estado_stock(ingrediente.ingrediente_stockActual, ingrediente.ingrediente_stockMinimo)
    
    # Convertir a dict y añadir campo calculado
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


# ============================================================================
# FUNCIÓN 4: Crear nuevo ingrediente
# ============================================================================
def create_ingrediente(db: Session, ingrediente_data: dict) -> dict:
    """Crea un nuevo ingrediente con validación de nombre único"""
    
    # VALIDACIÓN: verificar que NO exista otro ingrediente con el mismo nombre
    existe = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_nombre == ingrediente_data["ingrediente_nombre"]
    ).first()
    
    if existe:
        raise HTTPException(
            status_code=400, 
            detail="Ya existe un ingrediente con ese nombre"
        )
    
    # Crear nuevo ingrediente con los datos recibidos
    nuevo_ingrediente = Ingrediente(**ingrediente_data)
    
    # Guardar en base de datos
    db.add(nuevo_ingrediente)
    db.commit()
    db.refresh(nuevo_ingrediente)  # Actualizar para obtener el ID generado
    
    # Calcular estado de stock
    estado = calcular_estado_stock(nuevo_ingrediente.ingrediente_stockActual, nuevo_ingrediente.ingrediente_stockMinimo)
    
    # Retornar como dict con estado_stock
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


# ============================================================================
# FUNCIÓN 5: Actualizar ingrediente existente
# ============================================================================
def update_ingrediente(db: Session, ingrediente_id: int, ingrediente_data: dict) -> Optional[dict]:
    """Actualiza un ingrediente con validación de nombre único si se cambia"""
    
    # Buscar ingrediente por ID (solo activos)
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()
    
    # Si no existe, retornar None
    if not ingrediente:
        return None
    
    # VALIDACIÓN: si se actualiza el nombre, verificar que no exista OTRO ingrediente con ese nombre
    if "ingrediente_nombre" in ingrediente_data:
        existe_otro = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_nombre == ingrediente_data["ingrediente_nombre"],
            Ingrediente.ingrediente_id != ingrediente_id
        ).first()
        
        if existe_otro:
            raise HTTPException(
                status_code=400,
                detail="Ya existe un ingrediente con ese nombre"
            )
    
    # Actualizar solo los campos que vengan en ingrediente_data
    for key, value in ingrediente_data.items():
        setattr(ingrediente, key, value)
    
    # Guardar cambios
    db.commit()
    db.refresh(ingrediente)
    
    # Calcular estado de stock
    estado = calcular_estado_stock(ingrediente.ingrediente_stockActual, ingrediente.ingrediente_stockMinimo)
    
    # Retornar actualizado con estado_stock
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


# ============================================================================
# FUNCIÓN 6: Eliminar ingrediente (soft delete)
# ============================================================================
def delete_ingrediente(db: Session, ingrediente_id: int) -> bool:
    """Elimina un ingrediente (soft delete) si no está en uso"""
    
    # Buscar ingrediente por ID (solo activos)
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()
    
    # Si no existe, retornar False
    if not ingrediente:
        return False
    
    # VALIDACIÓN CRÍTICA: verificar que NO esté en uso en ProductosIngredientes
    en_uso = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()
    
    if en_uso:
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar: el ingrediente está siendo usado en productos"
        )
    
    # Soft delete: marcar como inactivo en lugar de eliminar físicamente
    ingrediente.ingrediente_activo = False
    db.commit()
    
    return True


# ============================================================================
# FUNCIÓN 7: Obtener ingredientes con stock bajo
# ============================================================================
def verificar_stock_bajo(db: Session) -> List[dict]:
    """Obtiene ingredientes con stock bajo o crítico (útil para alertas)"""
    
    # Query: ingredientes activos con stock bajo
    ingredientes = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_activo == True,
        Ingrediente.ingrediente_stockActual < Ingrediente.ingrediente_stockMinimo
    ).all()
    
    # Construir lista con estado_stock calculado
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