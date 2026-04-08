// ----------------------------------------
// lib/screens/dashboard_screen.dart
// Pantalla principal del cliente con resúmenes modernizada y mejorada.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/providers/data_provider.dart';
import '/screens/profile_screen.dart';
import '/screens/motorcycles_screen.dart';
import '/screens/maintenance_screen.dart';
import '/screens/reminders_screen.dart';
import '/screens/sales_screen.dart';
import '/screens/product_catalog_screen.dart'; // Importar nueva pantalla
import '/main.dart'; // Para acceder al ThemeModeChanger

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carga los datos al iniciar la pantalla.
    Future.microtask(
      () => Provider.of<DataProvider>(context, listen: false).fetchData(),
    );
  }

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeModeChanger = Provider.of<ThemeModeChanger>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 4.0, // Añade una ligera sombra
        foregroundColor: Colors.white, // Color de los íconos y texto
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // El color del texto es blanco
          ),
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
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeModeChanger.changeTheme(
                isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
            tooltip: isDarkMode
                ? 'Cambiar a modo claro'
                : 'Cambiar a modo oscuro',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.nombreCompleto ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.correoElectronico ?? 'Correo',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text('Perfil', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.two_wheeler,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text('Mis Motos', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MotorcyclesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.build,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text('Mantenimientos', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MaintenanceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.alarm,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text('Recordatorios', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RemindersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.receipt,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text(
                'Historial de Ventas',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SalesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_bag,
                color: theme.textTheme.bodyLarge?.color,
              ),
              title: Text(
                'Catálogo de Productos',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductCatalogScreen(),
                  ),
                );
              },
            ),
          ],
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
                    'Error al cargar datos',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${user?.nombres ?? 'Usuario'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Bienvenido de vuelta',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resumen
                  Text('Resumen', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildSummaryCard(
                        icon: Icons.two_wheeler,
                        title: 'Motos',
                        value: dataProvider.motorcycles.length.toString(),
                        subtitle: 'Registradas',
                        iconColor: theme.primaryColor,
                      ),
                      _buildSummaryCard(
                        icon: Icons.build,
                        title: 'Mantenimientos',
                        value: dataProvider.maintenances.length.toString(),
                        subtitle: 'Realizados',
                        iconColor: Colors.green[600]!,
                      ),
                      _buildSummaryCard(
                        icon: Icons.alarm,
                        title: 'Recordatorios',
                        value: dataProvider.reminders.length.toString(),
                        subtitle: 'Pendientes',
                        iconColor: Colors.red[600]!,
                      ),
                      _buildSummaryCard(
                        icon: Icons.attach_money,
                        title: 'Ventas',
                        value: dataProvider.sales.length.toString(),
                        subtitle: 'Facturas',
                        iconColor: Colors.deepPurple[600]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recordatorios
                  Text(
                    'Próximos Recordatorios',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (dataProvider.reminders.isEmpty)
                    Center(
                      child: Text(
                        'No hay recordatorios próximos.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...dataProvider.reminders.take(3).map((reminder) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isDarkMode ? Colors.black : Colors.black)
                                  .withOpacity(isDarkMode ? 0.2 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[600]!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.red[600],
                            ),
                          ),
                          title: Text(
                            reminder.mensaje?.isNotEmpty == true
                                ? reminder.mensaje!
                                : reminder.categoria ?? 'Recordatorio',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha: ${reminder.fechaRecordatorio.toLocal().toIso8601String().substring(0, 10)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (reminder.motoPlaca != null && reminder.motoPlaca!.isNotEmpty)
                                Text(
                                  'Moto: ${reminder.motoPlaca}',
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final cardBgColor = theme.cardColor;
    final textColor = theme.textTheme.titleLarge?.color;
    final subtitleColor = theme.textTheme.bodyMedium?.color;
    final shadowColor = (isDarkMode ? Colors.black : Colors.black).withOpacity(
      isDarkMode ? 0.2 : 0.05,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor?.withOpacity(0.8),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: subtitleColor),
            ),
          ],
        ),
      ),
    );
  }
}
