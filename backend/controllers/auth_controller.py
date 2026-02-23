from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from backend.database_manager.database import get_db
from backend.models.user_model import User
from backend.models.role_model import RoleModel, UserRoleModel
from pydantic import BaseModel

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class UserCreate(BaseModel):
    nombre_usuario: str
    correo: str
    contraseña: str


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
    db.flush()

    # Assign 'cliente' role automatically
    cliente_role = db.query(RoleModel).filter(RoleModel.role_name == "cliente").first()
    if cliente_role:
        db.add(UserRoleModel(
            user_id     = new_user.usuario_ID,
            role_id     = cliente_role.role_id,
            role_active = True
        ))

    db.commit()
    db.refresh(new_user)

    return {
        "usuario_ID":     new_user.usuario_ID,
        "nombre_usuario": new_user.nombre_usuario,
        "correo":         new_user.correo,
        "roles":          ["cliente"]
    }


@router.post("/login", status_code=status.HTTP_200_OK)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.correo == user_data.correo).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    # Verify password - support both hashed and plain text (legacy)
    try:
        password_ok = pwd_context.verify(user_data.contraseña, user.contraseña)
    except Exception:
        password_ok = (user.contraseña == user_data.contraseña)

    if not password_ok:
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    # Get active roles
    active_roles = db.query(RoleModel).join(UserRoleModel).filter(
        UserRoleModel.user_id == user.usuario_ID,
        UserRoleModel.role_active == True
    ).all()

    return {
        "usuario_ID":     user.usuario_ID,
        "nombre_usuario": user.nombre_usuario,
        "correo":         user.correo,
        "roles":          [r.role_name for r in active_roles]
    }