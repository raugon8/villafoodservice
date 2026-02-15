from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from database_manager.database import get_db
from object_class.products import (ProductResponse, ProductCreate, ProductUpdate,ProductIngredientBase, ProductSearchFilters, ProductSearchResponse)
from middleware.auth_middleware import RequireRole
from services import product_service, product_search_service

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/", response_model=List[ProductResponse])
def GetAllProducts(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Lista basica de productos con paginacion"""
    return product_service.get_all_products(db, skip, limit, category)

@router.get("/search", response_model=ProductSearchResponse)
def SearchProducts(
    filters: ProductSearchFilters = Depends(),
    current_role: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Busqueda avanzada con filtros, ingredientes y ordenamiento"""
    # Si el usuario es cliente o no esta identificado, solo ve productos activos
    if current_role == "cliente" or current_role is None:
        filters.active_only = True

    return product_search_service.search_products(db, filters)

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
@RequireRole(["admin", "almacen", "dependiente"])
def CreateProduct(
    product_in: ProductCreate,
    user_id: int,
    current_role: str,
    db: Session = Depends(get_db)
):
    """Crea un nuevo producto (Requiere rol administrativo)"""
    return product_service.create_product(db, product_in)

@router.put("/{id}", response_model=ProductResponse)
@RequireRole(["admin", "almacen", "dependiente"])
def UpdateProduct(
    id: int,
    product_in: ProductUpdate,
    user_id: int,
    current_role: str,
    db: Session = Depends(get_db)
):
    """Actualiza datos de un producto existente"""
    updated_product = product_service.update_product(db, id, product_in)
    if not updated_product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return updated_product

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
@RequireRole(["admin", "almacen", "dependiente"])
def DeleteProduct(
    id: int,
    user_id: int,
    current_role: str,
    db: Session = Depends(get_db)
):
    """Realiza un borrado logico del producto"""
    if not product_service.delete_product(db, id):
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return None

# --- Gestion de Ingredientes y Categorias ---

@router.post("/{id}/ingredients", status_code=status.HTTP_201_CREATED)
@RequireRole(["admin", "almacen", "dependiente"])
def AddIngredientToProduct(
    id: int,
    ingredient_in: ProductIngredientBase,
    user_id: int,
    current_role: str,
    db: Session = Depends(get_db)
):
    """Añade un ingrediente a la receta del producto"""
    return product_service.add_ingredient(db, id, ingredient_in)

@router.patch("/{id}/categories")
@RequireRole(["admin", "almacen", "dependiente"])
def UpdateProductCategories(
    id: int,
    category_ids: List[int],
    user_id: int,
    current_role: str,
    db: Session = Depends(get_db)
):
    """Asigna o actualiza las categorias del producto"""
    return product_service.update_product_categories(db, id, category_ids)