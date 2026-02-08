from sqlalchemy import Column, Integer, Numeric, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from database_manager.database import Base

class ProductIngredientModel(Base):
    __tablename__ = "product_ingredients"

    product_ingredient_id = Column(Integer, primary_key=True, autoincrement=True) # [cite: 373]
    product_id = Column(Integer, ForeignKey("products.product_id"), nullable=False) # [cite: 374]
    ingredient_id = Column(Integer, ForeignKey("ingredients.ingrediente_id"), nullable=False) # [cite: 375, 376]
    quantity = Column(Numeric(10, 2), nullable=False) # [cite: 377]

    # Relationships
    product = relationship("ProductModel", back_populates="product_ingredients") # [cite: 379]
    ingredient = relationship("Ingrediente", back_populates="productos_vinculados") # [cite: 380]

    # Constraint: avoid duplicate ingredients in same product
    __table_args__ = (UniqueConstraint('product_id', 'ingredient_id', name='_product_ingredient_uc'),) # [cite: 381, 382]