// modelo para que el dependiente vea los pedidos
class order_staff_item {
  final int pedido_id;
  final String usuario_nombre;
  final String pedido_estado;
  final double pedido_total;
  final bool es_nuevo;
  final String pedido_notas;

  order_staff_item({
    required this.pedido_id, 
    required this.usuario_nombre, 
    required this.pedido_estado, 
    required this.pedido_total, 
    required this.es_nuevo,
    required this.pedido_notas
  });

  // mapea el json del staff con el nuevo campo es_nuevo
  factory order_staff_item.from_json(Map<String, dynamic> json) {
    return order_staff_item(
      pedido_id: json['pedido_id'],
      usuario_nombre: json['usuario_nombre'] ?? 'cliente',
      pedido_estado: json['pedido_estado'],
      pedido_total: (json['pedido_total'] as num).toDouble(),
      es_nuevo: json['es_nuevo'] ?? false,
      pedido_notas: json['pedido_notas'] ?? '',
    );
  }
}