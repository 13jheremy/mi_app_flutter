// ----------------------------------------
// lib/screens/motorcycles_screen.dart
// Pantalla para listar las motos del cliente.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/data_provider.dart';
import '/screens/maintenance_screen.dart';

class MotorcyclesScreen extends StatelessWidget {
  const MotorcyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mis Motos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        elevation: 4.0,
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
      body: dataProvider.isLoadingData
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : dataProvider.errorMessage != null
          ? Center(
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
                    'Error al cargar las motos',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dataProvider.errorMessage!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dataProvider.fetchData(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : dataProvider.motorcycles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.two_wheeler,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes motos registradas.',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Añade una para empezar a gestionar tus mantenimientos!',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Contacta al taller para registrar tus motos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dataProvider.motorcycles.length,
              itemBuilder: (context, index) {
                final moto = dataProvider.motorcycles[index];
                return _buildMotorcycleCard(context, moto, theme);
              },
            ),
    );
  }

  Widget _buildMotorcycleCard(
    BuildContext context,
    dynamic moto,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.two_wheeler, color: theme.primaryColor),
        ),
        title: Text(
          '${moto.marca} ${moto.modelo}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Placa: ${moto.placa ?? 'N/A'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Año: ${moto.anio} - Km: ${moto.kilometraje ?? 'N/A'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de la moto
                _buildInfoRow(
                  theme,
                  Icons.info_outline,
                  'Marca',
                  moto.marca ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.model_training,
                  'Modelo',
                  moto.modelo ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.calendar_today,
                  'Año',
                  moto.anio?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.description,
                  'Placa',
                  moto.placa ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.speed,
                  'Kilometraje',
                  '${moto.kilometraje ?? 'N/A'} km',
                ),
                if (moto.chassis != null && moto.chassis!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    theme,
                    Icons.construction,
                    'Chasis',
                    moto.chassis!,
                  ),
                ],
                if (moto.motor != null && moto.motor!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, Icons.settings, 'Motor', moto.motor!),
                ],
                if (moto.color != null && moto.color!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, Icons.palette, 'Color', moto.color!),
                ],
                if (moto.cilindrada != null && moto.cilindrada != 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    theme,
                    Icons.local_gas_station,
                    'Cilindrada',
                    '${moto.cilindrada} cc',
                  ),
                ],
                const SizedBox(height: 16),
                // Botón para ver mantenimientos
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MaintenanceScreen(motorcycleId: moto.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Ver Mantenimientos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
