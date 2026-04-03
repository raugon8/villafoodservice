import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_model.dart';
import '../../providers/auth_provider.dart';

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
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _build_contenido(loc),
          ),
        ],
      ),
    );
  }

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

  Widget _build_contenido(AppLocalizations loc) {
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
}