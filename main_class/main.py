from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.controllers import auth_controller
from backend.database_manager.database import init_db
from controllers.product_controller import router as product_router
app = FastAPI()

# Configuración de permisos (CORS) para que el Frontend pueda entrar
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Creamos las tablas al iniciar la aplicación
init_db()

# Conectamos el controlador de autenticación con el prefijo /auth
app.include_router(auth_controller.router, prefix="/auth")
app.include_router(product_router)