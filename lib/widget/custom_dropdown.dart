import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.campoKey,
    required this.valorInicial,
    required this.hintText,
    required this.prefixIcon,
    required this.opcoes,
    required this.rotuloOpcao,
    required this.onChanged,
    this.itemBuilder,
    this.habilitado = true,
  });

  final Key campoKey;
  final T? valorInicial;
  final String hintText;
  final IconData prefixIcon;
  final List<T> opcoes;
  final String Function(T opcao) rotuloOpcao;
  final ValueChanged<T?> onChanged;
  final Widget Function(T opcao)? itemBuilder;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final corDesabilitada = cores.onSurface.withValues(alpha: 0.38);
    final estiloTexto = tema.textTheme.bodyMedium?.copyWith(
      color: habilitado ? cores.onSurface : corDesabilitada,
    );

    return DropdownButtonFormField<T>(
      key: campoKey,
      initialValue: valorInicial,
      isExpanded: true,
      dropdownColor: cores.surfaceContainer,
      borderRadius: BorderRadius.circular(4),
      iconEnabledColor: cores.onSurfaceVariant,
      iconDisabledColor: corDesabilitada,
      style: estiloTexto,
      decoration: _decoracao(
        tema: tema,
        hintText: hintText,
        prefixIcon: prefixIcon,
        habilitado: habilitado,
      ),
      items: opcoes
          .map(
            (opcao) => DropdownMenuItem<T>(
              value: opcao,
              child:
                  itemBuilder?.call(opcao) ??
                  Text(
                    rotuloOpcao(opcao),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: cores.onSurface,
                    ),
                  ),
            ),
          )
          .toList(growable: false),
      onChanged: habilitado ? onChanged : null,
    );
  }
}

InputDecoration _decoracao({
  required ThemeData tema,
  required String hintText,
  required IconData prefixIcon,
  required bool habilitado,
}) {
  final cores = tema.colorScheme;
  final corBorda = habilitado
      ? cores.outlineVariant
      : cores.outlineVariant.withValues(alpha: 0.56);
  final corConteudo = habilitado
      ? cores.onSurfaceVariant
      : cores.onSurface.withValues(alpha: 0.38);
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: corBorda),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: tema.textTheme.bodyMedium?.copyWith(color: corConteudo),
    prefixIcon: Icon(prefixIcon, size: 20, color: corConteudo),
    filled: true,
    fillColor: habilitado
        ? cores.surfaceContainer
        : cores.surfaceContainer.withValues(alpha: 0.64),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: cores.primary, width: 1.4),
    ),
  );
}
