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
    DisponibilidadDetalleResponse,
    ProductSearchFilters,
    ProductSearchResponse
)

# Imports de servicios
from backend.services import producto_service, disponibilidad_service, product_search_service

# Import de dependencia de BD
from backend.database_manager.database import get_db

# Import de middleware de roles
from backend.middleware.auth_middleware import RequireRole

# Router
router = APIRouter(prefix="/productos", tags=["productos"])


# ============================================================================
# ENDPOINTS DE LISTADO Y CONSULTA - sin restricción de rol
# ============================================================================

@router.get("/", response_model=List[ProductoResponse])
def listar_productos(
    skip: int = Query(0, ge=0, description="Número de registros a saltar"),
    limit: int = Query(100, ge=1, le=100, description="Límite de registros"),
    categoria: Optional[str] = Query(None, description="Filtrar por categoría"),
    db: Session = Depends(get_db)
):
    """Lista todos los productos activos con su disponibilidad."""
    return producto_service.get_productos(db, skip, limit, categoria)


@router.get("/disponibles", response_model=List[ProductoResponse])
def listar_productos_disponibles(
    categoria: Optional[str] = Query(None, description="Filtrar por categoría"),
    db: Session = Depends(get_db)
):
    """Lista solo productos que tienen stock disponible."""
    return disponibilidad_service.get_productos_disponibles(db, categoria)


@router.get("/search", response_model=ProductSearchResponse)
def buscar_productos(
    filters: ProductSearchFilters = Depends(),
    current_role: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """Búsqueda avanzada con filtros, texto libre e ingredientes."""
    if current_role == "cliente" or current_role is None:
        filters.active_only = True
    return product_search_service.search_products(db, filters)


@router.get("/{producto_id}", response_model=ProductoDetalleResponse)
def obtener_producto(
    producto_id: int,
    db: Session = Depends(get_db)
):
    """Obtiene el detalle completo de un producto con información de ingredientes."""
    producto = producto_service.get_producto_con_ingredientes(db, producto_id)
    if not producto:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return producto


@router.get("/{producto_id}/disponibilidad", response_model=DisponibilidadDetalleResponse)
def obtener_disponibilidad_detallada(
    producto_id: int,
    db: Session = Depends(get_db)
):
    """Obtiene análisis detallado de disponibilidad de un producto."""
    detalle = disponibilidad_service.get_detalle_disponibilidad(db, producto_id)
    if not detalle:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return detalle


# ============================================================================
# ENDPOINTS DE CREACIÓN Y MODIFICACIÓN - requieren rol
# ============================================================================

@router.post("/", response_model=ProductoResponse, status_code=status.HTTP_201_CREATED)
def crear_producto(
    producto_in: ProductoCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Crea un nuevo producto."""
    RequireRole(["admin", "almacen", "dependiente"])
    producto_data = producto_in.dict()
    return producto_service.create_producto(db, producto_data)


@router.put("/{producto_id}", response_model=ProductoResponse)
def actualizar_producto(
    producto_id: int,
    producto_in: ProductoUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Actualiza un producto existente."""
    RequireRole(["admin", "almacen", "dependiente"])
    producto_data = {k: v for k, v in producto_in.dict().items() if v is not None}
    if not producto_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No se proporcionaron campos para actualizar")
    resultado = producto_service.update_producto(db, producto_id, producto_data)
    if not resultado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return resultado


@router.delete("/{producto_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_producto(
    producto_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Elimina un producto (soft delete)."""
    RequireRole(["admin", "almacen", "dependiente"])
    if not producto_service.delete_producto(db, producto_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return None


@router.patch("/{producto_id}/categories")
def actualizar_categorias_producto(
    producto_id: int,
    category_ids: List[int],
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Asigna o actualiza las categorías de un producto."""
    RequireRole(["admin", "almacen", "dependiente"])
    return producto_service.update_product_categories(db, producto_id, category_ids)


# ============================================================================
# ENDPOINTS DE GESTIÓN DE INGREDIENTES - requieren rol
# ============================================================================

@router.post("/{producto_id}/ingredientes", status_code=status.HTTP_201_CREATED)
def añadir_ingrediente_a_producto(
    producto_id: int,
    ingrediente_in: ProductoIngredienteBase,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Añade un ingrediente a un producto con su cantidad necesaria."""
    RequireRole(["admin", "almacen", "dependiente"])
    return producto_service.add_ingrediente_to_producto(
        db, producto_id, ingrediente_in.ingrediente_id, ingrediente_in.cantidad_necesaria
    )


@router.put("/{producto_id}/ingredientes/{ingrediente_id}")
def actualizar_cantidad_ingrediente(
    producto_id: int,
    ingrediente_id: int,
    cantidad: Decimal,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Actualiza la cantidad necesaria de un ingrediente en un producto."""
    RequireRole(["admin", "almacen", "dependiente"])
    if cantidad <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La cantidad debe ser mayor a 0")
    resultado = producto_service.update_cantidad_ingrediente(db, producto_id, ingrediente_id, cantidad)
    if not resultado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Relación producto-ingrediente no encontrada")
    return resultado


@router.delete("/{producto_id}/ingredientes/{ingrediente_id}", status_code=status.HTTP_204_NO_CONTENT)
def quitar_ingrediente_de_producto(
    producto_id: int,
    ingrediente_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Elimina un ingrediente de un producto."""
    RequireRole(["admin", "almacen", "dependiente"])
    if not producto_service.remove_ingrediente_from_producto(db, producto_id, ingrediente_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Relación producto-ingrediente no encontrada")
    return None
