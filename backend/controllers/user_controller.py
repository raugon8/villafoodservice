from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from backend.object_class.users import UserWithRoles, UserCreateAdmin, UserUpdate
from backend.middleware.auth_middleware import RequireRole
from backend.services import user_service
from backend.database_manager.database import get_db

router = APIRouter(prefix="/usuarios", tags=["usuarios"])


# Endpoint sin restricción de rol, cualquier usuario ve sus roles.
# El frontend lo usa tras el login para saber a qué pantallas tiene acceso.
@router.get("/me/roles")
def get_user_roles(user_id: int, db: Session = Depends(get_db)):
    """Devuelve los roles activos del usuario indicado."""
    return {"roles": user_service.obtener_roles_usuario(db, user_id)}


# El resto de endpoints son exclusivos del admin.
@router.get("/", response_model=List[UserWithRoles])
def list_users(
    user_id: int = Query(...),
    current_role: str = Query(...),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """Lista todos los usuarios del sistema."""
    RequireRole(["admin"])
    return user_service.listar_usuarios(db, skip, limit, search)


@router.get("/{usuario_id}", response_model=UserWithRoles)
def get_user_by_id(
    usuario_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Obtiene un usuario por su ID."""
    RequireRole(["admin"])
    return user_service.obtener_usuario_por_id(db, usuario_id)


@router.post("/", response_model=UserWithRoles, status_code=201)
def create_user_by_admin(
    user_data: UserCreateAdmin,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Crea un nuevo usuario con sus roles asignados."""
    RequireRole(["admin"])
    return user_service.crear_usuario_admin(db, user_data)


# Actualiza datos personales (nombre, correo, contraseña).
@router.patch("/{usuario_id}", response_model=UserWithRoles)
def update_user(
    usuario_id: int,
    user_data: UserUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Actualiza los datos personales de un usuario."""
    RequireRole(["admin"])
    return user_service.actualizar_usuario(db, usuario_id, user_data)


@router.delete("/{usuario_id}")
def deactivate_user(
    usuario_id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Desactiva un usuario (desactiva sus roles, no borra el registro)."""
    RequireRole(["admin"])
    return user_service.desactivar_usuario(db, usuario_id)


# Este endpoint actualiza exclusivamente los roles del usuario.
@router.patch("/{usuario_id}/roles", response_model=UserWithRoles)
def update_user_roles(
    usuario_id: int,
    roles_data: dict,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Reemplaza los roles activos del usuario por los nuevos indicados."""
    RequireRole(["admin"])
    return user_service.actualizar_roles_usuario(db, usuario_id, roles_data.get("roles", []))