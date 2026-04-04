# coding: utf-8
"""
Seed de datos de demostración para VillaFoodService.
Se ejecuta automáticamente al arrancar si la BD está vacía.
"""

import bcrypt
from sqlalchemy.orm import Session

from backend.models.category_model import CategoryModel, CategoryProductModel
from backend.models.ingredient_model import Ingrediente
from backend.models.producto_model import Producto, ProductoIngrediente
from backend.models.role_model import RoleModel, UserRoleModel
from backend.models.user_model import User


def demo_data(db: Session):
    """Inserta datos de demostración si la BD está vacía.
    Si ya existen categorías, no hace nada (idempotente)."""

    if db.query(CategoryModel).first() is not None:
        return

    try:
        # ------------------------------------------------------------------ #
        # CATEGORÍAS                                                          #
        # ------------------------------------------------------------------ #
        categorias = {
            "Bebidas calientes":  CategoryModel(category_name="Bebidas calientes",  category_description="Cafetería"),
            "Bebidas frías":      CategoryModel(category_name="Bebidas frías",      category_description="Cafetería"),
            "Bocadillos":         CategoryModel(category_name="Bocadillos",         category_description="Cafetería"),
            "Menú del día":       CategoryModel(category_name="Menú del día",       category_description="Restaurante"),
            "Platos principales": CategoryModel(category_name="Platos principales", category_description="Restaurante"),
            "Postres":            CategoryModel(category_name="Postres",            category_description="Restaurante"),
            "Dulces":             CategoryModel(category_name="Dulces",             category_description="Repostería"),
            "Bollería":           CategoryModel(category_name="Bollería",           category_description="Repostería"),
        }
        db.add_all(categorias.values())
        db.flush()

        # ------------------------------------------------------------------ #
        # INGREDIENTES                                                         #
        # ------------------------------------------------------------------ #
        ingredientes = {
            "Pan":         Ingrediente(ingrediente_nombre="Pan",         ingrediente_unidadMedida="unidades", ingrediente_stockActual=50,   ingrediente_stockMinimo=10,   ingrediente_precioUnitario=0.00),
            "Jamón":       Ingrediente(ingrediente_nombre="Jamón",       ingrediente_unidadMedida="g",        ingrediente_stockActual=2000, ingrediente_stockMinimo=500,  ingrediente_precioUnitario=0.00),
            "Queso":       Ingrediente(ingrediente_nombre="Queso",       ingrediente_unidadMedida="g",        ingrediente_stockActual=1500, ingrediente_stockMinimo=300,  ingrediente_precioUnitario=0.00),
            "Leche":       Ingrediente(ingrediente_nombre="Leche",       ingrediente_unidadMedida="ml",       ingrediente_stockActual=5000, ingrediente_stockMinimo=1000, ingrediente_precioUnitario=0.00),
            "Café":        Ingrediente(ingrediente_nombre="Café",        ingrediente_unidadMedida="g",        ingrediente_stockActual=1000, ingrediente_stockMinimo=200,  ingrediente_precioUnitario=0.00),
            "Harina":      Ingrediente(ingrediente_nombre="Harina",      ingrediente_unidadMedida="g",        ingrediente_stockActual=3000, ingrediente_stockMinimo=500,  ingrediente_precioUnitario=0.00),
            "Huevo":       Ingrediente(ingrediente_nombre="Huevo",       ingrediente_unidadMedida="unidades", ingrediente_stockActual=30,   ingrediente_stockMinimo=6,    ingrediente_precioUnitario=0.00),
            "Mantequilla": Ingrediente(ingrediente_nombre="Mantequilla", ingrediente_unidadMedida="g",        ingrediente_stockActual=500,  ingrediente_stockMinimo=100,  ingrediente_precioUnitario=0.00),
            "Aceite":      Ingrediente(ingrediente_nombre="Aceite",      ingrediente_unidadMedida="ml",       ingrediente_stockActual=1000, ingrediente_stockMinimo=200,  ingrediente_precioUnitario=0.00),
        }
        db.add_all(ingredientes.values())
        db.flush()

        # ------------------------------------------------------------------ #
        # PRODUCTOS                                                           #
        # ------------------------------------------------------------------ #
        productos_data = [
            # (nombre, precio, categoria, [(ingrediente, cantidad), ...])
            ("Café solo",                1.00, "Bebidas calientes",  [("Café", 7)]),
            ("Café con leche",           1.20, "Bebidas calientes",  [("Café", 7), ("Leche", 150)]),
            ("Zumo de naranja",          1.50, "Bebidas frías",      []),
            ("Bocadillo de jamón",       2.50, "Bocadillos",         [("Pan", 1), ("Jamón", 80)]),
            ("Bocadillo mixto",          2.80, "Bocadillos",         [("Pan", 1), ("Jamón", 60), ("Queso", 40)]),
            ("Menú del día",             6.50, "Menú del día",       []),
            ("Tortilla española",        3.50, "Platos principales", [("Huevo", 3), ("Aceite", 20)]),
            ("Flan casero",              2.00, "Postres",            [("Huevo", 2), ("Leche", 200)]),
            ("Croissant de mantequilla", 1.50, "Bollería",           [("Harina", 80), ("Mantequilla", 30)]),
            ("Palmera de chocolate",     1.80, "Bollería",           [("Harina", 100), ("Mantequilla", 20)]),
            ("Magdalena",               1.00, "Dulces",             [("Harina", 60), ("Huevo", 1), ("Mantequilla", 15)]),
            ("Tarta de queso",           3.00, "Dulces",             [("Queso", 100), ("Huevo", 2)]),
        ]

        for nombre, precio, cat_nombre, ings in productos_data:
            producto = Producto(
                producto_nombre=nombre,
                producto_precioUnitario=precio,
                producto_categoria=cat_nombre,
                producto_activo=True,
            )
            db.add(producto)
            db.flush()

            # Enlace en tabla intermedia categoría-producto
            db.add(CategoryProductModel(
                category_id=categorias[cat_nombre].category_id,
                product_id=producto.producto_id,
            ))

            # Ingredientes del producto
            for ing_nombre, cantidad in ings:
                db.add(ProductoIngrediente(
                    productoIngrediente_productoId=producto.producto_id,
                    productoIngrediente_ingredienteId=ingredientes[ing_nombre].ingrediente_id,
                    productoIngrediente_cantidad=cantidad,
                ))

        db.flush()

        # ------------------------------------------------------------------ #
        # USUARIOS DE PRUEBA                                                   #
        # ------------------------------------------------------------------ #
        usuarios_data = [
            ("Cliente Demo",     "cliente@demo.com",     "cliente123",     "cliente"),
            ("Almacén Demo",     "almacen@demo.com",     "almacen123",     "almacen"),
            ("Dependiente Demo", "dependiente@demo.com", "dependiente123", "dependiente"),
        ]

        for nombre, correo, password, rol_nombre in usuarios_data:
            hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
            usuario = User(
                nombre_usuario=nombre,
                correo=correo,
                contraseña=hashed,
            )
            db.add(usuario)
            db.flush()

            rol = db.query(RoleModel).filter(RoleModel.role_name == rol_nombre).first()
            if rol:
                db.add(UserRoleModel(
                    user_id=usuario.usuario_id,
                    role_id=rol.role_id,
                    role_active=True,
                ))

        db.commit()
        print("[seed] Datos de demostración insertados correctamente.")

    except Exception as e:
        db.rollback()
        print(f"[seed] Error al insertar datos de demostración: {e}")