# Calcula la disponibilidad de productos en tiempo real según el stock de ingredientes.
# Es el servicio más crítico del sistema: todo el catálogo depende de estas funciones.

from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from decimal import Decimal
import math

# Imports de modelos
from backend.models.producto_model import Producto, ProductoIngrediente
from backend.models.ingredient_model import Ingrediente


# Función para calcular las unidades disponibles de un producto
def calcular_unidades_disponibles(db: Session, producto_id: int) -> int:
    """
    Calcula cuántas unidades de un producto se pueden hacer con el stock actual.

    Ejemplo:
        Pizza Margarita necesita:
        - 0.2 kg queso, stock: 1.0 kg → 1.0 / 0.2 = 5 unidades
        - 0.15 kg tomate, stock: 0.45 kg → 0.45 / 0.15 = 3 unidades
        - 0.3 kg masa, stock: 2.0 kg → 2.0 / 0.3 = 6 unidades
        Resultado: min(5, 3, 6) = 3 pizzas disponibles
    """

    # Obtener todas las relaciones producto-ingrediente
    relaciones = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id
    ).all()

    # Si el producto no tiene ingredientes → 0 disponibles
    if not relaciones:
        return 0

    # Lista para guardar las unidades posibles con cada ingrediente
    unidades_posibles_list = []

    for relacion in relaciones:
        # Obtener el ingrediente
        ingrediente = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_id == relacion.productoIngrediente_ingredienteId
        ).first()

        # Si el ingrediente no existe o está inactivo → 0 disponibles
        if not ingrediente or not ingrediente.ingrediente_activo:
            return 0

        # Obtener stock actual y cantidad necesaria
        stock_actual = float(ingrediente.ingrediente_stockActual)
        cantidad_necesaria = float(relacion.productoIngrediente_cantidad)

        # Si stock es 0 → no se puede hacer ninguna unidad
        if stock_actual == 0:
            return 0

        # Si cantidad necesaria es 0 → error de datos
        if cantidad_necesaria == 0:
            raise ValueError(f"Cantidad necesaria no puede ser 0 para ingrediente {ingrediente.ingrediente_id}")

        # Calcular cuántas unidades se pueden hacer con este ingrediente
        unidades_con_este_ingrediente = stock_actual / cantidad_necesaria

        # Redondear hacia abajo (no podemos servir medias unidades)
        unidades_con_este_ingrediente = math.floor(unidades_con_este_ingrediente)

        unidades_posibles_list.append(unidades_con_este_ingrediente)

    # El mínimo es lo que realmente se puede hacer
    # (el ingrediente que se acabe primero limita la producción)
    unidades_disponibles = min(unidades_posibles_list)

    return unidades_disponibles


# Función para obtener solo los productos con disponibilidad mayor a 0
def get_productos_disponibles(db: Session, categoria: Optional[str] = None) -> List[dict]:
    """Obtiene solo productos que tienen unidades_disponibles > 0.
    Opcionalmente filtra por categoría."""

    # Obtener todos los productos activos
    query = db.query(Producto).filter(Producto.producto_activo == True)

    # Filtrar por categoría si se especifica
    if categoria:
        query = query.filter(Producto.producto_categoria == categoria)

    productos = query.all()

    # Filtrar solo los que tienen stock disponible
    productos_disponibles = []

    for producto in productos:
        unidades = calcular_unidades_disponibles(db, producto.producto_id)

        if unidades > 0:
            producto_dict = {
                "producto_id": producto.producto_id,
                "producto_nombre": producto.producto_nombre,
                "producto_descripcion": producto.producto_descripcion,
                "producto_precioUnitario": producto.producto_precioUnitario,
                "producto_categoria": producto.producto_categoria,
                "producto_activo": producto.producto_activo,
                "unidades_disponibles": unidades,
                "disponible": True
            }
            productos_disponibles.append(producto_dict)

    return productos_disponibles


# Función para obtener el detalle de disponibilidad de un producto por ingrediente
def get_detalle_disponibilidad(db: Session, producto_id: int) -> dict:
    """Retorna información detallada sobre la disponibilidad de un producto,
    incluyendo análisis por ingrediente y cuál es el limitante."""

    # Obtener producto
    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return None

    # Obtener relaciones producto-ingrediente
    relaciones = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id
    ).all()

    if not relaciones:
        return {
            "producto_id": producto.producto_id,
            "producto_nombre": producto.producto_nombre,
            "unidades_disponibles": 0,
            "disponible": False,
            "ingredientes_detalle": [],
            "ingrediente_limitante": None
        }

    # Calcular disponibilidad global
    unidades_totales = calcular_unidades_disponibles(db, producto_id)

    # Analizar cada ingrediente
    ingredientes_detalle = []
    ingrediente_limitante_nombre = None
    min_unidades = float('inf')

    for relacion in relaciones:
        ingrediente = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_id == relacion.productoIngrediente_ingredienteId
        ).first()

        if not ingrediente:
            continue

        stock_actual = float(ingrediente.ingrediente_stockActual)
        cantidad_necesaria = float(relacion.productoIngrediente_cantidad)

        # Calcular unidades posibles con este ingrediente
        if cantidad_necesaria > 0:
            unidades_posibles = math.floor(stock_actual / cantidad_necesaria)
        else:
            unidades_posibles = 0

        # Determinar si es el ingrediente limitante
        es_limitante = (unidades_posibles == unidades_totales) and (unidades_totales > 0)

        if unidades_posibles < min_unidades:
            min_unidades = unidades_posibles
            ingrediente_limitante_nombre = ingrediente.ingrediente_nombre

        ingrediente_detalle = {
            "ingrediente_id": ingrediente.ingrediente_id,
            "ingrediente_nombre": ingrediente.ingrediente_nombre,
            "cantidad_necesaria": cantidad_necesaria,
            "stock_disponible": stock_actual,
            "unidades_posibles": unidades_posibles,
            "es_limitante": es_limitante
        }
        ingredientes_detalle.append(ingrediente_detalle)

    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "unidades_disponibles": unidades_totales,
        "disponible": unidades_totales > 0,
        "ingredientes_detalle": ingredientes_detalle,
        "ingrediente_limitante": ingrediente_limitante_nombre
    }


# Función para verificar si hay stock suficiente antes de confirmar un pedido
def verificar_disponibilidad_para_pedido(db: Session, producto_id: int, cantidad_solicitada: int) -> bool:
    """Verifica si hay suficiente stock para un pedido. No modifica el stock, solo comprueba."""

    unidades_disponibles = calcular_unidades_disponibles(db, producto_id)

    return cantidad_solicitada <= unidades_disponibles


# Función para actualizar el stock tras confirmar un pedido
def actualizar_stock_post_pedido(db: Session, pedido_id: int) -> None:
    """Resta el stock de ingredientes al confirmar un pedido."""
    # TODO: implementar cuando se complete la integración con la tabla de pedidos
    pass


# Función para obtener productos con stock crítico (usado en alertas del dashboard)
def get_productos_stock_critico(db: Session) -> List[dict]:
    """Retorna productos con 5 o menos unidades disponibles."""

    productos = db.query(Producto).filter(Producto.producto_activo == True).all()

    productos_criticos = []

    for producto in productos:
        unidades = calcular_unidades_disponibles(db, producto.producto_id)

        # Considerar crítico si tiene 0 unidades o menos de 5
        if unidades <= 5:
            detalle = get_detalle_disponibilidad(db, producto.producto_id)
            productos_criticos.append(detalle)

    return productos_criticos