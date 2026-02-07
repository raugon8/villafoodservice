"""
Servicio de Productos
Lógica de negocio para CRUD de productos y gestión de ingredientes
"""
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Optional
from decimal import Decimal

# Imports de modelos
from backend.models.producto_model import Producto, ProductoIngrediente
from backend.models.ingredient_model import Ingrediente

# Import del servicio de disponibilidad
from backend.services import disponibilidad_service


# ============================================================================
# FUNCIÓN 1: Listar productos con disponibilidad
# ============================================================================
def get_productos(db: Session, skip: int = 0, limit: int = 100, categoria: Optional[str] = None) -> List[dict]:
    """
    Obtiene lista de productos activos con su disponibilidad calculada.
    Opcionalmente filtra por categoría.
    """
    
    # Query base: productos activos
    query = db.query(Producto).filter(Producto.producto_activo == True)
    
    # Filtrar por categoría si se especifica
    if categoria:
        query = query.filter(Producto.producto_categoria == categoria)
    
    # Aplicar paginación
    productos = query.offset(skip).limit(limit).all()
    
    # Para cada producto, calcular disponibilidad
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
            "unidades_disponibles": unidades,
            "disponible": unidades > 0
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
        "unidades_disponibles": unidades,
        "disponible": unidades > 0
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
        "unidades_disponibles": detalle_disponibilidad["unidades_disponibles"],
        "disponible": detalle_disponibilidad["disponible"],
        "ingredientes": detalle_disponibilidad["ingredientes_detalle"],
        "ingrediente_limitante": detalle_disponibilidad["ingrediente_limitante"]
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
    
    # Crear nuevo producto
    nuevo_producto = Producto(**producto_data)
    
    # Guardar en BD
    db.add(nuevo_producto)
    db.commit()
    db.refresh(nuevo_producto)
    
    # Retornar con disponibilidad (será 0 porque no tiene ingredientes todavía)
    return {
        "producto_id": nuevo_producto.producto_id,
        "producto_nombre": nuevo_producto.producto_nombre,
        "producto_descripcion": nuevo_producto.producto_descripcion,
        "producto_precioUnitario": nuevo_producto.producto_precioUnitario,
        "producto_categoria": nuevo_producto.producto_categoria,
        "producto_activo": nuevo_producto.producto_activo,
        "unidades_disponibles": 0,
        "disponible": False
    }


# ============================================================================
# FUNCIÓN 5: Actualizar producto existente
# ============================================================================
def update_producto(db: Session, producto_id: int, producto_data: dict) -> Optional[dict]:
    """
    Actualiza un producto existente.
    VALIDACIÓN: Si se cambia el nombre, verificar que no exista otro con ese nombre.
    """
    
    # Buscar producto
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
    
    # Actualizar campos
    for key, value in producto_data.items():
        setattr(producto, key, value)
    
    db.commit()
    db.refresh(producto)
    
    # Calcular disponibilidad
    unidades = disponibilidad_service.calcular_unidades_disponibles(db, producto_id)
    
    return {
        "producto_id": producto.producto_id,
        "producto_nombre": producto.producto_nombre,
        "producto_descripcion": producto.producto_descripcion,
        "producto_precioUnitario": producto.producto_precioUnitario,
        "producto_categoria": producto.producto_categoria,
        "producto_activo": producto.producto_activo,
        "unidades_disponibles": unidades,
        "disponible": unidades > 0
    }


# ============================================================================
# FUNCIÓN 6: Eliminar producto (soft delete)
# ============================================================================
def delete_producto(db: Session, producto_id: int) -> bool:
    """
    Elimina un producto (soft delete).
    VALIDACIÓN CRÍTICA: No se puede eliminar si tiene pedidos activos.
    """
    
    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()
    
    if not producto:
        return False
    
    # VALIDACIÓN CRÍTICA: verificar que no tenga pedidos activos
    # TODO: Cuando se implemente la tabla Pedidos, descomentar esta validación
    # from models.pedido_model import Pedido
    # pedidos_activos = db.query(Pedido).filter(
    #     Pedido.producto_id == producto_id,
    #     Pedido.estado.in_(["pendiente", "en preparación"])
    # ).first()
    # 
    # if pedidos_activos:
    #     raise HTTPException(
    #         status_code=400,
    #         detail="No se puede eliminar: el producto tiene pedidos activos"
    #     )
    
    # Soft delete
    producto.producto_activo = False
    db.commit()
    
    return True


# ============================================================================
# FUNCIÓN 7: Añadir ingrediente a un producto
# ============================================================================
def add_ingrediente_to_producto(db: Session, producto_id: int, ingrediente_id: int, cantidad: Decimal) -> dict:
    """
    Añade un ingrediente a un producto con su cantidad necesaria.
    
    VALIDACIONES:
    - Producto existe y está activo
    - Ingrediente existe y está activo
    - Cantidad > 0
    - No existe ya esta combinación (duplicado)
    """
    
    # VALIDACIÓN: Producto existe y está activo
    producto = db.query(Producto).filter(
        Producto.producto_id == producto_id,
        Producto.producto_activo == True
    ).first()
    
    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    
    # VALIDACIÓN: Ingrediente existe y está activo
    ingrediente = db.query(Ingrediente).filter(
        Ingrediente.ingrediente_id == ingrediente_id,
        Ingrediente.ingrediente_activo == True
    ).first()
    
    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    
    # VALIDACIÓN: Cantidad > 0
    if cantidad <= 0:
        raise HTTPException(status_code=400, detail="La cantidad debe ser mayor a 0")
    
    # VALIDACIÓN: No existe ya esta relación
    existe_relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()
    
    if existe_relacion:
        raise HTTPException(
            status_code=400,
            detail="Este ingrediente ya está en el producto"
        )
    
    # Crear relación
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
    """
    Actualiza la cantidad necesaria de un ingrediente en un producto.
    VALIDACIÓN: cantidad > 0
    """
    
    # VALIDACIÓN: Cantidad > 0
    if nueva_cantidad <= 0:
        raise HTTPException(status_code=400, detail="La cantidad debe ser mayor a 0")
    
    # Buscar relación
    relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()
    
    if not relacion:
        return None
    
    # Actualizar cantidad
    relacion.productoIngrediente_cantidad = nueva_cantidad
    db.commit()
    db.refresh(relacion)
    
    # Obtener nombre del ingrediente
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
    """
    Elimina la relación producto-ingrediente.
    VALIDACIÓN: Un producto debe tener al menos 1 ingrediente.
    """
    
    # Buscar relación
    relacion = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id,
        ProductoIngrediente.productoIngrediente_ingredienteId == ingrediente_id
    ).first()
    
    if not relacion:
        return False
    
    # VALIDACIÓN: Verificar que no sea el último ingrediente
    total_ingredientes = db.query(ProductoIngrediente).filter(
        ProductoIngrediente.productoIngrediente_productoId == producto_id
    ).count()
    
    if total_ingredientes <= 1:
        raise HTTPException(
            status_code=400,
            detail="Un producto debe tener al menos un ingrediente"
        )
    
    # Eliminar relación
    db.delete(relacion)
    db.commit()
    
    return True