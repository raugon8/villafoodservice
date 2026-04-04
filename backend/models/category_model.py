from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import bcrypt
from backend.database_manager.database import get_db
from backend.models.user_model import User
from backend.models.role_model import RoleModel, UserRoleModel
from pydantic import BaseModel

# Agrupa los endpoints de autenticación. Se registra en main.py con include_router.
router = APIRouter()

# Ya no usamos pwd_context de passlib. Usaremos bcrypt directamente en las rutas.

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

    # Hasheamos la contraseña con bcrypt directamente
    password_bytes = user_data.contraseña.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password_bytes, salt).decode('utf-8')

    new_user = User(
        nombre_usuario = user_data.nombre_usuario,
        correo         = user_data.correo,
        contraseña     = hashed_password
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

    # Verifica la contraseña con bcrypt directamente, si falla porque hay usuarios con contraseña en texto plano, compara directamente.
    try:
        plain_bytes = user_data.contraseña.encode('utf-8')
        hash_bytes = user.contraseña.encode('utf-8')
        password_ok = bcrypt.checkpw(plain_bytes, hash_bytes)
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