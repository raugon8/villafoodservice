from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from backend.object_class.ingredient import IngredienteResponse, IngredienteCreate, IngredienteUpdate
# Se asume que Adán creará este archivo de servicios
from backend.services import ingrediente_service
from backend.database_manager.database import get_db

router = APIRouter(prefix="/ingredientes", tags=["ingredientes"])

@router.get("/", response_model=List[IngredienteResponse])
def listar_ingredientes(db: Session = Depends(get_db)):
    return ingrediente_service.get_ingredientes(db)

@router.get("/{id}", response_model=IngredienteResponse)
def obtener_ingrediente(id: int, db: Session = Depends(get_db)):
    res = ingrediente_service.get_ingrediente(db, id)
    if not res:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    return res

@router.post("/", response_model=IngredienteResponse, status_code=201)
def crear_ingrediente(ingrediente_in: IngredienteCreate, db: Session = Depends(get_db)):
    return ingrediente_service.create_ingrediente(db, ingrediente_in)

@router.put("/{id}", response_model=IngredienteResponse)
def actualizar_ingrediente(id: int, ingrediente_in: IngredienteUpdate, db: Session = Depends(get_db)):
    res = ingrediente_service.update_ingrediente(db, id, ingrediente_in)
    if not res:
        raise HTTPException(status_code=404, detail="No existe el ingrediente")
    return res

@router.delete("/{id}", status_code=204)
def eliminar_ingrediente(id: int, db: Session = Depends(get_db)):
    if not ingrediente_service.delete_ingrediente(db, id):
        raise HTTPException(status_code=404, detail="No encontrado")
    return None