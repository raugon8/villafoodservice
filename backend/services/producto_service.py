"""
Servicio de Productos
Lógica de negocio para CRUD de productos y gestión de ingredientes y alérgenos
"""
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

from backend.models.producto_model import Producto, ProductoIngrediente, AlergenoModel
from backend.models.ingredient_model import Ingrediente

# Import del servicio de disponibilidad
from backend.services import disponibilidad_service


# ============================================================================
# FUNCIÓN 1: Listar productos con disponibilidad
# ============================================================================
def get_productos(db: Session, skip: int = 0, limit: int = 100, categoria: Optional[str] = None) -> List[dict]:
    """Devuelve productos activos con su disponibilidad calculada. Opcionalmente filtra por categoría."""

    # Query base: productos activos
    query = db.query(Producto).filter(Producto.producto_activo == True)

    # Filtrar por categoría si se especifica
    if categoria:
        query = query.filter(Producto.producto_categoria == categoria)

    # Aplicar paginación
    productos = query.offset(skip).limit(limit).all()

    # Para cada producto, calcular disponibilidad en tiempo real
    resultado = []
    for producto in productos:
        unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto.producto_id)

        producto_dict = {
            "producto_id": producto.producto_id,
            "producto_nombre": producto.producto_nombre,
            "producto_descripcion": producto.producto_descripcion,
            "producto_precioUnitario": producto.producto_precioUnitario,
            "producto_categoria": producto.producto_categoria,
            "producto_activo": producto.producto_activo,
            "image_url": getattr(producto, "image_url", None),
            "unidades_disponibles": unidades,
            "disponible": unidades > 0,
            "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in producto.alergenos]
        }
        resultado.append(producto_dict)

    return resultado


# ============================================================================
# FUNCIÓN 2: Obtener un producto por ID
# ============================================================================
def get_producto(db: Session, producto_id: int) -> Optional[dict]:
    """Obtiene un producto específico por ID con disponibilidad"""

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return None

    # Calcular disponibilidad
    unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto_id)

    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "producto_descripcion": producto.producto_descripcion,
        "producto_precioUnitario": producto.producto_precioUnitario,
        "producto_categoria": producto.producto_categoria,
        "producto_activo": producto.producto_activo,
        "image_url": getattr(producto, "image_url", None),
        "unidades_disponibles": unidades,
        "disponible": unidades > 0,
        "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in producto.alergenos]
    }


# ============================================================================
# FUNCIÓN 3: Obtener producto con detalle de ingredientes
# ============================================================================
def get_producto_con_ingredientes(db: Session, producto_id: int) -> Optional[dict]:
    """
    Obtiene producto con todos sus ingredientes y análisis de disponibilidad.
    Usado para el endpoint GET /productos/{id}
    """

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return None

    # Obtener detalle de disponibilidad (incluye análisis de ingredientes)
    detalle_disponibilidad = disponibilidad_service.get_detalle_disponibilidad(db, producto_id)

    # Construir respuesta completa
    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "producto_descripcion": producto.producto_descripcion,
        "producto_precioUnitario": producto.producto_precioUnitario,
        "producto_categoria": producto.producto_categoria,
        "producto_activo": producto.producto_activo,
        "image_url": getattr(producto, "image_url", None),
        "unidades_disponibles": detalle_disponibilidad["unidades_disponibles"],
        "disponible": detalle_disponibilidad["disponible"],
        "ingredientes": detalle_disponibilidad["ingredientes_detalle"],
        "ingrediente_limitante": detalle_disponibilidad["ingrediente_limitante"],
        "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in producto.alergenos]
    }


