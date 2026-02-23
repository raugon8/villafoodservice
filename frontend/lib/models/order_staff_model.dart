import '../../models/order_model.dart';

// list item for staff order view
class order_staff_item {
  final int order_id;
  final String user_name;
  final String order_status;
  final double order_total;
  final bool is_new;
  final String order_notes;
  final int items_count;
  final DateTime order_date_time;
  final DateTime? order_pickup_time;
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
      order_pickup_time: json['order_pickup_time'] != null
          ? DateTime.parse(json['order_pickup_time'])
          : null,
      details: (json['details'] as List?)
          ?.map((d) => order_detail.from_json(d))
          .toList() ?? [],
    );
  }

  // returns color based on order status
  static getStatusColor(String status) {
    switch (status) {
      case 'pendiente':      return 0xFFFF9800; // orange
      case 'en_preparacion': return 0xFF2196F3; // blue
      case 'listo':          return 0xFF4CAF50; // green
      default:               return 0xFF9E9E9E; // grey
    }
  }
}