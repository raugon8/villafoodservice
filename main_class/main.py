from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database_manager.database import init_db

# Importacion de controladores
from controllers.auth_controller import router as auth_router
from controllers.ingredient_controller import router as ingredient_router
from controllers.product_controller import router as product_router
from controllers.order_controller import router as order_router
from controllers.dashboard_controller import router as dashboard_router
from controllers.category_controller import router as category_router #

app = FastAPI()

# Configuracion de permisos para conexion con el frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializacion de la base de datos y creacion de tablas
init_db() # [cite: 327, 431]

# Registro de rutas del sistema
app.include_router(auth_router, prefix="/auth") # [cite: 9]
app.include_router(ingredient_router) # [cite: 63, 65]
app.include_router(product_router) # [cite: 432, 434]
app.include_router(order_router) # [cite: 551]
app.include_router(dashboard_router) #
app.include_router(category_router) #

# Comentario: El prefijo /categories se gestiona dentro de su propio controlador