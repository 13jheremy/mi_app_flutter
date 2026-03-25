// lib/models/product.dart
class Product {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final int categoriaId;
  final String? categoriaNombre;
  final double precioVenta;
  final bool activo;
  final bool destacado;
  final int stockActual;
  final String? imageUrl;

  Product({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.categoriaId,
    this.categoriaNombre,
    required this.precioVenta,
    required this.activo,
    required this.destacado,
    required this.stockActual,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Intentar obtener el stock de diferentes formas
    int stock = 0;

    // 1. Primero intentar stock_actual directo
    if (json['stock_actual'] != null) {
      stock = json['stock_actual'] as int? ?? 0;
    }
    // 2. Luego intentar stock simple
    else if (json['stock'] != null) {
      stock = json['stock'] as int? ?? 0;
    }
    // 3. Luego intentar inventario.stock_actual (campo anidado)
    else if (json['inventario'] != null && json['inventario'] is Map) {
      final inventario = json['inventario'] as Map<String, dynamic>;
      stock = inventario['stock_actual'] as int? ?? 0;
    }
    // 4. Luego intentar cantidad
    else if (json['cantidad'] != null) {
      stock = json['cantidad'] as int? ?? 0;
    }

    // Obtener categoriaId de diferentes formas
    int catId = 0;
    if (json['categoria'] != null) {
      // Puede venir como int directo o como objeto {id: X}
      if (json['categoria'] is int) {
        catId = json['categoria'] as int;
      } else if (json['categoria'] is Map) {
        catId = json['categoria']['id'] as int? ?? 0;
      }
    }

    return Product(
      id: (json['id'] as int?) ?? 0,
      nombre: (json['nombre'] as String?) ?? '',
      codigo: (json['codigo'] as String?) ?? '',
      descripcion: json['descripcion'] as String?,
      categoriaId: catId,
      categoriaNombre: json['categoria_nombre'] as String?,
      precioVenta:
          double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0.0,
      activo: (json['activo'] as bool?) ?? true,
      destacado: (json['destacado'] as bool?) ?? false,
      stockActual: stock,
      imageUrl: json['imagen_url'] as String?,
    );
  }
}
