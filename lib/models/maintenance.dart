// ----------------------------------------
// lib/models/maintenance.dart
// Modelo para la tabla Mantenimiento.
// ----------------------------------------
import '/models/spare_part.dart';
import '/models/service.dart';

class Maintenance {
  final int id;
  final int motoId;
  final String? motoPlaca;
  final String? motoMarca;
  final String? motoModelo;
  final Service service;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String estado;
  final double costoTotal;
  final String? observaciones;
  final List<SparePart> repuestos;
  final String? descripcionProblema;
  final String? diagnostico;

  Maintenance({
    required this.id,
    required this.motoId,
    this.motoPlaca,
    this.motoMarca,
    this.motoModelo,
    required this.service,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
    required this.costoTotal,
    this.observaciones,
    this.repuestos = const [],
    this.descripcionProblema,
    this.diagnostico,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    // Parsear repuestos - el backend devuelve 'repuestos' como lista de objetos
    List<SparePart> repuestosList = [];
    if (json['repuestos'] != null && json['repuestos'] is List) {
      try {
        repuestosList = (json['repuestos'] as List)
            .map((r) => SparePart.fromJson(r))
            .toList();
      } catch (e) {
        // Si hay error al parsear repuestos, usar lista vacía
        repuestosList = [];
      }
    }

    // Parsear el servicio - el backend puede devolver:
    // 1. 'detalles' -> lista de DetalleMantenimiento con 'servicio' y 'servicio_data'
    // 2. 'servicio' -> objeto directo del servicio (menos común)
    Service servicioParseado;

    // Intentar obtener el servicio de los detalles
    if (json['detalles'] != null &&
        json['detalles'] is List &&
        (json['detalles'] as List).isNotEmpty) {
      // Usar el primer detalle para obtener el servicio
      final primerDetalle =
          (json['detalles'] as List)[0] as Map<String, dynamic>;
      servicioParseado = Service.fromJson(primerDetalle);
    } else if (json['servicio'] != null) {
      // Caso directo: tiene campo 'servicio'
      if (json['servicio'] is Map) {
        servicioParseado = Service.fromJson(
          json['servicio'] as Map<String, dynamic>,
        );
      } else if (json['servicio'] is int) {
        // Solo tiene el ID del servicio
        servicioParseado = Service(
          id: json['servicio'] as int,
          categoriaNombre: json['categoria_servicio'] ?? 'Sin categoría',
          descripcion: json['descripcion'] ?? 'Sin descripción',
        );
      } else {
        servicioParseado = Service.fromJson(json);
      }
    } else {
      // Por defecto, crear un servicio genérico
      servicioParseado = Service(
        id: 0,
        categoriaNombre: json['categoria_servicio'] ?? 'Sin categoría',
        descripcion:
            json['descripcion_problema'] ??
            json['diagnostico'] ??
            'Sin descripción',
      );
    }

    // Extraer información de la moto
    int motoId = 0;
    String? motoPlaca;
    String? motoMarca;
    String? motoModelo;

    // Caso 1: tiene 'moto_data' (objeto completo de la moto)
    if (json['moto_data'] != null && json['moto_data'] is Map) {
      final motoData = json['moto_data'] as Map<String, dynamic>;
      motoId = motoData['id'] ?? 0;
      motoPlaca = motoData['placa'];
      motoMarca = motoData['marca'];
      motoModelo = motoData['modelo'];
    }
    // Caso 2: tiene 'moto' como ID o objeto
    else if (json['moto'] != null) {
      if (json['moto'] is int) {
        motoId = json['moto'] as int;
      } else if (json['moto'] is Map) {
        final moto = json['moto'] as Map<String, dynamic>;
        motoId = moto['id'] ?? 0;
      }
      // Campos de moto sueltos
      motoPlaca = json['moto_placa'];
      motoMarca = json['moto_marca'];
      motoModelo = json['moto_modelo'];
    }
    // Caso 3: tiene campos sueltos de moto
    else {
      motoPlaca = json['moto_placa'];
      motoMarca = json['moto_marca'];
      motoModelo = json['moto_modelo'];
    }

    // Parsear las fechas - el backend usa 'fecha_ingreso' y 'fecha_entrega'
    DateTime fechaInicioParseada;
    DateTime? fechaFinParseada;

    if (json['fecha_ingreso'] != null) {
      fechaInicioParseada = DateTime.parse(json['fecha_ingreso']);
    } else if (json['fecha_inicio'] != null) {
      fechaInicioParseada = DateTime.parse(json['fecha_inicio']);
    } else {
      fechaInicioParseada = DateTime.now();
    }

    if (json['fecha_entrega'] != null) {
      fechaFinParseada = DateTime.parse(json['fecha_entrega']);
    } else if (json['fecha_fin'] != null) {
      fechaFinParseada = DateTime.parse(json['fecha_fin']);
    }

    // El costo total puede venir como 'total' o 'costo_total'
    double costoTotalParseado = 0.0;
    if (json['total'] != null) {
      costoTotalParseado = double.tryParse(json['total'].toString()) ?? 0.0;
    } else if (json['costo_total'] != null) {
      costoTotalParseado =
          double.tryParse(json['costo_total'].toString()) ?? 0.0;
    }

    return Maintenance(
      id: json['id'] ?? 0,
      motoId: motoId,
      motoPlaca: motoPlaca,
      motoMarca: motoMarca,
      motoModelo: motoModelo,
      service: servicioParseado,
      fechaInicio: fechaInicioParseada,
      fechaFin: fechaFinParseada,
      estado: (json['estado'] as String?) ?? 'pendiente',
      costoTotal: costoTotalParseado,
      observaciones: json['observaciones'] as String?,
      repuestos: repuestosList,
      descripcionProblema: json['descripcion_problema'] as String?,
      diagnostico: json['diagnostico'] as String?,
    );
  }
}
