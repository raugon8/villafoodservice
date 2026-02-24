from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from backend.database_manager.database import get_db
from backend.object_class.products import ProductResponse, ProductCreate, ProductUpdate, ProductIngredientBase
from backend.services import product_service
from backend.middleware.auth_middleware import RequireRole

router = APIRouter(prefix="/productos", tags=["productos"])


@router.get("/", response_model=List[ProductResponse])
def GetAllProducts(
    skip: int = 0,
    limit: int = 100,
    category: str = None,
    db: Session = Depends(get_db)
):
    # Catálogo público - sin restricción de rol
    return product_service.get_all_products(db, skip, limit, category)


@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def CreateProduct(
    product_in: ProductCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    return product_service.create_product(db, product_in)


@router.put("/{id}", response_model=ProductResponse)
def UpdateProduct(
    id: int,
    product_in: ProductUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    updated_product = product_service.update_product(db, id, product_in)
    if not updated_product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return updated_product


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def DeleteProduct(
    id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    if not product_service.delete_product(db, id):
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return None


@router.post("/{id}/ingredients", status_code=status.HTTP_201_CREATED)
def AddIngredientToProduct(
    id: int,
    ingredient_in: ProductIngredientBase,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    return product_service.add_ingredient(db, id, ingredient_in)