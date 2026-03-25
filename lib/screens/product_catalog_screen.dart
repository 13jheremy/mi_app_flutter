// ----------------------------------------
// lib/screens/product_catalog_screen.dart
// Pantalla para listar y buscar productos.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/product_provider.dart';
import '/widgets/status_badge.dart'; // Para el estilo de badges
import '/providers/category_provider.dart'; // Importar el nuevo proveedor

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Cargar productos y categorías al iniciar la pantalla
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<ProductProvider>(context, listen: false).searchProducts(query);
  }

  void _onCategoryFilterChanged(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    Provider.of<ProductProvider>(
      context,
      listen: false,
    ).filterProductsByCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
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
      body: Column(
        children: [
          // Buscador y Categorías
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 🔎 Buscador
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Buscar producto',
                    hintText: 'Nombre o código',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 16),

                // 🎨 Filtro de categorías en forma de chips bonitos
                categoryProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : categoryProvider.errorMessage != null
                    ? Text(
                        'Error al cargar categorías: ${categoryProvider.errorMessage}',
                        style: TextStyle(color: theme.colorScheme.error),
                      )
                    : SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: const Text("Todas"),
                                selected: _selectedCategory == null,
                                onSelected: (_) =>
                                    _onCategoryFilterChanged(null),
                              ),
                            ),
                            ...categoryProvider.categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(category.nombre),
                                  selected:
                                      _selectedCategory ==
                                      category.id.toString(),
                                  onSelected: (_) => _onCategoryFilterChanged(
                                    category.id.toString(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
              ],
            ),
          ),

          // 🛒 Lista de productos
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.errorMessage != null
                ? Center(
                    child: Text(
                      'Error: ${productProvider.errorMessage}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  )
                : productProvider.filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron productos.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.filteredProducts[index];

                      // Determine availability based on stock and active status
                      final bool hasStock = product.stockActual > 0;
                      final bool isActive = product.activo;

                      final String availabilityText = !isActive
                          ? 'Inactivo'
                          : hasStock
                          ? 'Disponible (${product.stockActual})'
                          : 'Agotado';
                      final StatusBadgeType availabilityType = !isActive
                          ? StatusBadgeType.warning
                          : hasStock
                          ? StatusBadgeType.success
                          : StatusBadgeType.error;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: theme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nombre,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.descripcion ?? 'Sin descripción',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Precio: \$${product.precioVenta.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  StatusBadge(
                                    text: availabilityText,
                                    type: availabilityType,
                                  ),
                                ],
                              ),
                              if (product.destacado) ...[
                                const SizedBox(height: 8),
                                StatusBadge(
                                  text: 'Destacado',
                                  type: StatusBadgeType.warning,
                                ),
                              ],
                              if (product.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.contain,
                                    height: 180,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
