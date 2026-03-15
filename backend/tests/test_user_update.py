import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.database_manager.database import Base
from backend.app.controllers.auth_controller import get_db
from backend.app.main import app
from backend.models.user_model import User

# Configuración de base de datos de prueba en memoria (cache compartido)
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:?cache=shared"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

def test_update_user():
    # 1. Crear un usuario de prueba
    db = TestingSessionLocal()
    user = db.query(User).filter(User.correo == "raul@test.com").first()
    if not user:
        user = User(nombre_usuario="Raul", correo="raul@test.com", contraseña="password123", rol="usuario")
        db.add(user)
        db.commit()
        db.refresh(user)
    user_id = user.usuario_ID
    db.close()

    # 2. Realizar la actualización
    update_data = {
        "nombre_usuario": "Raul Editado",
        "correo": "raul_editado@test.com",
        "rol": "admin"
    }
    
    response = client.put(f"/update/{user_id}", json=update_data)
    
    # 3. Verificar resultados
    assert response.status_code == 200
    data = response.json()
    assert data["nombre_usuario"] == "Raul Editado"
    assert data["correo"] == "raul_editado@test.com"
    assert data["rol"] == "admin"
