import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_model.dart';
import '../../providers/auth_provider.dart';

/// pantalla del panel de control principal para los administradores
/// muestra estadisticas generales y graficas temporales de rendimiento
class dashboard_screen extends StatefulWidget {
  const dashboard_screen({super.key});

  @override
  State<dashboard_screen> createState() => _dashboard_screen_state();
}

class _dashboard_screen_state extends State<dashboard_screen> {
  final _service = dashboard_service();
  DashboardData? _data;
  bool _loading = true;
  String? _error;

  String _periodo_seleccionado = 'todo';
  DateTime? _fecha_inicio;
  DateTime? _fecha_fin;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// solicita los datos del dashboard al backend usando los filtros actuales
  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final auth = Provider.of<auth_provider>(context, listen: false);
      final result = await _service.get_stats(
        user_id: auth.user_id ?? 1,
        current_role: auth.current_role ?? 'admin',
        periodo: _periodo_seleccionado == 'todo' || _periodo_seleccionado == 'personalizado'
            ? null : _periodo_seleccionado,
        fecha_inicio: _fecha_inicio?.toIso8601String(),
        fecha_fin: _fecha_fin?.toIso8601String(),
      );
      setState(() { _data = result; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  /// abre el selector de fechas nativo para elegir un rango personalizado
  Future<void> _seleccionar_fechas() async {
    final loc = AppLocalizations.of(context)!;
    final inicio = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: loc.dash_date_start,
    );
    if (inicio == null) return;
    final fin = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: inicio,
      lastDate: DateTime.now(),
      helpText: loc.dash_date_end,
    );
    if (fin == null) return;
    setState(() { _fecha_inicio = inicio; _fecha_fin = fin; });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale_prov = Provider.of<locale_provider>(context);
    final is_spanish = locale_prov.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.dash_title),
        actions: [
          IconButton(
            icon: Text(is_spanish ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 24)),
            onPressed: () => locale_prov.toggle_locale(),
          ),
          IconButton(icon: const Icon(Icons.people), tooltip: loc.dash_tooltip_users,
            onPressed: () => Navigator.pushNamed(context, '/admin/users')),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: Column(
        children: [
          _build_filtros(loc),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('error: $_error', style: const TextStyle(color: Colors.red)))
                : _build_contenido(loc, is_spanish),
          ),
        ],
      ),
    );
  }

  /// construye la barra superior con el selector de periodo
  ///
  /// args:
  ///   loc (AppLocalizations): diccionario de traduccion activo
  Widget _build_filtros(AppLocalizations loc) {
    final Map<String, String> periodos = {
      'todo': loc.dash_period_all,
      'hoy': loc.dash_period_today,
      'semana': loc.dash_period_week,
      'mes': loc.dash_period_month,
      '6meses': loc.dash_period_6months,
      'personalizado': loc.dash_period_custom,
    };

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _periodo_seleccionado,
            decoration: InputDecoration(
              labelText: loc.dash_period_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: periodos.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
            onChanged: (v) {
              setState(() { _periodo_seleccionado = v!; });
              if (v == 'personalizado') {
                _seleccionar_fechas();
              } else {
                _cargar();
              }
            },
          ),
          if (_periodo_seleccionado == 'personalizado' && _fecha_inicio != null && _fecha_fin != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${loc.dash_del}${_fecha_inicio!.day}/${_fecha_inicio!.month}/${_fecha_inicio!.year} '
                '${loc.dash_al}${_fecha_fin!.day}/${_fecha_fin!.month}/${_fecha_fin!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  /// construye el cuerpo principal con las tarjetas numericas y las graficas temporales
  ///
  /// args:
  ///   loc (AppLocalizations): diccionario de traduccion activo
  ///   is_spanish (bool): bandera para usar traducciones manuales en graficas
  Widget _build_contenido(AppLocalizations loc, bool is_spanish) {
    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seccion(loc.dash_sec_pedidos, Icons.receipt_long),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card(loc.dash_card_total, '${d.pedidos.total_pedidos}', Colors.blueGrey),
              _card(loc.dash_card_pendientes, '${d.pedidos.pedidos_pendientes}', Colors.orange),
              _card(loc.dash_card_preparacion, '${d.pedidos.pedidos_en_preparacion}', Colors.blue),
              _card(loc.dash_card_listos, '${d.pedidos.pedidos_listos}', Colors.green),
              _card(loc.dash_card_entregados, '${d.pedidos.pedidos_entregados}', Colors.green[800]!),
              _card(loc.dash_card_cancelados, '${d.pedidos.pedidos_cancelados}', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          
          if (d.series_pedidos.isNotEmpty)
            _build_grafica_lineal(
              titulo: is_spanish ? 'pedidos ultimos 7 dias' : 'orders last 7 days',
              datos: d.series_pedidos.map((e) => FlSpot(d.series_pedidos.indexOf(e).toDouble(), e.total.toDouble())).toList(),
              etiquetas: d.series_pedidos.map((e) => e.fecha).toList(),
              color: Colors.lightBlue,
              es_moneda: false,
            ),
          
          const SizedBox(height: 16),
          _seccion(loc.dash_sec_ventas, Icons.euro),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
            children: [
              _card(loc.dash_card_ingresos, '€${d.ventas.ingresos_totales.toStringAsFixed(2)}', Colors.green),
              _card(loc.dash_card_completados, '${d.ventas.total_pedidos_completados}', Colors.blue),
              _card(loc.dash_card_ticket, '€${d.ventas.ticket_promedio.toStringAsFixed(2)}', Colors.teal),
            ],
          ),
          const SizedBox(height: 16),

          if (d.series_ingresos.isNotEmpty)
            _build_grafica_lineal(
              titulo: is_spanish ? 'ingresos ultimos 7 dias' : 'revenue last 7 days',
              datos: d.series_ingresos.map((e) => FlSpot(d.series_ingresos.indexOf(e).toDouble(), e.total)).toList(),
              etiquetas: d.series_ingresos.map((e) => e.fecha).toList(),
              color: Colors.amber,
              es_moneda: true,
            ),

          const SizedBox(height: 16),
          _seccion(loc.dash_sec_productos, Icons.fastfood),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card(loc.dash_card_activos, '${d.productos.total_productos_activos}', Colors.green, icon: Icons.check_circle),
              _card(loc.dash_card_sinstock, '${d.productos.productos_sin_stock}', Colors.orange, icon: Icons.warning),
              _card(loc.dash_card_desactivados, '${d.productos.productos_desactivados}', Colors.grey, icon: Icons.cancel),
              _card_mas_vendido(d.productos.producto_mas_vendido_nombre, d.productos.producto_mas_vendido_cantidad, loc),
            ],
          ),
          const SizedBox(height: 16),
          _seccion(loc.dash_sec_ingredientes, Icons.inventory),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card(loc.dash_card_total, '${d.ingredientes.total_ingredientes}', Colors.blueGrey),
              _card(loc.dash_card_stockcritico, '${d.ingredientes.ingredientes_stock_critico}', Colors.red, icon: Icons.error),
              _card(loc.dash_card_stockbajo, '${d.ingredientes.ingredientes_stock_bajo}', Colors.orange, icon: Icons.warning),
              _card(loc.dash_card_desactivados, '${d.ingredientes.ingredientes_desactivados}', Colors.grey, icon: Icons.cancel),
            ],
          ),
          const SizedBox(height: 16),
          _seccion(loc.dash_sec_usuarios, Icons.people),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
            children: [
              _card(loc.dash_card_total, '${d.usuarios.total_usuarios}', Colors.blueGrey),
              _card(loc.dash_card_admins, '${d.usuarios.usuarios_admin}', Colors.purple),
              _card(loc.dash_card_clientes, '${d.usuarios.usuarios_cliente}', Colors.blue),
              _card(loc.dash_card_dependientes, '${d.usuarios.usuarios_dependiente}', Colors.teal),
              _card(loc.dash_card_almacen, '${d.usuarios.usuarios_almacen}', Colors.brown),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _periodo_seleccionado == 'todo'
                ? loc.dash_stat_all
                : _data!.periodo_inicio != null
                  ? '${loc.dash_stat_del}${_data!.periodo_inicio} ${loc.dash_al}${_data!.periodo_fin}'
                  : '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// construye una etiqueta de seccion con un icono
  ///
  /// args:
  ///   titulo (String): el texto principal de la seccion
  ///   icono (IconData): el icono decorativo
  Widget _seccion(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// construye una tarjeta para mostrar un valor numerico simple
  ///
  /// args:
  ///   titulo (String): la etiqueta pequeña inferior
  ///   valor (String): el numero grande en el centro
  ///   color (Color): el color del texto principal
  ///   icon (IconData?): un icono opcional para acompañar el valor
  Widget _card(String titulo, String valor, Color color, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: color, size: 18),
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(titulo, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// construye una tarjeta especial para el producto mas vendido con icono de estrella
  ///
  /// args:
  ///   nombre (String): el nombre del producto
  ///   cantidad (int): unidades vendidas
  ///   loc (AppLocalizations): diccionario de traducciones
  Widget _card_mas_vendido(String nombre, int cantidad, AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            Text('$cantidad${loc.dash_card_vendidos}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// construye una grafica de lineas usando fl_chart adaptada para series temporales
  ///
  /// args:
  ///   titulo (String): texto superior descriptivo
  ///   datos (List<FlSpot>): lista de puntos cartesianos a dibujar
  ///   etiquetas (List<String>): fechas en formato string para el eje x
  ///   color (Color): color principal de la linea y los puntos
  ///   es_moneda (bool): si es true, añade el simbolo del euro en el tooltip
  Widget _build_grafica_lineal({
    required String titulo,
    required List<FlSpot> datos,
    required List<String> etiquetas,
    required Color color,
    required bool es_moneda,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < etiquetas.length) {
                            // mostramos solo mes y dia para que quepa bien
                            final fecha_corta = etiquetas[index].length > 5 
                                ? etiquetas[index].substring(5) 
                                : etiquetas[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(fecha_corta, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: datos,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final val = es_moneda ? '€${spot.y.toStringAsFixed(2)}' : spot.y.toInt().toString();
                          return LineTooltipItem(val, const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}