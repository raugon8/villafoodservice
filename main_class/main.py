from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Importamos los controladores
from backend.controllers import auth_controller
from backend.controllers import ingredient_controller
from backend.controllers import producto_controller
from backend.controllers import order_controller

from backend.database_manager.database import init_db

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

# Conectamos los controladores
app.include_router(auth_controller.router, prefix="/auth")
app.include_router(ingredient_controller.router)
app.include_router(producto_controller.router)
app.include_router(order_controller.router)