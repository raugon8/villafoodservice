// representa un producto dentro del carrito
class cart_item {
  final int producto_id;
  final String producto_nombre;
  final double producto_precio;
  int cantidad;

  cart_item({required this.producto_id, required this.producto_nombre, required this.producto_precio, required this.cantidad});

  // convierte a json para enviar al servidor
  Map<String, dynamic> to_json() => {'producto_id': producto_id, 'cantidad': cantidad};
}

// pedido completo con sus detalles
class order {
  final int pedido_id;
  final String pedido_estado;
  final double pedido_total;
  final DateTime pedido_fecha_hora;
  final List<order_detail> detalles;

  order({required this.pedido_id, required this.pedido_estado, required this.pedido_total, required this.pedido_fecha_hora, required this.detalles});

  // crea objeto desde json del backend
  factory order.from_json(Map<String, dynamic> json) {
    return order(
      pedido_id: json['pedido_id'],
      pedido_estado: json['pedido_estado'],
      pedido_total: (json['pedido_total'] as num).toDouble(),
      pedido_fecha_hora: DateTime.parse(json['pedido_fecha_hora']),
      detalles: (json['detalles'] as List).map((d) => order_detail.from_json(d)).toList(),
    );
  }
}

// linea de detalle de un pedido
class order_detail {
  final String producto_nombre;
  final int detalle_cantidad;
  final double detalle_subtotal;

  order_detail({required this.producto_nombre, required this.detalle_cantidad, required this.detalle_subtotal});

  factory order_detail.from_json(Map<String, dynamic> json) {
    return order_detail(
      producto_nombre: json['producto_nombre'],
      detalle_cantidad: json['detalle_cantidad'],
      detalle_subtotal: (json['detalle_subtotal'] as num).toDouble(),
    );
  }
}