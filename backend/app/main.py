from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.controllers.auth_controller import router as auth_router

# Crear instancia de FastAPI
app = FastAPI(
    title="VillaFoodService API",
    description="API para gestión de servicios alimenticios",
    version="1.0.0"
)

app.include_router(auth_router)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "VillaFoodService API",
        "status": "online",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}