from pydantic import BaseModel
from decimal import Decimal
from datetime import datetime
from typing import Optional

class PedidosStats(BaseModel):
    """Estadisticas de pedidos agrupadas por estado"""
    total_pedidos: int
    pedidos_pendientes: int
    pedidos_en_preparacion: int
    pedidos_listos: int
    pedidos_entregados: int
    pedidos_cancelados: int

class ProductosStats(BaseModel):
    """Estadisticas de productos y disponibilidad"""
    total_productos_activos: int
    productos_sin_stock: int
    productos_desactivados: int
    producto_mas_vendido_nombre: str
    producto_mas_vendido_cantidad: int

class IngredientesStats(BaseModel):
    """Estadisticas de stock de ingredientes"""
    total_ingredientes: int
    ingredientes_stock_critico: int
    ingredientes_stock_bajo: int
    ingredientes_desactivados: int

class UsuariosStats(BaseModel):
    """Estadisticas de usuarios por rol"""
    total_usuarios: int
    usuarios_admin: int
    usuarios_cliente: int
    usuarios_dependiente: int
    usuarios_almacen: int

class VentasStats(BaseModel):
    """Estadisticas financieras"""
    ingresos_totales: Decimal
    total_pedidos_completados: int
    ticket_promedio: Decimal

class DashboardResponse(BaseModel):
    """Respuesta global del dashboard con todas las secciones"""
    pedidos: PedidosStats
    productos: ProductosStats
    ingredientes: IngredientesStats
    usuarios: UsuariosStats
    ventas: VentasStats
    periodo_inicio: Optional[datetime]
    periodo_fin: Optional[datetime]