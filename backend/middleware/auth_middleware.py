from fastapi import HTTPException, status
from functools import wraps
from database_manager.database import SessionLocal
from models.role_model import RoleModel, UserRoleModel


def RequireRole(allowed_roles: list):
    #Decorador para restringir acceso segun el rol

    def Decorator(func):
        @wraps(func)
        async def Wrapper(*args, **kwargs):
            # Obtenemos datos de la request (esto cambiara a JWT mas adelante)
            user_id = kwargs.get("user_id")
            current_role = kwargs.get("current_role")

            if not user_id or not current_role:
                raise HTTPException(status_code=401, detail="Credenciales no proporcionadas")

            db = SessionLocal()
            try:
                # Consulta para verificar si el usuario tiene el rol activo
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