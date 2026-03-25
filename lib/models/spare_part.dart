// ----------------------------------------
// lib/models/spare_part.dart
// Modelo para la tabla RepuestoMantenimiento.
// ----------------------------------------
class SparePart {
  final int id;
  final int? productoId;
  final String productoNombre;
  final String? productoCodigo;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final bool eliminado;

  SparePart({
    required this.id,
    this.productoId,
    required this.productoNombre,
    this.productoCodigo,
    required this.cantidad,
    required this.precioUnitario,
    this.subtotal = 0.0,
    this.eliminado = false,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver el producto de diferentes formas
    int? productoId;
    String productoNombre = 'Producto sin nombre';
    String? productoCodigo;

    // Caso 1: tiene 'producto' como objeto
    if (json['producto'] != null && json['producto'] is Map) {
      final producto = json['producto'] as Map<String, dynamic>;
      productoId = producto['id'] as int?;
      productoNombre = producto['nombre'] ?? 'Producto sin nombre';
      productoCodigo = producto['codigo'] as String?;
    }
    // Caso 2: tiene 'producto_nombre' calculado
    else if (json['producto_nombre'] != null) {
      productoNombre = json['producto_nombre'] as String;
      productoCodigo = json['producto_codigo'] as String?;
    }
    // Caso 3: tiene 'producto' como ID
    else if (json['producto'] is int) {
      productoId = json['producto'] as int;
    }

    // El precio puede venir como precio_unitario o price
    double precioUnitario = 0.0;
    if (json['precio_unitario'] != null) {
      precioUnitario =
          double.tryParse(json['precio_unitario'].toString()) ?? 0.0;
    } else if (json['precio'] != null) {
      precioUnitario = double.tryParse(json['precio'].toString()) ?? 0.0;
    }

    // El subtotal
    double subtotal = 0.0;
    if (json['subtotal'] != null) {
      subtotal = double.tryParse(json['subtotal'].toString()) ?? 0.0;
    }

    return SparePart(
      id: json['id'] ?? 0,
      productoId: productoId,
      productoNombre: productoNombre,
      productoCodigo: productoCodigo,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
      eliminado: json['eliminado'] ?? false,
    );
  }

  // Obtener el tipo de repuesto basado en el nombre del producto
  String get tipo {
    final nombreLower = productoNombre.toLowerCase();
    if (nombreLower.contains('aceite')) return 'Aceite';
    if (nombreLower.contains('filtro')) return 'Filtro';
    if (nombreLower.contains('freno')) return 'Freno';
    if (nombreLower.contains('llanta') || nombreLower.contains('neumático'))
      return 'Neumático';
    if (nombreLower.contains('batería') || nombreLower.contains('bateria'))
      return 'Batería';
    if (nombreLower.contains('bujía') || nombreLower.contains('bujia'))
      return 'Bujía';
    if (nombreLower.contains('cadena')) return 'Cadena';
    return 'Otro';
  }
}
