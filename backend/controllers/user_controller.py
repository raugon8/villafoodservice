"""
User Controller
REST endpoints for user and role management
backend/controllers/user_controller.py
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from backend.object_class.users import UserWithRoles, UserCreateAdmin, UserUpdate
from backend.middleware.auth_middleware import RequireRole
from backend.services import user_service
from backend.database_manager.database import get_db

router = APIRouter(prefix="/usuarios", tags=["usuarios"])


@router.get("/me/roles")
def get_user_roles(user_id: int, db: Session = Depends(get_db)):
    """Any user can see their own roles"""
    return {"roles": user_service.obtener_roles_usuario(db, user_id)}


@router.get("/", response_model=List[UserWithRoles])
def list_users(
    user_id: int = Query(...),
    current_role: str = Query(...),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """Admin only: list all users"""
    RequireRole(["admin"])
    return user_service.listar_usuarios(db, skip, limit, search)


@router.get("/{usuario_id}", response_model=UserWithRoles)
def get_user_by_id(
    usuario_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Admin only: get user by ID"""
    RequireRole(["admin"])
    return user_service.obtener_usuario_por_id(db, usuario_id)


@router.post("/", response_model=UserWithRoles, status_code=201)
def create_user_by_admin(
    user_data: UserCreateAdmin,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Admin only: create new user with roles"""
    RequireRole(["admin"])
    return user_service.crear_usuario_admin(db, user_data)


@router.patch("/{usuario_id}", response_model=UserWithRoles)
def update_user(
    usuario_id: int,
    user_data: UserUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Admin only: update user data and roles"""
    RequireRole(["admin"])
    return user_service.actualizar_usuario(db, usuario_id, user_data)


@router.delete("/{usuario_id}")
def deactivate_user(
    usuario_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Admin only: deactivate user"""
    RequireRole(["admin"])
    return user_service.desactivar_usuario(db, usuario_id)


@router.patch("/{usuario_id}/roles", response_model=UserWithRoles)
def update_user_roles(
    usuario_id: int,
    roles_data: dict,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Admin only: update user roles"""
    RequireRole(["admin"])
    return user_service.actualizar_roles_usuario(db, usuario_id, roles_data.get("roles", []))