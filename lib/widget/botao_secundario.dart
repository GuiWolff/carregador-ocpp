import 'package:flutter/material.dart';

class BotaoSecundario extends StatelessWidget {
  const BotaoSecundario({
    super.key,
    required this.onPressed,
    required this.texto,
    this.icone,
  });

  const BotaoSecundario.google({
    super.key,
    required this.onPressed,
    this.texto = 'Continuar com Google',
  }) : icone = const _GoogleIcone();

  final VoidCallback? onPressed;
  final String texto;
  final Widget? icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        backgroundColor: cores.surfaceContainer,
        foregroundColor: cores.onSurface,
        disabledForegroundColor: cores.onSurfaceVariant,
        side: BorderSide(color: cores.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: tema.textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      icon: icone ?? const SizedBox.shrink(),
      label: Text(texto),
    );
  }
}

class _GoogleIcone extends StatelessWidget {
  const _GoogleIcone();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cores.outlineVariant),
      ),
      child: Text(
        'G',
        style: tema.textTheme.labelMedium?.copyWith(
          color: cores.primary,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
