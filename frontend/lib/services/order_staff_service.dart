import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_staff_model.dart';

class order_staff_service {
  static const String base_url = 'http://localhost:8000';

  Future<List<order_staff_item>> list_staff_orders(
    String service, {
    required int user_id,
    required String current_role,
    String? status,
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    String url = '$base_url/pedidos/staff?service=$service&user_id=$user_id&current_role=$current_role&skip=$skip&limit=$limit';
    if (status != null && status.isNotEmpty) url += '&status=$status';
    if (search != null && search.isNotEmpty) url += '&search=$search';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((o) => order_staff_item.from_json(o)).toList();
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error loading staff orders');
  }

  Future<order_staff_item> get_staff_order_detail(
    int order_id,
    String service, {
    required int user_id,
    required String current_role,
  }) async {
    final response = await http.get(
      Uri.parse('$base_url/pedidos/staff/$order_id?service=$service&user_id=$user_id&current_role=$current_role'),
    );
    if (response.statusCode == 200) {
      return order_staff_item.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error loading order detail');
  }

  Future<order_staff_item> update_order_status(
    int order_id,
    String new_status,
    String service, {
    required int user_id,
    required String current_role,
  }) async {
    final response = await http.patch(
      Uri.parse('$base_url/pedidos/staff/$order_id/estado?service=$service&user_id=$user_id&current_role=$current_role'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'order_status': new_status}),
    );
    if (response.statusCode == 200) {
      return order_staff_item.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error updating status');
  }
}