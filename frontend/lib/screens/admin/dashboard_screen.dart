import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final Map<String, String> _periodos = {
    'todo': 'Todo el historial',
    'hoy': 'Hoy',
    'semana': 'Última semana',
    'mes': 'Último mes',
    '6meses': 'Últimos 6 meses',
    'personalizado': 'Personalizado',
  };

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
    final inicio = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Fecha inicio',
    );
    if (inicio == null) return;
    final fin = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: inicio,
      lastDate: DateTime.now(),
      helpText: 'Fecha fin',
    );
    if (fin == null) return;
    setState(() { _fecha_inicio = inicio; _fecha_fin = fin; });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        actions: [
          IconButton(icon: const Icon(Icons.people), tooltip: 'Gestionar usuarios',
            onPressed: () => Navigator.pushNamed(context, '/admin/users')),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: Column(
        children: [
          _build_filtros(),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _build_contenido(),
          ),
        ],
      ),
    );
  }

  Widget _build_filtros() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _periodo_seleccionado,
            decoration: InputDecoration(
              labelText: 'Periodo',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _periodos.entries
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
                'Del ${_fecha_inicio!.day}/${_fecha_inicio!.month}/${_fecha_inicio!.year} '
                'al ${_fecha_fin!.day}/${_fecha_fin!.month}/${_fecha_fin!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build_contenido() {
    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seccion('Pedidos', Icons.receipt_long),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card('Total', '${d.pedidos.total_pedidos}', Colors.blueGrey),
              _card('Pendientes', '${d.pedidos.pedidos_pendientes}', Colors.orange),
              _card('En preparación', '${d.pedidos.pedidos_en_preparacion}', Colors.blue),
              _card('Listos', '${d.pedidos.pedidos_listos}', Colors.green),
              _card('Entregados', '${d.pedidos.pedidos_entregados}', Colors.green[800]!),
              _card('Cancelados', '${d.pedidos.pedidos_cancelados}', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          _seccion('Ventas', Icons.euro),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
            children: [
              _card('Ingresos', '€${d.ventas.ingresos_totales.toStringAsFixed(2)}', Colors.green),
              _card('Completados', '${d.ventas.total_pedidos_completados}', Colors.blue),
              _card('Ticket medio', '€${d.ventas.ticket_promedio.toStringAsFixed(2)}', Colors.teal),
            ],
          ),
          const SizedBox(height: 16),
          _seccion('Productos', Icons.fastfood),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card('Activos', '${d.productos.total_productos_activos}', Colors.green, icon: Icons.check_circle),
              _card('Sin stock', '${d.productos.productos_sin_stock}', Colors.orange, icon: Icons.warning),
              _card('Desactivados', '${d.productos.productos_desactivados}', Colors.grey, icon: Icons.cancel),
              _card_mas_vendido(d.productos.producto_mas_vendido_nombre, d.productos.producto_mas_vendido_cantidad),
            ],
          ),
          const SizedBox(height: 16),
          _seccion('Ingredientes', Icons.inventory),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
            children: [
              _card('Total', '${d.ingredientes.total_ingredientes}', Colors.blueGrey),
              _card('Stock crítico', '${d.ingredientes.ingredientes_stock_critico}', Colors.red, icon: Icons.error),
              _card('Stock bajo', '${d.ingredientes.ingredientes_stock_bajo}', Colors.orange, icon: Icons.warning),
              _card('Desactivados', '${d.ingredientes.ingredientes_desactivados}', Colors.grey, icon: Icons.cancel),
            ],
          ),
          const SizedBox(height: 16),
          _seccion('Usuarios', Icons.people),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
            children: [
              _card('Total', '${d.usuarios.total_usuarios}', Colors.blueGrey),
              _card('Admins', '${d.usuarios.usuarios_admin}', Colors.purple),
              _card('Clientes', '${d.usuarios.usuarios_cliente}', Colors.blue),
              _card('Dependientes', '${d.usuarios.usuarios_dependiente}', Colors.teal),
              _card('Almacén', '${d.usuarios.usuarios_almacen}', Colors.brown),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _periodo_seleccionado == 'todo'
                ? 'Estadísticas de todo el historial'
                : _data!.periodo_inicio != null
                  ? 'Estadísticas del ${_data!.periodo_inicio} al ${_data!.periodo_fin}'
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

  Widget _card_mas_vendido(String nombre, int cantidad) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            Text('$cantidad vendidos', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}