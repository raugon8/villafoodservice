from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.database_manager.database import SessionLocal
from backend.models.user_model import User
from pydantic import BaseModel

router = APIRouter()


# --- ESQUEMAS (Validación de datos) ---

# Para el Registro (Tarea 1)
class UserCreate(BaseModel):
    nombre_usuario: str
    correo: str
    contraseña: str


# Para el Login (NUEVO - Tarea 2)
class UserLogin(BaseModel):
    correo: str
    contraseña: str


# --- DEPENDENCIAS ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# --- ENDPOINTS ---

# TAREA 1: REGISTRO
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Verificar si existe
    existe = db.query(User).filter(User.correo == user_data.correo).first()
    if existe:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    # Crear usuario
    new_user = User(
        nombre_usuario=user_data.nombre_usuario,
        correo=user_data.correo,
        contraseña=user_data.contraseña
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "usuario_ID": new_user.usuario_ID,
        "nombre_usuario": new_user.nombre_usuario,
        "correo": new_user.correo
    }


# TAREA 2: LOGIN (NUEVO)
@router.post("/login", status_code=status.HTTP_200_OK)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    # [cite_start]1. Buscar usuario por correo [cite: 6]
    user = db.query(User).filter(User.correo == user_data.correo).first()

    # [cite_start]2. Si no existe -> Error 404 [cite: 6]
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    # [cite_start]3. Comparar contraseña (texto plano por ahora) -> Error 401 [cite: 6]
    if user.contraseña != user_data.contraseña:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Contraseña incorrecta"
        )

    # [cite_start]4. Si va bien, devolver datos (sin contraseña) [cite: 6]
    return {
        "usuario_ID": user.usuario_ID,
        "nombre_usuario": user.nombre_usuario,
        "correo": user.correo
    }