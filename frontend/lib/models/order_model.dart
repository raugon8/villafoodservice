// representa un producto individual dentro del carrito
class cart_item {
  final int product_id;
  final String product_name;
  final double product_price;
  int quantity;
  cart_item({required this.product_id, required this.product_name, required this.product_price, required this.quantity});
  Map<String, dynamic> to_json() => {
    'product_id': product_id,
    'quantity': quantity
  };
}
// pedido completo con todos sus detalles y estado
class order {
  final int order_id;
  final String order_status;
  final double order_total;
  final DateTime order_date_time;
  final List<order_detail> details;
  order({required this.order_id, required this.order_status, required this.order_total, required this.order_date_time, required this.details});
  factory order.from_json(Map<String, dynamic> json) {
    return order(
      order_id:        json['order_id'],
      order_status:    json['order_status'],
      order_total:     double.parse(json['order_total'].toString()),
      order_date_time: DateTime.parse(json['order_date_time']),
      details:         (json['details'] as List?)?.map((d) => order_detail.from_json(d)).toList() ?? [],
    );
  }
}
// linea de detalle de un pedido especifico
class order_detail {
  final String product_name;
  final int detail_quantity;
  final double detail_subtotal;
  order_detail({required this.product_name, required this.detail_quantity, required this.detail_subtotal});
  factory order_detail.from_json(Map<String, dynamic> json) {
    return order_detail(
      product_name:    json['product_name'] ?? '',
      detail_quantity: json['detail_quantity'],
      detail_subtotal: double.parse(json['detail_subtotal'].toString()),
    );
  }
}
// producto dentro del historial de un pedido anterior
class historial_producto {
  final int producto_id;
  final String nombre;
  final int cantidad;
  final double precio_unitario;
  historial_producto({required this.producto_id, required this.nombre, required this.cantidad, required this.precio_unitario});
  factory historial_producto.from_json(Map<String, dynamic> json) {
    return historial_producto(
      producto_id:     json['producto_id'],
      nombre:          json['nombre'] ?? '',
      cantidad:        json['cantidad'],
      precio_unitario: double.parse(json['precio_unitario'].toString()),
    );
  }
}
// pedido del historial del cliente con formato del endpoint /pedidos/historial
class historial_pedido {
  final int pedido_id;
  final DateTime fecha;
  final String estado;
  final double total;
  final List<historial_producto> productos;
  // nota de cancelacion escrita por el dependiente — null si no fue cancelado o no hay nota
  final String? cancel_reason;
  historial_pedido({required this.pedido_id, required this.fecha, required this.estado, required this.total, required this.productos, this.cancel_reason});
  factory historial_pedido.from_json(Map<String, dynamic> json) {
    return historial_pedido(
      pedido_id:     json['pedido_id'],
      fecha:         DateTime.parse(json['fecha']),
      estado:        json['estado'],
      total:         double.parse(json['total'].toString()),
      cancel_reason: json['cancel_reason'],
      productos:     (json['productos'] as List?)?.map((p) => historial_producto.from_json(p)).toList() ?? [],
    );
  }
}