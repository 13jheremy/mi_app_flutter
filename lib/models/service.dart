// ----------------------------------------
// lib/models/service.dart
// Modelo para la tabla Servicio.
// ----------------------------------------
class Service {
  final int id;
  final String categoriaNombre;
  final String descripcion;
  final String? nombre;

  Service({
    required this.id,
    required this.categoriaNombre,
    required this.descripcion,
    this.nombre,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver el servicio de dos formas:
    // 1. Como objeto completo en 'servicio' o 'servicio_data'
    // 2. O como campos sueltos en DetalleMantenimiento

    // Intentar obtener el nombre del servicio
    String nombre = '';
    String descripcion = '';
    String categoriaNombre = 'Sin categoría';

    // Caso 1: tiene 'servicio_data' (objeto completo del servicio)
    if (json['servicio_data'] != null && json['servicio_data'] is Map) {
      final servicioData = json['servicio_data'] as Map<String, dynamic>;
      nombre = servicioData['nombre'] ?? '';
      descripcion = servicioData['descripcion'] ?? '';
      if (servicioData['categoria_servicio'] != null &&
          servicioData['categoria_servicio'] is Map) {
        categoriaNombre =
            servicioData['categoria_servicio']['nombre'] ?? 'Sin categoría';
      }
    }
    // Caso 2: tiene 'servicio' como objeto
    else if (json['servicio'] != null && json['servicio'] is Map) {
      final servicio = json['servicio'] as Map<String, dynamic>;
      nombre = servicio['nombre'] ?? '';
      descripcion = servicio['descripcion'] ?? '';
      if (servicio['categoria_servicio'] != null &&
          servicio['categoria_servicio'] is Map) {
        categoriaNombre =
            servicio['categoria_servicio']['nombre'] ?? 'Sin categoría';
      }
    }
    // Caso 3: tiene 'servicio_nombre' y 'categoria_servicio' directamente
    else {
      nombre = json['servicio_nombre'] ?? '';
      descripcion = json['descripcion'] ?? '';
      categoriaNombre = json['categoria_servicio'] ?? 'Sin categoría';
    }

    return Service(
      id: json['servicio'] is int ? json['servicio'] : (json['id'] ?? 0),
      categoriaNombre: categoriaNombre,
      descripcion: descripcion.isNotEmpty
          ? descripcion
          : (json['descripcion'] ?? 'Sin descripción'),
      nombre: nombre.isNotEmpty ? nombre : null,
    );
  }
}
