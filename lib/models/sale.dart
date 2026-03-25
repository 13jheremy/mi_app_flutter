// ----------------------------------------
// lib/models/sale.dart
// Modelo para la tabla Venta.
// ----------------------------------------
import '/models/sale_detail.dart';

class Sale {
  final int id;
  final DateTime fecha;
  final String estado;
  final String? clienteNombre;
  final String? clienteApellido;
  final String? clienteCedula;
  final double subtotal;
  final double impuesto;
  final double total;
  final double? pagado;
  final double? saldo;
  final int? registradoPor;
  final String? registradoPorNombre;
  final String? creadoPorNombre;
  final List<SaleDetail> detalles;
  final List<dynamic>? pagos;

  Sale({
    required this.id,
    required this.fecha,
    required this.estado,
    this.clienteNombre,
    this.clienteApellido,
    this.clienteCedula,
    required this.subtotal,
    required this.impuesto,
    required this.total,
    this.pagado,
    this.saldo,
    this.registradoPor,
    this.registradoPorNombre,
    this.creadoPorNombre,
    this.detalles = const [],
    this.pagos,
  });

  // Getter para método de pago (obtiene del primer pago si existe)
  String get metodoPago {
    if (pagos != null && pagos!.isNotEmpty) {
      final primerPago = pagos!.first;
      if (primerPago is Map && primerPago.containsKey('metodo')) {
        final metodo = primerPago['metodo'];
        if (metodo != null) {
          return metodo.toString();
        }
      }
    }
    return 'Sin especificar';
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    var detallesList = json['detalles'] as List? ?? [];
    List<SaleDetail> detalles = [];
    try {
      detalles = detallesList.map((i) => SaleDetail.fromJson(i)).toList();
    } catch (e) {
      // Si hay error al parsear detalles, usar lista vacía
      detalles = [];
    }

    return Sale(
      id: json['id'] ?? 0,
      fecha: json['fecha_venta'] != null
          ? DateTime.parse(json['fecha_venta'])
          : DateTime.now(),
      estado: (json['estado'] as String?) ?? 'pendiente',
      clienteNombre: json['cliente_nombre'] as String?,
      clienteApellido: json['cliente_apellido'] as String?,
      clienteCedula: json['cliente_cedula'] as String?,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      impuesto: double.tryParse(json['impuesto']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      pagado: double.tryParse(json['pagado']?.toString() ?? '0'),
      saldo: double.tryParse(json['saldo']?.toString() ?? '0'),
      registradoPor: json['registrado_por'] as int?,
      registradoPorNombre: json['registrado_por_nombre'] as String?,
      creadoPorNombre: json['creado_por_nombre'] as String?,
      detalles: detalles,
      pagos: json['pagos'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_venta': fecha.toIso8601String(),
      'estado': estado,
      'cliente_nombre': clienteNombre,
      'cliente_apellido': clienteApellido,
      'cliente_cedula': clienteCedula,
      'subtotal': subtotal,
      'impuesto': impuesto,
      'total': total,
      'pagado': pagado,
      'saldo': saldo,
      'registrado_por': registradoPor,
      'registrado_por_nombre': registradoPorNombre,
      'creado_por_nombre': creadoPorNombre,
      'detalles': detalles.map((d) => d.toJson()).toList(),
      'pagos': pagos,
    };
  }
}