# ============================================================================
# FUNCIÓN 4: Crear nuevo producto
# ============================================================================
def create_producto(db: Session, producto_data: dict) -> dict:
    """
    Crea un nuevo producto.
    VALIDACIÓN: No puede existir otro producto con el mismo nombre.
    """

    # VALIDACIÓN: verificar que NO exista otro producto con el mismo nombre
    existe = db.query(Producto).filter(
        Producto.producto_nombre == producto_data["producto_nombre"]
    ).first()

    if existe:
        raise HTTPException(
            status_code=400,
            detail="Ya existe un producto con ese nombre"
        )

    # Extraer la lista de alérgenos antes de instanciar el modelo
    alergeno_ids = producto_data.pop("alergeno_ids", None)

    # Crear nuevo producto
    nuevo_producto = Producto(**producto_data)

    # Asignar alérgenos si se enviaron
    if alergeno_ids:
        nuevos_alergenos = db.query(AlergenoModel).filter(AlergenoModel.alergeno_id.in_(alergeno_ids)).all()
        nuevo_producto.alergenos = nuevos_alergenos

    # Guardar en BD
    db.add(nuevo_producto)
    db.commit()
    db.refresh(nuevo_producto)

    return {
        "producto_id": nuevo_producto.producto_id,
        "producto_nombre": nuevo_producto.producto_nombre,
        "producto_descripcion": nuevo_producto.producto_descripcion,
        "producto_precioUnitario": nuevo_producto.producto_precioUnitario,
        "producto_categoria": nuevo_producto.producto_categoria,
        "producto_activo": nuevo_producto.producto_activo,
        "image_url": getattr(nuevo_producto, "image_url", None),
        "unidades_disponibles": 0,
        "disponible": False,
        "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in nuevo_producto.alergenos]
    }


# ============================================================================
# FUNCIÓN 5: Actualizar producto existente
# ============================================================================
def update_producto(db: Session, producto_id: int, producto_data: dict) -> Optional[dict]:
    """
    Actualiza un producto existente.
    VALIDACIÓN: Si se cambia el nombre, verificar que no exista otro con ese nombre.
    """

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return None

    # VALIDACIÓN: si se actualiza el nombre, verificar unicidad
    if "producto_nombre" in producto_data:
        existe_otro = db.query(Producto).filter(
            Producto.producto_nombre == producto_data["producto_nombre"],
            Producto.producto_id != producto_id
        ).first()

        if existe_otro:
            raise HTTPException(
                status_code=400,
                detail="Ya existe un producto con ese nombre"
            )

    # Extraer la lista de alérgenos
    alergeno_ids = producto_data.pop("alergeno_ids", None)

    # Actualizar campos normales
    for key, value in producto_data.items():
        setattr(producto, key, value)

    # Gestionar la relación de alérgenos
    if alergeno_ids is not None:
        if not alergeno_ids:
            producto.alergenos = []  # Lista vacía limpia los alérgenos
        else:
            nuevos_alergenos = db.query(AlergenoModel).filter(AlergenoModel.alergeno_id.in_(alergeno_ids)).all()
            producto.alergenos = nuevos_alergenos

    db.commit()
    db.refresh(producto)

    unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto_id)

    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "producto_descripcion": producto.producto_descripcion,
        "producto_precioUnitario": producto.producto_precioUnitario,
        "producto_categoria": producto.producto_categoria,
        "producto_activo": producto.producto_activo,
        "image_url": getattr(producto, "image_url", None),
        "unidades_disponibles": unidades,
        "disponible": unidades > 0,
        "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in producto.alergenos]
    }


# ============================================================================
# FUNCIÓN 6: Eliminar producto (soft delete)
# ============================================================================
def delete_producto(db: Session, producto_id: int) -> bool:
    """Soft delete de un producto: se marca como inactivo, no se borra de la BD.
    Valida que no tenga pedidos activos antes de desactivar."""

    from backend.models.pedido_model import OrderModel, OrderDetailModel

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        return False

    # No se puede desactivar si hay pedidos en curso que contienen este producto.
    pedidos_activos = db.query(OrderModel).join(OrderDetailModel).filter(
        OrderDetailModel.product_id == producto_id,
        OrderModel.order_status.in_(["pendiente", "en_preparacion"])
    ).first()

    if pedidos_activos:
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar: el producto tiene pedidos activos"
        )

    # Soft delete: no se borra el registro, solo se marca como inactivo.
    producto.producto_activo = False
    db.commit()

    return True


