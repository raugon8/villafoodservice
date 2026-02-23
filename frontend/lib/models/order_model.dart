// represents a product inside the cart
class cart_item {
  final int product_id;
  final String product_name;
  final double product_price;
  int quantity;

  cart_item({
    required this.product_id,
    required this.product_name,
    required this.product_price,
    required this.quantity
  });

  Map<String, dynamic> to_json() => {
    'product_id': product_id,
    'quantity': quantity
  };
}

// full order with its details
class order {
  final int order_id;
  final String order_status;
  final double order_total;
  final DateTime order_date_time;
  final List<order_detail> details;

  order({
    required this.order_id,
    required this.order_status,
    required this.order_total,
    required this.order_date_time,
    required this.details
  });

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

// detail line of an order
class order_detail {
  final String product_name;
  final int detail_quantity;
  final double detail_subtotal;

  order_detail({
    required this.product_name,
    required this.detail_quantity,
    required this.detail_subtotal
  });

  factory order_detail.from_json(Map<String, dynamic> json) {
    return order_detail(
      product_name:    json['product_name'] ?? '',
      detail_quantity: json['detail_quantity'],
      detail_subtotal: double.parse(json['detail_subtotal'].toString()),
    );
  }
}