# Servicio de disponibilidad simplificado:
# La disponibilidad de un producto depende ÚNICA Y EXCLUSIVAMENTE
# del interruptor manual 'producto_en_stock' gestionado desde el frontend.

from sqlalchemy.orm import Session
from typing import List

from backend.models.producto_model import Producto


def calcular_unidades_disponibles(db: Session, producto_id: int) -> int:
    """
    LÓGICA 100% MANUAL:
    Si el producto tiene 'producto_en_stock == True' -> devuelve 999 (Disponible).
    Si tiene 'producto_en_stock == False' -> devuelve 0 (Agotado).
    """
    producto = db.query(Producto).filter(Producto.producto_id == producto_id).first()

    if not producto or not producto.producto_en_stock:
        return 0

    return 999


def calcular_disponibilidad_detalle(db: Session, producto_id: int) -> dict:
    """
    Versión para el panel de administración.
    Ya no calcula qué ingrediente falta, solo devuelve el estado del interruptor.
    """
    producto = db.query(Producto).filter(Producto.producto_id == producto_id).first()
    if not producto:
        return {}

    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "unidades_disponibles": 999 if producto.producto_en_stock else 0,
        "disponible": producto.producto_en_stock,
        "ingredientes_detalle": [],  # Lo dejamos vacío porque el stock de ingredientes ya no importa aquí
        "ingrediente_limitante": None
    }


def verificar_disponibilidad_para_pedido(db: Session, producto_id: int, cantidad_solicitada: int) -> bool:
    """Comprueba si el interruptor manual del producto está encendido."""
    unidades_disponibles = calcular_unidades_disponibles(db, producto_id)
    return unidades_disponibles > 0


def actualizar_stock_post_pedido(db: Session, pedido_id: int) -> None:
    pass


def get_productos_stock_critico(db: Session) -> List[dict]:
    """Devuelve la lista de productos que el personal ha marcado manualmente como AGOTADOS."""
    productos = db.query(Producto).filter(
        Producto.producto_activo == True,
        Producto.producto_en_stock == False
    ).all()

    productos_criticos = []
    for producto in productos:
        productos_criticos.append({
            "producto_id": producto.producto_id,
            "producto_nombre": producto.producto_nombre,
            "unidades_disponibles": 0,
            "estado": "Agotado manualmente"
        })

    return productos_criticos