from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import bcrypt
import jwt
from datetime import datetime, timedelta
from backend.database_manager.database import get_db
from backend.models.user_model import User
from backend.models.role_model import RoleModel, UserRoleModel
from pydantic import BaseModel, validator

# Configuración del Cifrado
SECRET_KEY = "VillaFood_Super_Secret_Key_Change_Me_Later"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # El token durará 7 días

router = APIRouter()


class UserCreate(BaseModel):
    nombre_usuario: str
    correo: str
    contraseña: str

    @validator('contraseña')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('La contraseña debe tener al menos 8 caracteres')
        if not any(char.isdigit() for char in v):
            raise ValueError('La contraseña debe contener al menos un número')
        if not any(char.isupper() for char in v):
            raise ValueError('La contraseña debe contener al menos una letra mayúscula')
        if not any(char.islower() for char in v):
            raise ValueError('La contraseña debe contener al menos una letra minúscula')
        return v


class UserLogin(BaseModel):
    correo: str
    contraseña: str


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existe = db.query(User).filter(User.correo == user_data.correo).first()
    if existe:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    password_bytes = user_data.contraseña.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password_bytes, salt).decode('utf-8')

    new_user = User(
        nombre_usuario=user_data.nombre_usuario,
        correo=user_data.correo,
        contraseña=hashed_password
    )
    db.add(new_user)
    db.flush()

    cliente_role = db.query(RoleModel).filter(RoleModel.role_name == "cliente").first()
    if cliente_role:
        db.add(UserRoleModel(
            user_id=new_user.usuario_id,
            role_id=cliente_role.role_id,
            role_active=True
        ))

    db.commit()
    db.refresh(new_user)

    return {
        "usuario_id": new_user.usuario_id,
        "nombre_usuario": new_user.nombre_usuario,
        "correo": new_user.correo,
        "roles": ["cliente"]
    }


@router.post("/login", status_code=status.HTTP_200_OK)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.correo == user_data.correo).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    try:
        plain_bytes = user_data.contraseña.encode('utf-8')
        hash_bytes = user.contraseña.encode('utf-8')
        password_ok = bcrypt.checkpw(plain_bytes, hash_bytes)
    except Exception:
        password_ok = (user.contraseña == user_data.contraseña)

    if not password_ok:
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    active_roles = db.query(RoleModel).join(UserRoleModel).filter(
        UserRoleModel.user_id == user.usuario_id,
        UserRoleModel.role_active == True
    ).all()

    roles_list = [r.role_name for r in active_roles]

    # --- GENERACIÓN DEL TOKEN JWT ---
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"sub": str(user.usuario_id), "roles": roles_list, "exp": expire}
    access_token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "usuario_id": user.usuario_id,
        "nombre_usuario": user.nombre_usuario,
        "correo": user.correo,
        "roles": roles_list,
        "access_token": access_token,
        "token_type": "bearer"
    }