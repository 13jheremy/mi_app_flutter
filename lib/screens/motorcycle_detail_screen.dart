// ----------------------------------------
// lib/screens/motorcycle_detail_screen.dart
// Pantalla para mostrar los detalles de una moto específica.
// ----------------------------------------
import 'package:flutter/material.dart';
import '/models/motorcycle.dart';
import '/screens/maintenance_screen.dart';

class MotorcycleDetailScreen extends StatelessWidget {
  final Motorcycle motorcycle;

  const MotorcycleDetailScreen({super.key, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detalles de Moto',
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal con imagen y datos básicos
            _buildMainCard(theme),
            const SizedBox(height: 20),
            // Información del vehículo
            _buildVehicleInfo(theme),
            const SizedBox(height: 20),
            // Información de registro
            _buildRegistrationInfo(theme),
            const SizedBox(height: 30),
            // Botones de navegación
            _buildButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(ThemeData theme) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.two_wheeler,
                size: 60,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${motorcycle.marca} ${motorcycle.modelo}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Año ${motorcycle.anio}',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Vehículo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          theme,
          icon: Icons.badge,
          label: 'Placa',
          value: motorcycle.placa ?? 'No asignada',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.speed,
          label: 'Kilometraje',
          value: motorcycle.kilometraje != null
              ? '${motorcycle.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km'
              : 'No registrado',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.confirmation_number,
          label: 'Número de Chasis',
          value: motorcycle.numeroChasis ?? 'No registrado',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.settings,
          label: 'Número de Motor',
          value: motorcycle.numeroMotor ?? 'No registrado',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.palette,
          label: 'Color',
          value: motorcycle.color ?? 'No registrado',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.engineering,
          label: 'Cilindrada',
          value: motorcycle.cilindrada != null
              ? '${motorcycle.cilindrada} cc'
              : 'No registrada',
        ),
      ],
    );
  }

  Widget _buildRegistrationInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Registro',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          theme,
          icon: Icons.person_add,
          label: 'Registrado por',
          value: motorcycle.registradoPorNombre ?? 'No registrado',
        ),
        _buildInfoCard(
          theme,
          icon: Icons.calendar_today,
          label: 'Fecha de Registro',
          value: motorcycle.fechaRegistro != null
              ? _formatDate(motorcycle.fechaRegistro!)
              : 'No registrada',
        ),
        if (motorcycle.creadoPorNombre != null)
          _buildInfoCard(
            theme,
            icon: Icons.create,
            label: 'Creado por',
            value: motorcycle.creadoPorNombre ?? 'No registrado',
          ),
        if (motorcycle.fechaActualizacion != null)
          _buildInfoCard(
            theme,
            icon: Icons.update,
            label: 'Última Actualización',
            value: _formatDate(motorcycle.fechaActualizacion!),
          ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MaintenanceScreen(motorcycleId: motorcycle.id),
                ),
              );
            },
            icon: const Icon(Icons.build, size: 24),
            label: const Text(
              'Ver Mantenimientos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a Mis Motos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
