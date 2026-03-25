// ----------------------------------------
// lib/screens/reminders_screen.dart
// Pantalla para listar los recordatorios.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/data_provider.dart';
import '/models/reminder.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Próximos Recordatorios'),
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
                    'Error al cargar recordatorios',
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
          : dataProvider.reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recordatorios próximos.',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '¡Mantente al día con tus mantenimientos para recibir alertas!',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dataProvider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = dataProvider.reminders[index];
                return _buildReminderCard(reminder, theme);
              },
            ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, ThemeData theme) {
    // Determinar el color basado en el estado
    Color estadoColor;
    IconData estadoIcon;

    if (reminder.estaVencido) {
      estadoColor = Colors.red;
      estadoIcon = Icons.warning;
    } else if (reminder.esProximo) {
      estadoColor = Colors.orange;
      estadoIcon = Icons.schedule;
    } else {
      estadoColor = theme.primaryColor;
      estadoIcon = Icons.notifications_active;
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
          (reminder.categoria != null && reminder.categoria!.isNotEmpty)
              ? reminder.categoria!
              : 'Recordatorio',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.motoPlaca != null && reminder.motoPlaca!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  reminder.motoPlaca!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${DateFormat('dd-MM-yyyy').format(reminder.fechaRecordatorio)}',
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
                // Tipo de recordatorio
                if (reminder.tipo != null && reminder.tipo!.isNotEmpty) ...[
                  Text(
                    'Tipo: ${reminder.tipo}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],

                // Mensaje
                if (reminder.mensaje != null &&
                    reminder.mensaje!.isNotEmpty) ...[
                  Text(
                    'Mensaje: ${reminder.mensaje}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],

                // Kilómetros próximos
                if (reminder.kmProximo != null) ...[
                  Row(
                    children: [
                      Icon(Icons.speed, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Próximo servicio a ${reminder.kmProximo} km',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Estado de alerta
                if (reminder.alerta) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 14,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Próximo a vencer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
