import 'package:flutter/material.dart';

class LabeledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onIconTap;

  const LabeledTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : GestureDetector(onTap: onIconTap, child: Icon(icon, color: Colors.deepPurple)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.deepPurple.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}

class LabeledDropdownField extends StatelessWidget {
  final List<String> items;
  final String label;
  final TextEditingController controller;
  final bool required;
  final bool readOnly;

  const LabeledDropdownField({
    super.key,
    required this.items,
    required this.label,
    required this.controller,
    this.required = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: controller.text.isNotEmpty ? controller.text : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: readOnly ? null : (value) => controller.text = value ?? '',
      validator: required && !readOnly
          ? (value) {
              if (value == null || value.isEmpty) return 'This field is required';
              return null;
            }
          : null,
    );
  }
}


