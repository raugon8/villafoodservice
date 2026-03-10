from fastapi import HTTPException
from functools import wraps
from backend.database_manager.database import SessionLocal
from backend.models.role_model import RoleModel, UserRoleModel

# Decorador que restringe el acceso a un endpoint según el rol del usuario.
# Se usa encima de las funciones de los controllers: @RequireRole(["admin", "dependiente"])
def RequireRole(allowed_roles: list):
    def Decorator(func):
        @wraps(func)
        async def Wrapper(*args, **kwargs):
            # Obtener user_id y rol activo de los query params de la petición
            user_id      = kwargs.get("user_id")
            current_role = kwargs.get("current_role")

            if not user_id or not current_role:
                raise HTTPException(status_code=401, detail="Credenciales no proporcionadas")

            db = SessionLocal()
            try:
                # Verificar que el usuario tiene el rol activo y que ese rol está entre los permitidos
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