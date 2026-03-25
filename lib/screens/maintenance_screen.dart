// ----------------------------------------
// lib/screens/maintenance_screen.dart
// Pantalla para listar los mantenimientos.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/maintenance.dart';
import '/services/data_service.dart';
import '/providers/data_provider.dart'; // Importar DataProvider
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatefulWidget {
  final int? motorcycleId; // Opcional, para filtrar por moto

  const MaintenanceScreen({super.key, this.motorcycleId});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Future<List<Maintenance>>? _maintenancesFuture;

  @override
  void initState() {
    super.initState();
    _loadMaintenances();
  }

  void _loadMaintenances() {
    if (widget.motorcycleId != null) {
      // Cargar mantenimientos de una moto específica
      _maintenancesFuture = DataService.fetchMaintenances(widget.motorcycleId!);
    } else {
      // Usar los mantenimientos ya cargados en DataProvider
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      _maintenancesFuture = Future.value(dataProvider.maintenances);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.motorcycleId != null
              ? 'Historial de Mantenimiento'
              : 'Mis Mantenimientos',
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Maintenance>>(
        future: _maintenancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar mantenimientos',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadMaintenances();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay mantenimientos registrados.',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando realices un mantenimiento, aparecerá aquí.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final mantenimientos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: mantenimientos.length,
              itemBuilder: (context, index) {
                final mantenimiento = mantenimientos[index];
                return _buildMaintenanceCard(mantenimiento, theme);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMaintenanceCard(Maintenance mantenimiento, ThemeData theme) {
    // Determinar el color del estado
    Color estadoColor;
    IconData estadoIcon;

    switch (mantenimiento.estado.toLowerCase()) {
      case 'completado':
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle;
        break;
      case 'en_proceso':
        estadoColor = Colors.orange;
        estadoIcon = Icons.engineering;
        break;
      case 'pendiente':
        estadoColor = Colors.blue;
        estadoIcon = Icons.schedule;
        break;
      case 'cancelado':
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel;
        break;
      default:
        estadoColor = Colors.grey;
        estadoIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(estadoIcon, color: estadoColor),
        ),
        title: Text(
          mantenimiento.service.nombre ?? mantenimiento.service.categoriaNombre,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mantenimiento.motoPlaca != null ||
                mantenimiento.motoMarca != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${mantenimiento.motoMarca ?? ''} ${mantenimiento.motoModelo ?? ''} ${mantenimiento.motoPlaca ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${DateFormat('dd-MM-yyyy').format(mantenimiento.fechaInicio)} - ${mantenimiento.estado}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del servicio
                Text(
                  'Servicio: ${mantenimiento.service.categoriaNombre}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (mantenimiento.service.descripcion.isNotEmpty &&
                    mantenimiento.service.descripcion != 'Sin descripción') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Descripción: ${mantenimiento.service.descripcion}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],

                const SizedBox(height: 8),

                // Costo total
                Row(
                  children: [
                    Text(
                      'Costo Total: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${mantenimiento.costoTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Descripción del problema
                if (mantenimiento.descripcionProblema != null &&
                    mantenimiento.descripcionProblema!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Problema Reportado: ${mantenimiento.descripcionProblema}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],

                // Diagnóstico
                if (mantenimiento.diagnostico != null &&
                    mantenimiento.diagnostico!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Diagnóstico: ${mantenimiento.diagnostico}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],

                // Observaciones
                if (mantenimiento.observaciones != null &&
                    mantenimiento.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Observaciones: ${mantenimiento.observaciones}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],

                // Repuestos utilizados
                if (mantenimiento.repuestos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Repuestos Utilizados:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...mantenimiento.repuestos.map((repuesto) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${repuesto.productoNombre} x ${repuesto.cantidad}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${(repuesto.precioUnitario * repuesto.cantidad).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
