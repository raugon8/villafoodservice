from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from database_manager.database import get_db
from object_class.users import UserWithRoles, UserCreateAdmin, UserUpdate
from middleware.auth_middleware import RequireRole
from services import user_service # Servicio que hara Adan

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

@router.get("/me/roles")
def GetUserRoles(user_id: int, db: Session = Depends(get_db)):
    """Cualquier usuario puede ver sus propios roles"""
    return user_service.obtener_roles_usuario(db, user_id)

@router.get("/", response_model=List[UserWithRoles])
@RequireRole(["admin"])
def ListUsers(skip: int = 0, limit: int = 100, search: str = None, db: Session = Depends(get_db)):
    """Solo el admin lista todos los usuarios"""
    return user_service.listar_usuarios(db, skip, limit, search)

@router.post("/", response_model=UserWithRoles, status_code=201)
@RequireRole(["admin"])
def CreateUserByAdmin(user_data: UserCreateAdmin, db: Session = Depends(get_db)):
    """Creacion manual de usuarios por parte del administrador"""
    return user_service.crear_usuario_admin(db, user_data)

@router.patch("/{usuario_id}", response_model=UserWithRoles)
@RequireRole(["admin"])
def UpdateUser(usuario_id: int, user_data: UserUpdate, db: Session = Depends(get_db)):
    """Actualizacion de datos y roles por el administrador"""
    return user_service.actualizar_usuario(db, usuario_id, user_data)