from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from database_manager.database import get_db
from object_class.category import CategoryResponse, CategoryCreate, CategoryUpdate
from middleware.auth_middleware import RequireRole
from services import category_service # Servicio de Adan

router = APIRouter(prefix="/categories", tags=["categories"])

@router.get("/", response_model=List[CategoryResponse])
def ListCategories(active_only: bool = True, db: Session = Depends(get_db)):
    """Lista todas las categorias disponibles"""
    return category_service.list_categories(db, active_only)

@router.post("/", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
@RequireRole(["admin"])
def CreateCategory(category_in: CategoryCreate, user_id: int, current_role: str, db: Session = Depends(get_db)):
    """Crea una nueva categoria (Solo Admin)"""
    return category_service.create_category(db, category_in)

@router.patch("/{category_id}", response_model=CategoryResponse)
@RequireRole(["admin"])
def UpdateCategory(category_id: int, category_in: CategoryUpdate, user_id: int, current_role: str, db: Session = Depends(get_db)):
    """Actualiza una categoria existente (Solo Admin)"""
    return category_service.update_category(db, category_id, category_in)

@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
@RequireRole(["admin"])
def DeactivateCategory(category_id: int, user_id: int, current_role: str, db: Session = Depends(get_db)):
    """Desactiva una categoria (Soft delete)"""
    category_service.deactivate_category(db, category_id)
    return None