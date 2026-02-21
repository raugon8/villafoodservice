import 'package:flutter/material.dart';

class catalog_screen extends StatefulWidget {
  const catalog_screen({super.key});
  @override
  State<catalog_screen> createState() => _catalog_screen_state();
}

class _catalog_screen_state extends State<catalog_screen> {
  String _filtro = "";
  String _categoria_seleccionada = "Todas";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Productos')),
      body: Column(
        children: [
          // Buscador en tiempo real
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _filtro = value),
              decoration: InputDecoration(
                hintText: 'Buscar producto o ingrediente...',
                prefixIcon: const Icon(Icons.search),
                // Color del tema 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          //Selector de categorias (Simulado para frontend)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Todas', 'Cafetería', 'Restaurante', 'Repostería'].map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _categoria_seleccionada == cat,
                    onSelected: (bool selected) {
                      setState(() => _categoria_seleccionada = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Buscando: $_filtro', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Categoría: $_categoria_seleccionada'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}