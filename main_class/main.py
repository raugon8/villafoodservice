# Punto de entrada de la aplicación. Registra middlewares, inicializa la BD y conecta todos los routers.
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.controllers import auth_controller
from backend.controllers import ingredient_controller
from backend.controllers import producto_controller
from backend.controllers import order_controller
from backend.controllers import user_controller
from backend.controllers import dashboard_controller
from backend.controllers import category_controller
from backend.database_manager.database import init_db, migrate_db

app = FastAPI()

# Permite peticiones desde cualquier origen. En producción se restringirá a la URL del frontend (T11).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Crea las tablas si no existen y aplica migraciones al arrancar
init_db()
migrate_db()

# Registro de todos los routers del sistema
app.include_router(auth_controller.router, prefix="/auth")
app.include_router(ingredient_controller.router)
app.include_router(producto_controller.router)
app.include_router(order_controller.router)
app.include_router(user_controller.router)
app.include_router(dashboard_controller.router)
app.include_router(category_controller.router)