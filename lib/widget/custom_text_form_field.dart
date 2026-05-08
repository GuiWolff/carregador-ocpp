import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.campoKey,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
  });

  final Key campoKey;
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return TextField(
      key: campoKey,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: _decoracao(
        tema: tema,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

InputDecoration _decoracao({
  required ThemeData tema,
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  final cores = tema.colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: cores.outlineVariant),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: tema.textTheme.bodyMedium?.copyWith(
      color: cores.onSurfaceVariant,
    ),
    prefixIcon: Icon(prefixIcon, size: 20, color: cores.onSurfaceVariant),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: cores.surfaceContainer,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: cores.primary, width: 1.4),
    ),
  );
}