# ============================================================================
# FUNCIÓN 7: Añadir ingrediente a un producto
# ============================================================================
def add_ingrediente_to_producto(db: Session, producto_id: int, ingrediente_id: int, cantidad: Decimal) -> dict:
    """Añade un ingrediente a un producto con su cantidad necesaria."""

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()

    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")

    if cantidad <= 0:
        raise HTTPException(status_code=400, detail="La cantidad debe ser mayor a 0")

    existe_relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()

    if existe_relacion:
        raise HTTPException(
            status_code=400,
            detail="Este ingrediente ya está en el producto"
        )

    nueva_relacion = ProductoIngrediente(
        productoIngrediente_productoId=producto_id,
        productoIngrediente_ingredienteId=ingrediente_id,
        productoIngrediente_cantidad=cantidad
    )

    db.add(nueva_relacion)
    db.commit()
    db.refresh(nueva_relacion)

    return {
        "productoIngrediente_id": nueva_relacion.productoIngrediente_id,
        "producto_id": producto_id,
        "ingrediente_id": ingrediente_id,
        "ingrediente_nombre": ingrediente.ingrediente_nombre,
        "cantidad": cantidad
    }


# ============================================================================
# FUNCIÓN 8: Actualizar cantidad de ingrediente en producto
# ============================================================================
def update_cantidad_ingrediente(db: Session, producto_id: int, ingrediente_id: int, nueva_cantidad: Decimal) -> Optional[dict]:
    """Actualiza la cantidad necesaria de un ingrediente en un producto.
    Valida que cantidad > 0."""

    if nueva_cantidad <= 0:
        raise HTTPException(status_code=400, detail="La cantidad debe ser mayor a 0")

    relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()

    if not relacion:
        return None

    relacion.productoIngrediente_cantidad = nueva_cantidad
    db.commit()
    db.refresh(relacion)

    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id
    ).first()

    return {
        "productoIngrediente_id": relacion.productoIngrediente_id,
        "producto_id": producto_id,
        "ingrediente_id": ingrediente_id,
        "ingrediente_nombre": ingrediente.ingrediente_nombre if ingrediente else "Desconocido",
        "cantidad": nueva_cantidad
    }


# ============================================================================
# FUNCIÓN 9: Quitar ingrediente de un producto
# ============================================================================
def remove_ingrediente_from_producto(db: Session, producto_id: int, ingrediente_id: int) -> bool:
    """Elimina la relación producto-ingrediente."""

    relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()

    if not relacion:
        return False

    total_ingredientes = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id
    ).count()

    if total_ingredientes <= 1:
        raise HTTPException(
            status_code=400,
            detail="Un producto debe tener al menos un ingrediente"
        )

    db.delete(relacion)
    db.commit()

    return True


# ============================================================================
# FUNCIÓN 10: Actualizar categorías de un producto
# ============================================================================
def update_product_categories(db: Session, producto_id: int, category_ids: list) -> dict:
    """Asigna o reemplaza las categorías de un producto."""
    from backend.models.category_model import CategoryProductModel, CategoryModel

    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()

    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    # Eliminar asociaciones actuales
    db.query(CategoryProductModel).filter(
        CategoryProductModel.product_id == producto_id
    ).delete()

    # Crear nuevas asociaciones
    for cat_id in category_ids:
        categoria = db.query(CategoryModel).filter(
            CategoryModel.category_id == cat_id,
            CategoryModel.category_active == True
        ).first()
        if not categoria:
            raise HTTPException(status_code=404, detail=f"Categoría {cat_id} no encontrada o inactiva")

        nueva = CategoryProductModel(category_id=cat_id, product_id=producto_id)
        db.add(nueva)

    db.commit()

    unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto_id)
    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "producto_descripcion": producto.producto_descripcion,
        "producto_precioUnitario": producto.producto_precioUnitario,
        "producto_categoria": producto.producto_categoria,
        "producto_activo": producto.producto_activo,
        "image_url": getattr(producto, "image_url", None),
        "unidades_disponibles": unidades,
        "disponible": unidades > 0,
        "alergenos": [{"alergeno_id": a.alergeno_id, "nombre": a.nombre} for a in producto.alergenos]
    }