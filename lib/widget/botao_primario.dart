import 'package:flutter/material.dart';

class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.onPressed,
    this.texto = 'Entrar',
    this.textoCarregando = 'Entrando',
    this.carregando = false,
    this.icone = Icons.login_rounded,
  });

  final VoidCallback? onPressed;
  final String texto;
  final String textoCarregando;
  final bool carregando;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return FilledButton.icon(
      onPressed: carregando ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        backgroundColor: cores.primary,
        disabledBackgroundColor: cores.primary.withValues(alpha: 0.42),
        foregroundColor: cores.onPrimary,
        disabledForegroundColor: cores.onPrimary.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: tema.textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      icon: carregando
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cores.onPrimary,
              ),
            )
          : Icon(icone, size: 18),
      label: Text(carregando ? textoCarregando : texto, style: TextStyle(fontSize: 10),),
    );
  }
}
