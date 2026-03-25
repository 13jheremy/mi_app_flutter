// ----------------------------------------
// lib/widgets/form_field_widget.dart
// Widget reutilizable para campos de formulario con el estilo definido.
// ----------------------------------------
import 'package:flutter/material.dart';

class FormFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final String? dropdownValue;
  final void Function(String?)? onDropdownChanged;

  const FormFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (dropdownItems != null) {
      return DropdownButtonFormField<String>(
        value: dropdownValue,
        items: dropdownItems,
        onChanged: onDropdownChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // rounded-md
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode
              ? Colors.grey[700]
              : Colors.grey[100], // bg-white dark:bg-gray-700
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // px-3 py-2
          enabled: enabled,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
          ),
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        validator: validator,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[900]),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.grey[900],
      ), // text-gray-900 dark:text-gray-100
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // rounded-md
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[700]
            : Colors.grey[100], // bg-white dark:bg-gray-700
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // px-3 py-2
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
        ), // placeholder-gray-500 dark:placeholder-gray-400
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ), // text-gray-700 dark:text-gray-300
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                theme.primaryColor, // focus:ring-blue-500 focus:border-blue-500
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red, // border-red-300
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red, // border-red-300
            width: 2,
          ),
        ),
      ),
    );
  }
}
