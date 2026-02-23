"""
User Service
Business logic for user and role management
backend/services/user_service.py
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from passlib.context import CryptContext

from backend.models.user_model import User
from backend.models.role_model import RoleModel, UserRoleModel
from backend.object_class.users import UserCreateAdmin, UserUpdate

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ============================================================================
# HELPER
# ============================================================================

def _build_user_response(db: Session, user: User) -> dict:
    """Builds UserWithRoles dict from User object"""
    active_roles = db.query(RoleModel).join(UserRoleModel).filter(
        UserRoleModel.user_id == user.usuario_ID,
        UserRoleModel.role_active == True
    ).all()

    return {
        "user_id":     user.usuario_ID,
        "user_name":   user.nombre_usuario,
        "user_email":  user.correo,
        "roles":       [r.role_name for r in active_roles],
        "user_active": True
    }


# ============================================================================
# FUNCTION 1: Get user roles
# ============================================================================

def obtener_roles_usuario(db: Session, user_id: int) -> List[str]:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    active_roles = db.query(RoleModel).join(UserRoleModel).filter(
        UserRoleModel.user_id == user_id,
        UserRoleModel.role_active == True
    ).all()

    return [r.role_name for r in active_roles]


# ============================================================================
# FUNCTION 2: List users
# ============================================================================

def listar_usuarios(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    busqueda: Optional[str] = None
) -> List[dict]:
    query = db.query(User)

    if busqueda:
        query = query.filter(
            User.nombre_usuario.ilike(f"%{busqueda}%") |
            User.correo.ilike(f"%{busqueda}%")
        )

    users = query.order_by(User.usuario_ID.asc()).offset(skip).limit(limit).all()
    return [_build_user_response(db, u) for u in users]


# ============================================================================
# FUNCTION 3: Get user by ID
# ============================================================================

def obtener_usuario_por_id(db: Session, user_id: int) -> dict:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")
    return _build_user_response(db, user)


# ============================================================================
# FUNCTION 4: Create user (admin)
# ============================================================================

def crear_usuario_admin(db: Session, usuario_data: UserCreateAdmin) -> dict:
    existing = db.query(User).filter(User.correo == usuario_data.usuario_email).first()
    if existing:
        raise ValueError(f"Email '{usuario_data.usuario_email}' ya está registrado")

    try:
        hashed = pwd_context.hash(usuario_data.usuario_password)
        new_user = User(
            nombre_usuario = usuario_data.usuario_name + " " + usuario_data.usuario_surname,
            correo         = usuario_data.usuario_email,
            contraseña     = hashed
        )
        db.add(new_user)
        db.flush()  # get new user ID without committing

        for role_name in usuario_data.roles:
            role = db.query(RoleModel).filter(
                RoleModel.role_name == role_name,
                RoleModel.role_active == True
            ).first()
            if not role:
                raise ValueError(f"Rol '{role_name}' no existe o no está activo")

            db.add(UserRoleModel(
                user_id     = new_user.usuario_ID,
                role_id     = role.role_id,
                role_active = True
            ))

        db.commit()
        return _build_user_response(db, new_user)

    except Exception:
        db.rollback()
        raise


# ============================================================================
# FUNCTION 5: Update user
# ============================================================================

def actualizar_usuario(db: Session, user_id: int, usuario_data: UserUpdate) -> dict:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    if usuario_data.usuario_name or usuario_data.usuario_surname:
        name    = usuario_data.usuario_name or user.nombre_usuario.split()[0]
        surname = usuario_data.usuario_surname or ""
        user.nombre_usuario = f"{name} {surname}".strip()

    if usuario_data.usuario_email:
        user.correo = usuario_data.usuario_email

    if usuario_data.usuario_password:
        user.contraseña = pwd_context.hash(usuario_data.usuario_password)

    if usuario_data.roles is not None:
        # deactivate all current roles
        db.query(UserRoleModel).filter(UserRoleModel.user_id == user_id).update(
            {"role_active": False}
        )
        # assign new roles
        for role_name in usuario_data.roles:
            role = db.query(RoleModel).filter(RoleModel.role_name == role_name).first()
            if not role:
                raise ValueError(f"Rol '{role_name}' no existe")

            existing = db.query(UserRoleModel).filter(
                UserRoleModel.user_id == user_id,
                UserRoleModel.role_id == role.role_id
            ).first()

            if existing:
                existing.role_active = True
            else:
                db.add(UserRoleModel(
                    user_id=user_id, role_id=role.role_id, role_active=True
                ))

    db.commit()
    return _build_user_response(db, user)


# ============================================================================
# FUNCTION 6: Deactivate user
# ============================================================================

def desactivar_usuario(db: Session, user_id: int) -> dict:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    if user.correo == "root@villafoodservice.com":
        raise ValueError("No se puede desactivar el usuario Root")

    # deactivate all roles
    db.query(UserRoleModel).filter(UserRoleModel.user_id == user_id).update(
        {"role_active": False}
    )
    db.commit()
    return {"message": f"Usuario {user_id} desactivado correctamente"}


# ============================================================================
# FUNCTION 7: Update user roles
# ============================================================================

def actualizar_roles_usuario(db: Session, user_id: int, nuevos_roles: List[str]) -> dict:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    # deactivate all current roles
    db.query(UserRoleModel).filter(UserRoleModel.user_id == user_id).update(
        {"role_active": False}
    )

    for role_name in nuevos_roles:
        role = db.query(RoleModel).filter(
            RoleModel.role_name == role_name,
            RoleModel.role_active == True
        ).first()
        if not role:
            raise ValueError(f"Rol '{role_name}' no existe o no está activo")

        existing = db.query(UserRoleModel).filter(
            UserRoleModel.user_id == user_id,
            UserRoleModel.role_id == role.role_id
        ).first()

        if existing:
            existing.role_active = True
        else:
            db.add(UserRoleModel(
                user_id=user_id, role_id=role.role_id, role_active=True
            ))

    db.commit()
    return _build_user_response(db, user)