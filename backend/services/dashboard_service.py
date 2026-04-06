from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
from typing import Optional
from decimal import Decimal

from backend.object_class.dashboard import (
    DashboardResponse, PedidosStats, ProductosStats,
    IngredientesStats, UsuariosStats, VentasStats
)


def obtener_estadisticas_dashboard(
    db: Session,
    fecha_inicio: Optional[datetime] = None,
    fecha_fin: Optional[datetime] = None
) -> DashboardResponse:
    # Se usa SQL directo con SUM, CASE WHEN y GROUP BY.

    params = {}
    filtro_fechas_where = ""
    filtro_fechas_and = ""
    if fecha_inicio and fecha_fin:
        filtro_fechas_where = "WHERE order_date_time BETWEEN :inicio AND :fin"
        filtro_fechas_and = "AND order_date_time BETWEEN :inicio AND :fin"
        params = {"inicio": fecha_inicio, "fin": fecha_fin}

    # ================================================================
    # 1. ESTADÍSTICAS DE PEDIDOS
    # ================================================================
    pedidos_result = db.execute(text(f"""
        SELECT
            COUNT(*) as total,
            SUM(CASE WHEN order_status = 'pendiente' THEN 1 ELSE 0 END),
            SUM(CASE WHEN order_status = 'en_preparacion' THEN 1 ELSE 0 END),
            SUM(CASE WHEN order_status = 'listo' THEN 1 ELSE 0 END),
            SUM(CASE WHEN order_status = 'entregado' THEN 1 ELSE 0 END),
            SUM(CASE WHEN order_status = 'cancelado' THEN 1 ELSE 0 END)
        FROM orders {filtro_fechas_where}
    """), params).fetchone()

    pedidos_stats = PedidosStats(
        total_pedidos=pedidos_result[0] or 0,
        pedidos_pendientes=pedidos_result[1] or 0,
        pedidos_en_preparacion=pedidos_result[2] or 0,
        pedidos_listos=pedidos_result[3] or 0,
        pedidos_entregados=pedidos_result[4] or 0,
        pedidos_cancelados=pedidos_result[5] or 0,
    )

    # ================================================================
    # 2. ESTADÍSTICAS DE PRODUCTOS
    # ================================================================
    productos_result = db.execute(text("""
        SELECT
            SUM(CASE WHEN producto_activo = TRUE THEN 1 ELSE 0 END),
            SUM(CASE WHEN producto_activo = FALSE THEN 1 ELSE 0 END)
        FROM productos
    """)).fetchone()

    # Productos sin stock: Aquellos activos pero no tienen stock.
    sin_stock_result = db.execute(text("""
        SELECT COUNT(DISTINCT p.producto_id)
        FROM productos p
        WHERE p.producto_activo = TRUE
        AND p.producto_id IN (
            SELECT pi."productoIngrediente_productoId"
            FROM productos_ingredientes pi
            JOIN ingredientes i ON pi."productoIngrediente_ingredienteId" = i.ingrediente_id
            WHERE (i."ingrediente_stockActual" / pi."productoIngrediente_cantidad") < 1
        )
    """)).fetchone()

    # Excluye pedidos cancelados para no contar ventas que no se completaron.
    mas_vendido = db.execute(text(f"""
        SELECT p.producto_nombre, SUM(od.detail_quantity) as total_vendido
        FROM order_details od
        JOIN productos p ON od.product_id = p.producto_id
        JOIN orders o ON od.order_id = o.order_id
        WHERE o.order_status != 'cancelado'
        {filtro_fechas_and}
        GROUP BY p.producto_id, p.producto_nombre
        ORDER BY total_vendido DESC
        LIMIT 1
    """), params).fetchone()

    productos_stats = ProductosStats(
        total_productos_activos=productos_result[0] or 0,
        productos_sin_stock=sin_stock_result[0] or 0,
        productos_desactivados=productos_result[1] or 0,
        producto_mas_vendido_nombre=mas_vendido[0] if mas_vendido else "N/A",
        producto_mas_vendido_cantidad=int(mas_vendido[1]) if mas_vendido else 0,
    )

    # ================================================================
    # 3. ESTADÍSTICAS DE INGREDIENTES
    # ================================================================
    ing_result = db.execute(text("""
        SELECT
            SUM(CASE WHEN ingrediente_activo = TRUE THEN 1 ELSE 0 END),
            SUM(CASE WHEN ingrediente_activo = TRUE
                AND "ingrediente_stockActual" <= "ingrediente_stockMinimo" THEN 1 ELSE 0 END),
            SUM(CASE WHEN ingrediente_activo = TRUE
                AND "ingrediente_stockActual" > "ingrediente_stockMinimo"
                AND "ingrediente_stockActual" <= "ingrediente_stockMinimo" * 1.5 THEN 1 ELSE 0 END),
            SUM(CASE WHEN ingrediente_activo = FALSE THEN 1 ELSE 0 END)
        FROM ingredientes
    """)).fetchone()

    ingredientes_stats = IngredientesStats(
        total_ingredientes=ing_result[0] or 0,
        ingredientes_stock_critico=ing_result[1] or 0,
        ingredientes_stock_bajo=ing_result[2] or 0,
        ingredientes_desactivados=ing_result[3] or 0,
    )

    # ================================================================
    # 4. ESTADÍSTICAS DE USUARIOS
    # ================================================================
    total_usuarios = db.execute(text("""
        SELECT COUNT(*) FROM usuarios
    """)).fetchone()[0] or 0

    roles_result = db.execute(text("""
        SELECT r.role_name, COUNT(DISTINCT ur.user_id) as total
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.role_id
        WHERE ur.role_active = TRUE
        GROUP BY r.role_name
    """)).fetchall()

    # Crea un listado con los usuarios que tienen un rol.
    roles_dict = {row[0]: row[1] for row in roles_result}

    usuarios_stats = UsuariosStats(
        total_usuarios=total_usuarios,
        usuarios_admin=roles_dict.get('admin', 0),
        usuarios_cliente=roles_dict.get('cliente', 0),
        usuarios_dependiente=roles_dict.get('dependiente', 0),
        usuarios_almacen=roles_dict.get('almacen', 0),
    )

    # ================================================================
    # 5. ESTADÍSTICAS DE VENTAS
    # ================================================================
    ventas_result = db.execute(text(f"""
        SELECT
            COALESCE(SUM(order_total), 0),
            COUNT(*)
        FROM orders
        WHERE order_status IN ('listo', 'entregado')
        {filtro_fechas_and}
    """), params).fetchone()

    ingresos = Decimal(str(ventas_result[0] or 0))
    completados = ventas_result[1] or 0
    # Protección contra división por cero si no hay pedidos completados en el periodo.
    ticket = (ingresos / completados) if completados > 0 else Decimal('0')

    ventas_stats = VentasStats(
        ingresos_totales=ingresos,
        total_pedidos_completados=completados,
        ticket_promedio=ticket,
    )

    return DashboardResponse(
        pedidos=pedidos_stats,
        productos=productos_stats,
        ingredientes=ingredientes_stats,
        usuarios=usuarios_stats,
        ventas=ventas_stats,
        periodo_inicio=fecha_inicio,
        periodo_fin=fecha_fin,
    )