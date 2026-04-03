# Servicio más crítico del sistema: todo el catálogo depende de estas funciones.
# Calcula la disponibilidad de productos en tiempo real según el stock de ingredientes.

from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from decimal import Decimal
import math

from backend.models.producto_model import Producto, ProductoIngrediente
from backend.models.ingredient_model import Ingrediente


def calcular_unidades_disponibles(db: Session, producto_id: int) -> int:
    """
    Calcula cuántas unidades de un producto se pueden elaborar con el stock actual.
    El ingrediente con menor resultado limita la disponibilidad total.
    Ejemplo:
        Pizza Margarita necesita:
        - 0.2 kg queso, stock: 1.0 kg → 1.0 / 0.2 = 5 unidades
        - 0.15 kg tomate, stock: 0.45 kg → 0.45 / 0.15 = 3 unidades
        - 0.3 kg masa, stock: 2.0 kg → 2.0 / 0.3 = 6 unidades
        Resultado: min(5, 3, 6) = 3 pizzas disponibles
    """

    relaciones = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id
    ).all()

    # Sin ingredientes asignados no se puede elaborar el producto.
    if not relaciones:
        return 0

    unidades_posibles_list = []

    for relacion in relaciones:
        ingrediente = db.query(Ingrediente).filter(
            Ingrediente.ingrediente_id == relacion.productoIngrediente_ingredienteId
        ).first()

        # Ingrediente inactivo o eliminado bloquea la disponibilidad del producto.
        if not ingrediente or not ingrediente.ingrediente_activo:
            return 0

        stock_actual = float(ingrediente.ingrediente_stockActual)
        cantidad_necesaria = float(relacion.productoIngrediente_cantidad)

        if stock_actual == 0:
            return 0

        if cantidad_necesaria == 0:
            raise ValueError(f"Cantidad necesaria no puede ser 0 para ingrediente {ingrediente.ingrediente_id}")

        # floor() porque no se pueden servir fracciones de unidad.
        unidades_con_este_ingrediente = math.floor(stock_actual / cantidad_necesaria)

        unidades_posibles_list.append(unidades_con_este_ingrediente)

    # El mínimo es el factor limitante: El ingrediente que se agota primero.
    unidades_disponibles = min(unidades_posibles_list)

    return unidades_disponibles


def get_productos_disponibles(db: Session, categoria: Optional[str] = None) -> List[dict]:
    """Devuelve solo los productos activos con al menos una unidad disponible.
    Opcionalmente filtra por categoría."""

    query = db.query(Producto).filter(Producto.producto_activo == True)

    if categoria:
        query = query.filter(Producto.producto_categoria == categoria)

    productos = query.all()

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


def get_detalle_disponibilidad(db: Session, producto_id: int) -> dict:
    """Devuelve el análisis de disponibilidad de un producto desglosado por ingrediente,
    indicando cuál es el ingrediente limitante."""

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return None

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

    # Disponibilidad global del producto (mínimo entre todos los ingredientes).
    unidades_totales = calcular_unidades_disponibles(db, producto_id)

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

        if cantidad_necesaria > 0:
            unidades_posibles = math.floor(stock_actual / cantidad_necesaria)
        else:
            unidades_posibles = 0

        # El ingrediente limitante es el que tiene el menor número de unidades posibles.
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


def verificar_disponibilidad_para_pedido(db: Session, producto_id: int, cantidad_solicitada: int) -> bool:
    """Comprueba si hay stock suficiente para un pedido. No modifica el stock."""

    unidades_disponibles = calcular_unidades_disponibles(db, producto_id)

    return cantidad_solicitada <= unidades_disponibles


def actualizar_stock_post_pedido(db: Session, pedido_id: int) -> None:
    """Pendiente de implementar. El descuento de stock se realiza actualmente
    en order_service._deduct_ingredient_stock() al confirmar el pedido."""
    pass


def get_productos_stock_critico(db: Session) -> List[dict]:
    """Devuelve productos activos con 5 o menos unidades disponibles."""

    productos = db.query(Producto).filter(Producto.producto_activo == True).all()

    productos_criticos = []

    for producto in productos:
        unidades = calcular_unidades_disponibles(db, producto.producto_id)

        if unidades <= 5:
            detalle = get_detalle_disponibilidad(db, producto.producto_id)
            productos_criticos.append(detalle)

    return productos_criticos