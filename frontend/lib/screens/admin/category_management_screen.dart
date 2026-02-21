import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';

class category_management_screen extends StatelessWidget {
  const category_management_screen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = category_service();
    return Scaffold(
      appBar: AppBar(title: const Text('gestion de categorias')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // para crear categoria
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<category_model>>(
        future: service.list_categories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(snapshot.data![index].category_name),
              trailing: const Icon(Icons.edit),
            ),
          );
        },
      ),
    );
  }
}