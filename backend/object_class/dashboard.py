from pydantic import BaseModel
from decimal import Decimal
from datetime import datetime
from typing import Optional


class PedidosStats(BaseModel):
    """Estadísticas de pedidos agrupadas por estado."""
    total_pedidos: int
    pedidos_pendientes: int
    pedidos_en_preparacion: int
    pedidos_listos: int
    pedidos_entregados: int
    pedidos_cancelados: int


class ProductosStats(BaseModel):
    """Estadísticas de productos y disponibilidad."""
    total_productos_activos: int
    productos_sin_stock: int
    productos_desactivados: int
    producto_mas_vendido_nombre: str
    producto_mas_vendido_cantidad: int


class IngredientesStats(BaseModel):
    """Estadísticas de stock de ingredientes.
    Crítico: stock por debajo del mínimo.
    Bajo: stock por encima del mínimo pero dentro del 150% del mismo."""
    total_ingredientes: int
    ingredientes_stock_critico: int
    ingredientes_stock_bajo: int
    ingredientes_desactivados: int


class UsuariosStats(BaseModel):
    """Estadísticas de usuarios agrupadas por rol."""
    total_usuarios: int
    usuarios_admin: int
    usuarios_cliente: int
    usuarios_dependiente: int
    usuarios_almacen: int


class VentasStats(BaseModel):
    """Estadísticas ventas."""
    ingresos_totales: Decimal
    total_pedidos_completados: int
    ticket_promedio: Decimal


class DashboardResponse(BaseModel):
    """Respuesta global del dashboard. Agrupa todas las secciones en un solo objeto.
    periodo_inicio y periodo_fin reflejan el filtro aplicado, tiene None por valor si no se filtra por fecha."""
    pedidos: PedidosStats
    productos: ProductosStats
    ingredientes: IngredientesStats
    usuarios: UsuariosStats
    ventas: VentasStats
    periodo_inicio: Optional[datetime]
    periodo_fin: Optional[datetime]