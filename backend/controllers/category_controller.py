from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from backend.database_manager.database import get_db
from backend.object_class.category import CategoryResponse, CategoryCreate, CategoryUpdate
from backend.middleware.auth_middleware import RequireRole
from backend.services import category_service

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("/", response_model=List[CategoryResponse])
def ListCategories(active_only: bool = True, db: Session = Depends(get_db)):
    """Lista todas las categorías disponibles"""
    return category_service.list_categories(db, active_only)


@router.get("/{category_id}", response_model=CategoryResponse)
def GetCategory(category_id: int, db: Session = Depends(get_db)):
    """Obtiene una categoría por ID"""
    return category_service.get_category_by_id(db, category_id)


@router.post("/", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
def CreateCategory(
    category_in: CategoryCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Crea una nueva categoría (Solo Admin)"""
    RequireRole(["admin"])
    return category_service.create_category(db, category_in)


@router.patch("/{category_id}", response_model=CategoryResponse)
def UpdateCategory(
    category_id: int,
    category_in: CategoryUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Actualiza una categoría existente (Solo Admin)"""
    RequireRole(["admin"])
    return category_service.update_category(db, category_id, category_in)


@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
def DeactivateCategory(
    category_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Desactiva una categoría (Soft delete)"""
    RequireRole(["admin"])
    category_service.deactivate_category(db, category_id)
    return None