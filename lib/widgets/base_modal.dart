// ----------------------------------------
// lib/widgets/base_modal.dart
// Widget reutilizable para modales con el estilo definido.
// ----------------------------------------
import 'package:flutter/material.dart';

class BaseModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool isLoading;
  final String size; // 'sm', 'md', 'lg', 'xl'

  const BaseModal({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.isLoading = false,
    this.size = 'md',
  });

  double _getMaxWidth(String size) {
    switch (size) {
      case 'sm':
        return 400.0; // max-w-md
      case 'md':
        return 500.0; // max-w-lg
      case 'lg':
        return 700.0; // max-w-2xl
      case 'xl':
        return 900.0; // max-w-4xl
      default:
        return 500.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxWidth(size)),
          child: Material(
            color: isDarkMode
                ? Colors.grey[800]
                : Colors.white, // bg-white dark:bg-gray-800
            borderRadius: BorderRadius.circular(16), // rounded-lg
            elevation: 8, // shadow-xl
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0), // p-6
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(child: content),
                      if (actions != null && actions!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!
                              .map(
                                (action) => Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: action,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: (isDarkMode ? Colors.grey[800] : Colors.white)
                          ?.withAlpha(
                            (0.7 * 255).round(),
                          ), // reemplazo seguro de withOpacity
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
