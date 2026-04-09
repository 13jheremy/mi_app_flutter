// ----------------------------------------
// lib/models/category.dart
// Modelo para la tabla Categoria.
// ----------------------------------------
class Category {
  final int id;
  final String nombre;
  final String? descripcion;

  Category({required this.id, required this.nombre, this.descripcion});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nombre: (json['nombre'] as String?) ?? 'Sin nombre',
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'descripcion': descripcion};
  }
}
