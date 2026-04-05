import '../config/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

// conecta con el backend para extraer todas las metricas del panel
class dashboard_service {
  static const String base_url = AppConstants.apiUrl;

  // construye la url con los filtros de fecha opcionales
  Future<DashboardData> get_stats({
    required int user_id,
    required String current_role,
    String? periodo,
    String? fecha_inicio,
    String? fecha_fin,
  }) async {
    String url = '$base_url/dashboard/stats?user_id=$user_id&current_role=$current_role';
    if (periodo != null && periodo.isNotEmpty) url += '&periodo=$periodo';
    if (fecha_inicio != null) url += '&fecha_inicio=$fecha_inicio';
    if (fecha_fin != null) url += '&fecha_fin=$fecha_fin';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return DashboardData.from_json(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'error cargando estadisticas');
  }
}

