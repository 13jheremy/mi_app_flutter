// ----------------------------------------
// lib/screens/motorcycles_screen.dart
// Pantalla para listar las motos del cliente.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/data_provider.dart';
import '/screens/motorcycle_detail_screen.dart';

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
                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  color: theme.cardColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.two_wheeler, color: theme.primaryColor),
                    ),
                    title: Text(
                      '${moto.marca} ${moto.modelo} (${moto.anio})',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Placa: ${moto.placa ?? 'N/A'} - Km: ${moto.kilometraje ?? 'N/A'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      // Navegación a la pantalla de detalles de la moto
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MotorcycleDetailScreen(motorcycle: moto),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
