// ----------------------------------------
// lib/widgets/status_badge.dart
// Widget reutilizable para mostrar estados con el estilo definido.
// ----------------------------------------
import 'package:flutter/material.dart';

enum StatusBadgeType { success, error, warning, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusBadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case StatusBadgeType.success:
        backgroundColor = isDarkMode ? Colors.green[900]! : Colors.green[100]!;
        textColor = isDarkMode ? Colors.green[200]! : Colors.green[800]!;
        break;
      case StatusBadgeType.error:
        backgroundColor = isDarkMode ? Colors.red[900]! : Colors.red[100]!;
        textColor = isDarkMode ? Colors.red[200]! : Colors.red[800]!;
        break;
      case StatusBadgeType.warning:
        backgroundColor = isDarkMode
            ? Colors.yellow[900]!
            : Colors.yellow[100]!;
        textColor = isDarkMode ? Colors.yellow[200]! : Colors.yellow[800]!;
        break;
      case StatusBadgeType.info:
        backgroundColor = isDarkMode ? Colors.blue[900]! : Colors.blue[100]!;
        textColor = isDarkMode ? Colors.blue[200]! : Colors.blue[800]!;
        break;
      case StatusBadgeType.neutral:
        backgroundColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
        textColor = isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999), // rounded-full
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12, // text-xs
          fontWeight: FontWeight.w500, // font-medium
        ),
      ),
    );
  }
}
