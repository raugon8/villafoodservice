from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from backend.database_manager.database import get_db
from backend.models.user_model import User
from backend.models.role_model import RoleModel, UserRoleModel
from pydantic import BaseModel

# Agrupa los endpoints de autenticación. Se registra en main.py con include_router.
router = APIRouter()

# Gestor de cifrado de contraseñas con bcrypt (contraseñas no se guardan en texto plano)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# Schema para el registro: nombre, correo y contraseña.
class UserCreate(BaseModel):
    nombre_usuario: str
    correo: str
    contraseña: str


# Schema para el login: solo necesita correo y contraseña.
class UserLogin(BaseModel):
    correo: str
    contraseña: str


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existe = db.query(User).filter(User.correo == user_data.correo).first()
    if existe:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    new_user = User(
        nombre_usuario = user_data.nombre_usuario,
        correo         = user_data.correo,
        contraseña     = pwd_context.hash(user_data.contraseña)
    )
    db.add(new_user)
    # flush() envía el INSERT a la BD sin confirmar, para generar el usuario_id al que se le asignará el rol.
    db.flush()

    # Todo usuario registrado recibe el rol 'cliente' por defecto.
    cliente_role = db.query(RoleModel).filter(RoleModel.role_name == "cliente").first()
    if cliente_role:
        db.add(UserRoleModel(
            user_id     = new_user.usuario_id,
            role_id     = cliente_role.role_id,
            role_active = True
        ))

    db.commit()
    db.refresh(new_user)

    return {
        "usuario_id":     new_user.usuario_id,
        "nombre_usuario": new_user.nombre_usuario,
        "correo":         new_user.correo,
        "roles":          ["cliente"]
    }


@router.post("/login", status_code=status.HTTP_200_OK)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.correo == user_data.correo).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    # Verifica la contraseña con bcryp, si falla porque hay usuarios con contraseña en texto plano, compara directamente.
    try:
        password_ok = pwd_context.verify(user_data.contraseña, user.contraseña)
    except Exception:
        password_ok = (user.contraseña == user_data.contraseña)

    if not password_ok:
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    # Obtiene los roles activos del usuario para devolverlos al frontend.
    active_roles = db.query(RoleModel).join(UserRoleModel).filter(
        UserRoleModel.user_id == user.usuario_id,
        UserRoleModel.role_active == True
    ).all()

    return {
        "usuario_id":     user.usuario_id,
        "nombre_usuario": user.nombre_usuario,
        "correo":         user.correo,
        "roles":          [r.role_name for r in active_roles]
    }