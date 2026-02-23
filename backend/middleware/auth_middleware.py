from fastapi import HTTPException
from functools import wraps
from backend.database_manager.database import SessionLocal
from backend.models.role_model import RoleModel, UserRoleModel


def RequireRole(allowed_roles: list):
    """Decorator to restrict access based on user role"""

    def Decorator(func):
        @wraps(func)
        async def Wrapper(*args, **kwargs):
            # Get data from request (will change to JWT later)
            user_id      = kwargs.get("user_id")
            current_role = kwargs.get("current_role")

            if not user_id or not current_role:
                raise HTTPException(status_code=401, detail="Credenciales no proporcionadas")

            db = SessionLocal()
            try:
                has_access = db.query(RoleModel).join(UserRoleModel).filter(
                    UserRoleModel.user_id == user_id,
                    RoleModel.role_name == current_role,
                    UserRoleModel.role_active == True,
                    RoleModel.role_name.in_(allowed_roles)
                ).first()

                if not has_access:
                    raise HTTPException(status_code=403, detail="No tienes permisos para esta accion")
            finally:
                db.close()

            return await func(*args, **kwargs)

        return Wrapper

    return Decorator