class dashboard_data {
  final Map<String, dynamic> pedidos;
  final Map<String, dynamic> productos;
  final Map<String, dynamic> ingredientes;
  final Map<String, dynamic> ventas;

  dashboard_data({
    required this.pedidos, 
    required this.productos, 
    required this.ingredientes, 
    required this.ventas
  });

  factory dashboard_data.from_json(Map<String, dynamic> json) {
    return dashboard_data(
      pedidos: json['pedidos'],
      productos: json['productos'],
      ingredientes: json['ingredientes'],
      ventas: json['ventas'],
    );
  }
}