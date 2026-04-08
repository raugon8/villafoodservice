import '../../models/order_model.dart'; // necesario para leer la lista de order_detail

// elemento de lista para la vista de pedidos del personal
class order_staff_item {
  final int order_id;
  final String user_name;
  final String order_status;
  final double order_total;
  final bool is_new; // recuperado: marca si el pedido acaba de entrar
  final String order_notes;
  final int items_count;
  final DateTime order_date_time;
  final DateTime? order_pickup_time;
  // nota de cancelacion escrita por el dependiente
  final String? cancel_reason;
  // recuperado: la lista de productos dentro del pedido
  final List<order_detail> details; 

  order_staff_item({
    required this.order_id,
    required this.user_name,
    required this.order_status,
    required this.order_total,
    required this.is_new,
    required this.order_notes,
    required this.items_count,
    required this.order_date_time,
    this.order_pickup_time,
    this.cancel_reason,
    this.details = const []
  });

  factory order_staff_item.from_json(Map<String, dynamic> json) {
    return order_staff_item(
      order_id:          json['order_id'],
      user_name:         json['user_name'] ?? 'cliente',
      order_status:      json['order_status'],
      order_total:       double.parse(json['order_total'].toString()),
      is_new:            json['is_new'] ?? false,
      order_notes:       json['order_notes'] ?? '',
      items_count:       json['items_count'] ?? 0,
      order_date_time:   DateTime.parse(json['order_date_time']),
      order_pickup_time: json['order_pickup_time'] != null ? DateTime.parse(json['order_pickup_time']) : null,
      
      // leemos el motivo de cancelacion por si la hay
      cancel_reason:     json['cancel_reason'] ?? json['motivo_cancelacion'] ?? json['nota'],
      
      // parseamos la lista de detalles del pedido
      details:           (json['details'] as List?)?.map((d) => order_detail.from_json(d)).toList() ?? [],
    );
  }

  // devuelve un codigo de color especifico segun el estado del pedido
  static int getStatusColor(String status) {
    switch (status) {
      case 'pendiente':      return 0xFFFFC107; // amarillo
      case 'en_preparacion': return 0xFF2196F3; // azul
      case 'listo':          return 0xFF4CAF50; // verde
      case 'cancelado':      return 0xFFF44336; // rojo
      default:               return 0xFF9E9E9E; // gris
    }
  }
}