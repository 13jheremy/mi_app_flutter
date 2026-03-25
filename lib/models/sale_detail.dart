// ----------------------------------------
// lib/models/sale_detail.dart
// Modelo para la tabla DetalleVenta.
// ----------------------------------------
class SaleDetail {
  final int id;
  final String productoNombre;
  final String? productoImagen;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  SaleDetail({
    required this.id,
    required this.productoNombre,
    this.productoImagen,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      id: json['id'] ?? 0,
      productoNombre:
          (json['producto_nombre'] as String?) ?? 'Producto sin nombre',
      productoImagen: json['producto_imagen'] as String?,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario:
          double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_nombre': productoNombre,
      'producto_imagen': productoImagen,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
