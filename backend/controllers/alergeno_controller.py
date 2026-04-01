
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from backend.database_manager.database import get_db
from backend.object_class.products import AlergenoResponse
from backend.models.product_model import AlergenoModel

router = APIRouter(prefix="/alergenos", tags=["alergenos"])

@router.get("/", response_model=List[AlergenoResponse])
def listar_alergenos(db: Session = Depends(get_db)):
    """
    Lista el catálogo fijo de los 14 alérgenos de declaración
    obligatoria en la UE. No requiere permisos especiales.
    """
    return db.query(AlergenoModel).all()