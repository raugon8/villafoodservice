from fastapi import HTTPException, Request
from functools import wraps
import jwt

# Configuracion del cifrado JWT — debe coincidir con auth_controller.py
SECRET_KEY = "VillaFood_Super_Secret_Key_Change_Me_Later"
ALGORITHM = "HS256"

# Decorador que restringe el acceso a un endpoint segun el rol del usuario.
# Se usa encima de las funciones de los controllers: RequireRole(["admin", "dependiente"])
# Verifica el token JWT del header Authorization: Bearer <token>
def RequireRole(allowed_roles: list):
    def Decorator(func):
        @wraps(func)
        async def Wrapper(*args, **kwargs):
            # Intentamos obtener el token JWT del header Authorization
            request: Request = kwargs.get("request")

            token = None
            if request:
                auth_header = request.headers.get("Authorization", "")
                if auth_header.startswith("Bearer "):
                    token = auth_header[7:]

            if token:
                # --- VERIFICACION POR TOKEN JWT (nuevo sistema seguro) ---
                try:
                    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
                    token_roles = payload.get("roles", [])
                except jwt.ExpiredSignatureError:
                    raise HTTPException(status_code=401, detail="El token ha expirado. Vuelve a iniciar sesión.")
                except jwt.PyJWTError:
                    raise HTTPException(status_code=401, detail="Token inválido o manipulado.")

                if not any(role in allowed_roles for role in token_roles):
                    raise HTTPException(status_code=403, detail="No tienes permisos para esta acción.")

            else:
                # --- VERIFICACION POR QUERY PARAMS (sistema anterior, compatibilidad) ---
                # Permite que el sistema siga funcionando mientras el frontend migra al token
                user_id      = kwargs.get("user_id")
                current_role = kwargs.get("current_role")

                if not user_id or not current_role:
                    raise HTTPException(status_code=401, detail="Credenciales no proporcionadas")

                if current_role not in allowed_roles:
                    raise HTTPException(status_code=403, detail="No tienes permisos para esta acción.")

            return await func(*args, **kwargs)
        return Wrapper
    return Decorator