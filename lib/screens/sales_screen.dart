// ----------------------------------------
// lib/screens/sales_screen.dart
// Pantalla para el historial de ventas.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/data_provider.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
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
                    'Error al cargar el historial de ventas',
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
          : dataProvider.sales.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay compras registradas.',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Realiza tu primera compra y aparecerá aquí!',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dataProvider.sales.length,
              itemBuilder: (context, index) {
                final venta = dataProvider.sales[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: theme.cardColor,
                  child: ExpansionTile(
                    leading: Icon(Icons.receipt, color: Colors.green[600]),
                    title: Text(
                      'Factura #${venta.id} - Total: \$${venta.total.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Fecha: ${DateFormat('dd-MM-yyyy').format(venta.fecha)}',
                      style: theme.textTheme.bodyMedium,
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
                            if (venta.registradoPorNombre != null)
                              Text(
                                'Registrado por: ${venta.registradoPorNombre}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (venta.creadoPorNombre != null)
                              Text(
                                'Creado por: ${venta.creadoPorNombre}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            Text(
                              'Estado: ${venta.estado}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Método de Pago: ${venta.metodoPago}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (venta.detalles.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Productos:',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...venta.detalles.map((detalle) {
                                return ListTile(
                                  dense: true,
                                  leading: detalle.productoImagen != null
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            detalle.productoImagen!,
                                          ),
                                          onBackgroundImageError: (_, __) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 20,
                                              ),
                                        )
                                      : const CircleAvatar(
                                          radius: 20,
                                          child: Icon(
                                            Icons.inventory,
                                            size: 20,
                                          ),
                                        ),
                                  title: Text(
                                    '${detalle.productoNombre} x ${detalle.cantidad}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Precio: \$${detalle.precioUnitario.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        'Subtotal: \$${detalle.subtotal.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
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
              },
            ),
    );
  }
}
