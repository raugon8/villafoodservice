from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt

# Configuración del Cifrado (Debe coincidir con auth_controller.py)
SECRET_KEY = "VillaFood_Super_Secret_Key_Change_Me_Later"
ALGORITHM = "HS256"

# Le dice a FastAPI que busque el token en el Header "Authorization: Bearer <token>"
security = HTTPBearer()

def RequireRole(allowed_roles: list):
    """
    Dependencia de FastAPI que intercepta la petición, verifica el token JWT,
    comprueba los permisos y devuelve el user_id de forma segura.
    """
    def role_checker(credentials: HTTPAuthorizationCredentials = Security(security)) -> int:
        token = credentials.credentials
        try:
            # Desencriptamos el token. Si fue alterado, esto lanza un error automáticamente.
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id = int(payload.get("sub"))
            token_roles = payload.get("roles", [])
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="El token ha expirado. Vuelve a iniciar sesión.")
        except jwt.PyJWTError:
            raise HTTPException(status_code=401, detail="Token inválido o manipulado.")

        # Verificamos si el usuario tiene al menos un rol de los permitidos para esta ruta
        if not any(role in allowed_roles for role in token_roles):
            raise HTTPException(status_code=403, detail="No tienes permisos para esta acción.")

        # Devolvemos el ID real y verificado.
        return user_id

    return role_checker