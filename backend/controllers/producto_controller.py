"""
Controller de Productos
Endpoints REST para la gestión de productos y su disponibilidad
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from decimal import Decimal

# Imports de schemas
from backend.object_class.products import (
    ProductoCreate, 
    ProductoUpdate, 
    ProductoResponse,
    ProductoDetalleResponse,
    ProductoIngredienteBase,
    DisponibilidadDetalleResponse
)

# Imports de servicios
from backend.services import producto_service, disponibilidad_service

# Import de dependencia de BD
from backend.database_manager.database import get_db

# Router
router = APIRouter(prefix="/productos", tags=["productos"])


# ============================================================================
# ENDPOINTS DE LISTADO Y CONSULTA
# ============================================================================

@router.get("/", response_model=List[ProductoResponse])
def listar_productos(
    skip: int = Query(0, ge=0, description="Número de registros a saltar"),
    limit: int = Query(100, ge=1, le=100, description="Límite de registros"),
    categoria: Optional[str] = Query(None, description="Filtrar por categoría"),
    db: Session = Depends(get_db)
):
    """
    Lista todos los productos activos con su disponibilidad.
    
    Query params:
    - skip: paginación (default 0)
    - limit: límite de resultados (default 100, max 100)
    - categoria: filtrar por categoría (Cafetería/Restaurante/Repostería)
    """
    return producto_service.get_productos(db, skip, limit, categoria)


@router.get("/disponibles", response_model=List[ProductoResponse])
def listar_productos_disponibles(
    categoria: Optional[str] = Query(None, description="Filtrar por categoría"),
    db: Session = Depends(get_db)
):
    """
    Lista solo productos que tienen stock disponible (unidades_disponibles > 0).
    
    Query params:
    - categoria: filtrar por categoría (opcional)
    """
    return disponibilidad_service.get_productos_disponibles(db, categoria)


@router.get("/{producto_id}", response_model=ProductoDetalleResponse)
def obtener_producto(
    producto_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtiene el detalle completo de un producto con información de ingredientes.
    
    Incluye:
    - Datos del producto
    - Lista de ingredientes con cantidades
    - Disponibilidad calculada
    - Ingrediente limitante
    """
    producto = producto_service.get_producto_con_ingredientes(db, producto_id)
    
    if not producto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Producto no encontrado"
        )
    
    return producto


@router.get("/{producto_id}/disponibilidad", response_model=DisponibilidadDetalleResponse)
def obtener_disponibilidad_detallada(
    producto_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtiene análisis detallado de disponibilidad de un producto.
    
    Muestra:
    - Unidades disponibles totales
    - Análisis por ingrediente (stock, unidades posibles)
    - Cuál ingrediente es el limitante
    """
    detalle = disponibilidad_service.get_detalle_disponibilidad(db, producto_id)
    
    if not detalle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Producto no encontrado"
        )
    
    return detalle


# ============================================================================
# ENDPOINTS DE CREACIÓN Y MODIFICACIÓN
# ============================================================================

@router.post("/", response_model=ProductoResponse, status_code=status.HTTP_201_CREATED)
def crear_producto(
    producto_in: ProductoCreate,
    db: Session = Depends(get_db)
):
    """
    Crea un nuevo producto.
    
    Validaciones:
    - Nombre único (no puede existir otro con el mismo nombre)
    - Precio > 0
    - Categoría válida (Cafetería/Restaurante/Repostería)
    
    Nota: El producto se crea sin ingredientes. Usar endpoints de ingredientes para añadirlos.
    """
    producto_data = producto_in.dict()
    return producto_service.create_producto(db, producto_data)


@router.put("/{producto_id}", response_model=ProductoResponse)
def actualizar_producto(
    producto_id: int,
    producto_in: ProductoUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualiza un producto existente.
    
    Solo se actualizan los campos proporcionados (todos son opcionales).
    
    Validaciones:
    - Si se cambia nombre, debe ser único
    - Si se cambia precio, debe ser > 0
    - Si se cambia categoría, debe ser válida
    """
    # Convertir a dict y eliminar valores None
    producto_data = {k: v for k, v in producto_in.dict().items() if v is not None}
    
    if not producto_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se proporcionaron campos para actualizar"
        )
    
    resultado = producto_service.update_producto(db, producto_id, producto_data)
    
    if not resultado:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Producto no encontrado"
        )
    
    return resultado


@router.delete("/{producto_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_producto(
    producto_id: int,
    db: Session = Depends(get_db)
):
    """
    Elimina un producto (soft delete).
    
    Validaciones:
    - No se puede eliminar si tiene pedidos activos
    
    Nota: No elimina físicamente, solo marca como inactivo (producto_activo = False)
    """
    eliminado = producto_service.delete_producto(db, producto_id)
    
    if not eliminado:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Producto no encontrado"
        )
    
    return None


# ============================================================================
# ENDPOINTS DE GESTIÓN DE INGREDIENTES
# ============================================================================

@router.post("/{producto_id}/ingredientes", status_code=status.HTTP_201_CREATED)
def añadir_ingrediente_a_producto(
    producto_id: int,
    ingrediente_in: ProductoIngredienteBase,
    db: Session = Depends(get_db)
):
    """
    Añade un ingrediente a un producto con su cantidad necesaria.
    
    Validaciones:
    - Producto debe existir y estar activo
    - Ingrediente debe existir y estar activo
    - Cantidad debe ser > 0
    - No puede añadir el mismo ingrediente dos veces
    
    Body:
    {
        "ingrediente_id": 1,
        "cantidad_necesaria": 0.2
    }
    """
    return producto_service.add_ingrediente_to_producto(
        db,
        producto_id,
        ingrediente_in.ingrediente_id,
        ingrediente_in.cantidad_necesaria
    )


@router.put("/{producto_id}/ingredientes/{ingrediente_id}")
def actualizar_cantidad_ingrediente(
    producto_id: int,
    ingrediente_id: int,
    cantidad: Decimal,
    db: Session = Depends(get_db)
):
    """
    Actualiza la cantidad necesaria de un ingrediente en un producto.
    
    Validaciones:
    - La relación producto-ingrediente debe existir
    - Cantidad debe ser > 0
    
    Body:
    {
        "cantidad": 0.5
    }
    """
    if cantidad <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La cantidad debe ser mayor a 0"
        )
    
    resultado = producto_service.update_cantidad_ingrediente(
        db,
        producto_id,
        ingrediente_id,
        cantidad
    )
    
    if not resultado:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Relación producto-ingrediente no encontrada"
        )
    
    return resultado


@router.delete("/{producto_id}/ingredientes/{ingrediente_id}", status_code=status.HTTP_204_NO_CONTENT)
def quitar_ingrediente_de_producto(
    producto_id: int,
    ingrediente_id: int,
    db: Session = Depends(get_db)
):
    """
    Elimina un ingrediente de un producto.
    
    Validaciones:
    - La relación debe existir
    - Un producto debe tener al menos 1 ingrediente (no se puede eliminar el último)
    """
    eliminado = producto_service.remove_ingrediente_from_producto(
        db,
        producto_id,
        ingrediente_id
    )
    
    if not eliminado:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Relación producto-ingrediente no encontrada"
        )
    
    return None