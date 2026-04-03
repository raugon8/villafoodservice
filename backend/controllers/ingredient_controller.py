from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from backend.object_class.ingredient import IngredienteResponse, IngredienteCreate, IngredienteUpdate
from backend.services import ingrediente_service
from backend.database_manager.database import get_db
from backend.middleware.auth_middleware import RequireRole

router = APIRouter(prefix="/ingredientes", tags=["ingredientes"])


# Los GET permiten al dependiente ver ingredientes, pero no modificarlos.
# Crear, actualizar y eliminar está restringido a admin y almacén.
@router.get("/", response_model=List[IngredienteResponse])
def listar_ingredientes(
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    return ingrediente_service.get_ingredientes(db)


@router.get("/{id}", response_model=IngredienteResponse)
def obtener_ingrediente(
    id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen", "dependiente"])
    res = ingrediente_service.get_ingrediente(db, id)
    if not res:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    return res


@router.post("/", response_model=IngredienteResponse, status_code=201)
def crear_ingrediente(
    ingrediente_in: IngredienteCreate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen"])
    return ingrediente_service.create_ingrediente(db, ingrediente_in)


@router.put("/{id}", response_model=IngredienteResponse)
def actualizar_ingrediente(
    id: int,
    ingrediente_in: IngredienteUpdate,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    RequireRole(["admin", "almacen"])
    res = ingrediente_service.update_ingrediente(db, id, ingrediente_in)
    if not res:
        raise HTTPException(status_code=404, detail="No existe el ingrediente")
    return res


@router.delete("/{id}", status_code=204)
def eliminar_ingrediente(
    id: int,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    # El service comprueba que el ingrediente no esté en uso en ningún producto antes de eliminarlo.
    RequireRole(["admin", "almacen"])
    if not ingrediente_service.delete_ingrediente(db, id):
        raise HTTPException(status_code=404, detail="No encontrado")
    return None