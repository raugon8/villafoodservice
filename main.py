# Punto de entrada de la aplicación. Registra middlewares, inicializa la BD y conecta todos los routers.
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os
import sys
from backend.controllers import auth_controller
from backend.controllers import ingredient_controller
from backend.controllers import producto_controller
from backend.controllers import order_controller
from backend.controllers import user_controller
from backend.controllers import dashboard_controller
from backend.controllers import category_controller
from backend.controllers import alergeno_controller
from backend.database_manager.database import init_db, migrate_db, get_db
from backend.database_manager.demo_data import demo_data

app = FastAPI()

# Permite peticiones desde cualquier origen.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Crea las tablas si no existen y aplica migraciones al arrancar
init_db()
migrate_db()

# Seed de datos de demostración (solo se ejecuta si la BD está vacía)
@app.on_event("startup")
def startup():
    db = next(get_db())
    try:
        demo_data(db)
    finally:
        db.close()

# Registro de todos los routers del sistema
app.include_router(auth_controller.router, prefix="/auth")
app.include_router(ingredient_controller.router)
app.include_router(producto_controller.router)
app.include_router(order_controller.router)
app.include_router(user_controller.router)
app.include_router(dashboard_controller.router)
app.include_router(category_controller.router)
app.include_router(alergeno_controller.router)

# Sirve el frontend Flutter compilado desde la carpeta web/
# sys._MEIPASS es la ruta temporal que usa PyInstaller al ejecutar el .exe
base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
web_path = os.path.join(base_path, "web")

if os.path.exists(web_path):
    app.mount("/", StaticFiles(directory=web_path, html=True), name="static")