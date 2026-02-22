import 'order_model.dart';

// simple static cart shared between screens
class cart_manager {
  static final List<cart_item> items = [];

  static void add_item(int product_id, String product_name, double product_price) {
    final existing = items.indexWhere((i) => i.product_id == product_id);
    if (existing >= 0) {
      items[existing].quantity++;
    } else {
      items.add(cart_item(
        product_id: product_id,
        product_name: product_name,
        product_price: product_price,
        quantity: 1
      ));
    }
  }

  static void clear() {
    items.clear();
  }

  static int get total_items => items.fold(0, (sum, i) => sum + i.quantity);
}