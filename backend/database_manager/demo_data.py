from sqlalchemy.orm import Session

from backend.models.ingredient_model import Ingrediente
from backend.models.product_ingredient_model import ProductIngredientModel
from backend.models.producto_model import Producto

class Categoria:
    pass


def demo_data(db: Session):
    """Ejecuta el seed de datos de demostración si la BD está vacía."""

    if db.query(Servicio).first() is not None:
        return

    try:
        # --- SERVICIOS ---
        demo_services = {
            "Cafetería": Servicio(nombre="Cafetería"),
            "Restaurante": Servicio(nombre="Restaurante"),
            "Repostería": Servicio(nombre="Repostería")
        }
        db.add_all(demo_services.values())
        db.flush()

        # --- CATEGORÍAS ---
        demo_categories = {
            "Bebidas calientes": Categoria(nombre="Bebidas calientes", servicio_id=demo_services["Cafetería"].id),
            "Bebidas frías": Categoria(nombre="Bebidas frías", servicio_id=demo_services["Cafetería"].id),
            "Bocadillos": Categoria(nombre="Bocadillos", servicio_id=demo_services["Cafetería"].id),
            "Menú del día": Categoria(nombre="Menú del día", servicio_id=demo_services["Restaurante"].id),
            "Platos principales": Categoria(nombre="Platos principales", servicio_id=demo_services["Restaurante"].id),
            "Postres": Categoria(nombre="Postres", servicio_id=demo_services["Restaurante"].id),
            "Dulces": Categoria(nombre="Dulces", servicio_id=demo_services["Repostería"].id),
            "Bollería": Categoria(nombre="Bollería", servicio_id=demo_services["Repostería"].id)
        }
        db.add_all(demo_categories.values())
        db.flush()

        # --- INGREDIENTES ---
        demo_ingredients = {
            "Pan": Ingrediente(ingrediente_nombre="Pan", ingrediente_unidadMedida="unidades",
                               ingrediente_stockActual=50, ingrediente_stockMinimo=10, ingrediente_precioUnitario=0.00),
            "Jamón": Ingrediente(ingrediente_nombre="Jamón", ingrediente_unidadMedida="g", ingrediente_stockActual=2000,
                                 ingrediente_stockMinimo=500, ingrediente_precioUnitario=0.00),
            "Queso": Ingrediente(ingrediente_nombre="Queso", ingrediente_unidadMedida="g", ingrediente_stockActual=1500,
                                 ingrediente_stockMinimo=300, ingrediente_precioUnitario=0.00),
            "Leche": Ingrediente(ingrediente_nombre="Leche", ingrediente_unidadMedida="ml",
                                 ingrediente_stockActual=5000, ingrediente_stockMinimo=1000,
                                 ingrediente_precioUnitario=0.00),
            "Café": Ingrediente(ingrediente_nombre="Café", ingrediente_unidadMedida="g", ingrediente_stockActual=1000,
                                ingrediente_stockMinimo=200, ingrediente_precioUnitario=0.00),
            "Harina": Ingrediente(ingrediente_nombre="Harina", ingrediente_unidadMedida="g",
                                  ingrediente_stockActual=3000, ingrediente_stockMinimo=500,
                                  ingrediente_precioUnitario=0.00),
            "Huevo": Ingrediente(ingrediente_nombre="Huevo", ingrediente_unidadMedida="unidades",
                                 ingrediente_stockActual=30, ingrediente_stockMinimo=6,
                                 ingrediente_precioUnitario=0.00),
            "Mantequilla": Ingrediente(ingrediente_nombre="Mantequilla", ingrediente_unidadMedida="g",
                                       ingrediente_stockActual=500, ingrediente_stockMinimo=100,
                                       ingrediente_precioUnitario=0.00),
            "Aceite": Ingrediente(ingrediente_nombre="Aceite", ingrediente_unidadMedida="ml",
                                  ingrediente_stockActual=1000, ingrediente_stockMinimo=200,
                                  ingrediente_precioUnitario=0.00)
        }
        db.add_all(demo_ingredients.values())
        db.flush()

        # --- PRODUCTOS Y SUS INGREDIENTES ---
        demo_products = [
            ("Café solo", 1.00, "Bebidas calientes", [("Café", 7)]),
            ("Café con leche", 1.20, "Bebidas calientes", [("Café", 7), ("Leche", 150)]),
            ("Zumo de naranja", 1.50, "Bebidas frías", []),
            ("Bocadillo de jamón", 2.50, "Bocadillos", [("Pan", 1), ("Jamón", 80)]),
            ("Bocadillo mixto", 2.80, "Bocadillos", [("Pan", 1), ("Jamón", 60), ("Queso", 40)]),
            ("Menú del día", 6.50, "Menú del día", []),
            ("Tortilla española", 3.50, "Platos principales", [("Huevo", 3), ("Aceite", 20)]),
            ("Flan casero", 2.00, "Postres", [("Huevo", 2), ("Leche", 200)]),
            ("Croissant de mantequilla", 1.50, "Bollería", [("Harina", 80), ("Mantequilla", 30)]),
            ("Palmera de chocolate", 1.80, "Bollería", [("Harina", 100), ("Mantequilla", 20)]),
            ("Magdalena", 1.00, "Dulces", [("Harina", 60), ("Huevo", 1), ("Mantequilla", 15)]),
            ("Tarta de queso", 3.00, "Dulces", [("Queso", 100), ("Huevo", 2)])
        ]

        for p_nombre, p_precio, p_cat, p_ingredientes in demo_products:
            producto = Producto(producto_nombre=p_nombre, producto_precioUnitario=p_precio,
                                categoria_id=demo_categories[p_cat].id)
            db.add(producto)
            db.flush()

            for ing_nombre, ing_cantidad in p_ingredientes:
                prod_ing = ProductIngredientModel(
                    product_id=producto.producto_id,
                    ingredient_id=demo_ingredients[ing_nombre].ingrediente_id,
                    quantity=ing_cantidad
                )
                db.add(prod_ing)

        # --- USUARIOS DE PRUEBA ---
        demo_users = [
            ("Cliente Demo", "cliente@demo.com", "cliente123", "cliente"),
            ("Almacén Demo", "almacen@demo.com", "almacen123", "almacen"),
            ("Dependiente Demo", "dependiente@demo.com", "dependiente123", "dependiente")
        ]

        for u_nombre, u_correo, u_pass, u_rol_nombre in demo_users:
            hashed_pwd = pwd_context.hash(u_pass)
            usuario = demo_users(nombre_usuario=u_nombre, correo=u_correo, contraseña=hashed_pwd)
            db.add(usuario)
            db.flush()

            rol = db.query(Role).filter(Role.role_name == u_rol_nombre).first()
            if rol:
                db.add(UserRole(user_id=usuario.usuario_ID, role_id=rol.role_id, role_active=True))

        db.commit()
        print("Demo data seeded successfully.")

    except Exception as e:
        db.rollback()
        print(f"Error seeding database with demo data: {e}")