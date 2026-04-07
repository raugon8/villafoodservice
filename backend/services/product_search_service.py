from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import Optional
from decimal import Decimal

from backend.object_class.products import ProductSearchFilters, ProductSearchResponse
from backend.services import disponibilidad_service


def search_products(db: Session, filters: ProductSearchFilters) -> ProductSearchResponse:
    """Búsqueda avanzada de productos con filtros dinámicos.
    Usa SQL directo porque las condiciones WHERE son más sencillas."""

    # ================================================================
    # Construir condiciones WHERE dinámicamente según los filtros activos
    # ================================================================
    conditions = []
    params = {}

    if filters.active_only:
        conditions.append("p.producto_activo = TRUE")

    if filters.search_query:
        # Busca en nombre, descripción y nombre de ingredientes del producto.
        conditions.append("""(
            p.producto_nombre LIKE :search
            OR p.producto_descripcion LIKE :search
            OR EXISTS (
                SELECT 1 FROM productos_ingredientes pi
                JOIN ingredientes i ON pi."productoIngrediente_ingredienteId" = i.ingrediente_id
                WHERE pi."productoIngrediente_productoId" = p.producto_id
                AND i.ingrediente_nombre LIKE :search
            )
        )""")
        params["search"] = f"%{filters.search_query}%"

    if filters.service:
        conditions.append("p.producto_categoria = :service")
        params["service"] = filters.service

    if filters.category_ids:
        # Filtra productos que pertenezcan a cualquiera de las categorias seleccionadas (OR).
        # Los IDs se insertan directamente porque son enteros validados por Pydantic, sin riesgo de inyeccion.
        ids_str = ",".join(str(i) for i in filters.category_ids)
        conditions.append(f"""EXISTS (
            SELECT 1 FROM category_products cp
            WHERE cp.product_id = p.producto_id
            AND cp.category_id IN ({ids_str})
        )""")

    if filters.min_price is not None:
        conditions.append('p."producto_precioUnitario" >= :min_price')
        params["min_price"] = float(filters.min_price)

    if filters.max_price is not None:
        conditions.append('p."producto_precioUnitario" <= :max_price')
        params["max_price"] = float(filters.max_price)

    where_clause = "WHERE " + " AND ".join(conditions) if conditions else ""

    # ================================================================
    # Ordenamiento
    # ================================================================
    order_map = {
        "name_asc":   "p.producto_nombre ASC",
        "name_desc":  "p.producto_nombre DESC",
        "price_asc":  'p."producto_precioUnitario" ASC',
        "price_desc": 'p."producto_precioUnitario" DESC',
    }

    if filters.sort_by == "popularity":
        # Ordena por total de unidades vendidas en pedidos no cancelados.
        # COALESCE evita NULL si el producto nunca ha sido pedido.
        order_clause = """ORDER BY (
            SELECT COALESCE(SUM(od.detail_quantity), 0)
            FROM order_details od
            JOIN orders o ON od.order_id = o.order_id
            WHERE od.product_id = p.producto_id
            AND o.order_status != 'cancelado'
        ) DESC"""
    else:
        order_clause = f"ORDER BY {order_map.get(filters.sort_by or 'name_asc', 'p.producto_nombre ASC')}"

    # ================================================================
    # Contar total — Es necesario para que el frontend sepa cuántos resultados hay en total.
    # ================================================================
    count_sql = f"SELECT COUNT(*) FROM productos p {where_clause}"
    total_count = db.execute(text(count_sql), params).fetchone()[0]

    # ================================================================
    # Query principal con paginación
    # ================================================================
    main_sql = f"""
        SELECT p.producto_id, p.producto_nombre, p.producto_descripcion,
               p."producto_precioUnitario", p.producto_categoria, p.producto_activo,
               p.image_url
        FROM productos p
        {where_clause}
        {order_clause}
        LIMIT :limit OFFSET :skip
    """
    params["limit"] = filters.limit
    params["skip"] = filters.skip

    rows = db.execute(text(main_sql), params).fetchall()

    # ================================================================
    # Añadir disponibilidad y alérgenos a cada producto.
    # ================================================================
    products = []
    for row in rows:
        producto_id = row[0]
        unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto_id)

        if filters.available_only and unidades == 0:
            continue

        # Obtener alérgenos del producto desde la tabla intermedia
        alergenos = db.execute(
            text("""
                SELECT a.alergeno_id, a.nombre
                FROM alergenos a
                JOIN producto_alergenos pa ON a.alergeno_id = pa.alergeno_id
                WHERE pa.producto_id = :producto_id
            """),
            {"producto_id": producto_id}
        ).fetchall()

        products.append({
            "producto_id":             producto_id,
            "producto_nombre":         row[1],
            "producto_descripcion":    row[2],
            "producto_precioUnitario": row[3],
            "producto_categoria":      row[4],
            "producto_activo":         bool(row[5]),
            "image_url":               row[6],
            "unidades_disponibles":    unidades,
            "disponible":              unidades > 0,
            "alergenos":               [{"alergeno_id": a[0], "nombre": a[1]} for a in alergenos],
        })

    return ProductSearchResponse(
        products=products,
        total_count=total_count,
        filters_applied=filters,
    )