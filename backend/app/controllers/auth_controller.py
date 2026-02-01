from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.database_manager.database import SessionLocal
from backend.models.user_model import User
from pydantic import BaseModel

# Creamos el enrutador (gestor de caminos)
router = APIRouter()


# Validación de datos que entran (Schema)
class UserCreate(BaseModel):
    nombre_usuario: str
    correo: str
    contraseña: str


# Función para conectar con la BD en cada petición
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# --- LÓGICA DEL REGISTRO ---
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # 1. Buscamos si el correo ya existe
    existe = db.query(User).filter(User.correo == user_data.correo).first()

    if existe:
        # Si existe, cortamos y devolvemos error 400
        raise HTTPException(
            status_code=400,
            detail="El correo ya está registrado"
        )

    # 2. Si no existe, preparamos el nuevo usuario
    nuevo_usuario = User(
        nombre_usuario=user_data.nombre_usuario,
        correo=user_data.correo,
        contraseña=user_data.contraseña
    )

    # 3. Guardamos en la base de datos
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)

    # 4. Devolvemos los datos limpios (sin contraseña)
    return {
        "usuario_ID": nuevo_usuario.usuario_ID,
        "nombre_usuario": nuevo_usuario.nombre_usuario,
        "correo": nuevo_usuario.correo
    }