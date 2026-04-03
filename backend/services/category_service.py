from sqlalchemy.orm import Session
from fastapi import HTTPException

from backend.models.category_model import CategoryModel
from backend.object_class.category import CategoryCreate, CategoryUpdate, CategoryResponse


def list_categories(db: Session, active_only: bool = True):
    query = db.query(CategoryModel)
    # Si active_only es True, filtra las categorías desactivadas.
    if active_only:
        query = query.filter(CategoryModel.category_active == True)
    return query.order_by(CategoryModel.category_name.asc()).all()


def get_category_by_id(db: Session, category_id: int):
    category = db.query(CategoryModel).filter(CategoryModel.category_id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    return category


def create_category(db: Session, category_data: CategoryCreate):
    existe = db.query(CategoryModel).filter(
        CategoryModel.category_name == category_data.category_name
    ).first()
    if existe:
        raise HTTPException(status_code=400, detail="Ya existe una categoría con ese nombre")

    nueva = CategoryModel(
        category_name=category_data.category_name,
        category_description=category_data.category_description,
        category_active=True
    )
    db.add(nueva)
    db.commit()
    # refresh() necesario para devolver el objeto con el category_id generado por la BD.
    db.refresh(nueva)
    return nueva


def update_category(db: Session, category_id: int, category_data: CategoryUpdate):
    category = db.query(CategoryModel).filter(CategoryModel.category_id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")

    if category_data.category_name is not None:
        # Busca duplicados excluyendo la propia categoría que se está editando.
        # Sin el category_id != category_id, editar sin cambiar el nombre lanzaría un falso error.
        existe = db.query(CategoryModel).filter(
            CategoryModel.category_name == category_data.category_name,
            CategoryModel.category_id != category_id
        ).first()
        if existe:
            raise HTTPException(status_code=400, detail="Ya existe una categoría con ese nombre")
        category.category_name = category_data.category_name

    if category_data.category_description is not None:
        category.category_description = category_data.category_description

    if category_data.category_active is not None:
        category.category_active = category_data.category_active

    db.commit()
    db.refresh(category)
    return category


def deactivate_category(db: Session, category_id: int):
    category = db.query(CategoryModel).filter(CategoryModel.category_id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    # Soft delete: Solo se marca como inactivo.
    # No se usa db.refresh() porque no es necesario generar un id.
    category.category_active = False
    db.commit()