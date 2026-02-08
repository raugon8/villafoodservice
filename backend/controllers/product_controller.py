from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from database_manager.database import get_db
from object_class.products import ProductResponse, ProductCreate, ProductUpdate, ProductIngredientBase
from services import product_service # Created by Adan

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/", response_model=List[ProductResponse])
def GetAllProducts(skip: int = 0, limit: int = 100, category: str = None, db: Session = Depends(get_db)):
    return product_service.get_all_products(db, skip, limit, category) # [cite: 418, 422]

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def CreateProduct(product_in: ProductCreate, db: Session = Depends(get_db)):
    return product_service.create_product(db, product_in) #

@router.put("/{id}", response_model=ProductResponse)
def UpdateProduct(id: int, product_in: ProductUpdate, db: Session = Depends(get_db)):
    updated_product = product_service.update_product(db, id, product_in)
    if not updated_product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return updated_product

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def DeleteProduct(id: int, db: Session = Depends(get_db)):
    if not product_service.delete_product(db, id): #
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return None

# Ingredients management endpoints
@router.post("/{id}/ingredients", status_code=status.HTTP_201_CREATED)
def AddIngredientToProduct(id: int, ingredient_in: ProductIngredientBase, db: Session = Depends(get_db)):
    return product_service.add_ingredient(db, id, ingredient_in) #