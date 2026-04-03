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
    """Construye el listado de respuesta de un usuario con sus roles activos.
    Se reutiliza en todas las funciones que devuelven un usuario."""
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
# FUNCION 1: Obtener roles de usuario
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
# FUNCION 2: Listar usuarios
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
# FUNCION 3: Obtener usuario por ID
# ============================================================================

def obtener_usuario_por_id(db: Session, user_id: int) -> dict:
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")
    return _build_user_response(db, user)


# ============================================================================
# FUNCION 4: Crear usuario (admin)
# ============================================================================

def crear_usuario_admin(db: Session, usuario_data: UserCreateAdmin) -> dict:
    """Crea un usuario con sus roles asignados.
    Usa flush() para obtener el usuario_ID antes del commit, necesario para asignar los roles.
    Usa rollback() porque crea usuario y roles en operaciones largas."""
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
        # flush() genera el usuario_ID sin confirmar, necesario para asignar los roles a continuación.
        db.flush()

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
# FUNCION 5: Actualizar usuario
# ============================================================================

def actualizar_usuario(db: Session, user_id: int, usuario_data: UserUpdate) -> dict:
    """Actualiza datos personales y/o roles de un usuario.
    Para los roles: desactiva todos los actuales y reactiva o crea los nuevos; preserva la fecha de asignación original."""
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
        # Desactiva todos los roles actuales antes de asignar los nuevos.
        db.query(UserRoleModel).filter(UserRoleModel.user_id == user_id).update(
            {"role_active": False}
        )
        # Reactiva o crea los nuevos roles.
        for role_name in usuario_data.roles:
            role = db.query(RoleModel).filter(RoleModel.role_name == role_name).first()
            if not role:
                raise ValueError(f"Rol '{role_name}' no existe")

            existing = db.query(UserRoleModel).filter(
                UserRoleModel.user_id == user_id,
                UserRoleModel.role_id == role.role_id
            ).first()

            if existing:
                # Reactiva el rol si ya existía para preservar la fecha de asignación original.
                existing.role_active = True
            else:
                db.add(UserRoleModel(
                    user_id=user_id, role_id=role.role_id, role_active=True
                ))

    db.commit()
    return _build_user_response(db, user)


# ============================================================================
# FUNCION 6: Deactivar Usuario
# ============================================================================

def desactivar_usuario(db: Session, user_id: int) -> dict:
    """Desactiva un usuario desactivando todos sus roles.
    El usuario root no puede desactivarse para evitar quedarse sin administrador."""
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    if user.correo == "root@villafoodservice.com":
        raise ValueError("No se puede desactivar el usuario Root")

    # Desactiva todos los roles del usuario (soft delete de roles).
    db.query(UserRoleModel).filter(UserRoleModel.user_id == user_id).update(
        {"role_active": False}
    )
    db.commit()
    return {"message": f"Usuario {user_id} desactivado correctamente"}


# ============================================================================
# FUNCION 7: Actualizar roles de usuario
# ============================================================================

def actualizar_roles_usuario(db: Session, user_id: int, nuevos_roles: List[str]) -> dict:
    """Reemplaza los roles activos de un usuario por los nuevos indicados.
    Desactiva todos los roles actuales y reactiva o crea los nuevos,
    preserva la fecha de asignación original si el rol ya existía."""
    user = db.query(User).filter(User.usuario_ID == user_id).first()
    if not user:
        raise ValueError(f"Usuario {user_id} no encontrado")

    # Desactiva todos los roles actuales antes de asignar los nuevos.
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
            # Reactiva el rol si ya existía para preservar la fecha de asignación original.
            existing.role_active = True
        else:
            db.add(UserRoleModel(
                user_id=user_id, role_id=role.role_id, role_active=True
            ))

    db.commit()
    return _build_user_response(db, user)