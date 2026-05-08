import 'package:flutter/material.dart';

const _corDestaque = Color(0xFFA2FF6C);
const _corConteudoDestaque = Color(0xFF10231C);
const _corDestaqueDesabilitado = Color(0xFFD8FFC4);

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
    return FilledButton.icon(
      onPressed: carregando ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        backgroundColor: _corDestaque,
        disabledBackgroundColor: _corDestaqueDesabilitado,
        foregroundColor: _corConteudoDestaque,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
      icon: carregando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _corConteudoDestaque,
              ),
            )
          : Icon(icone, size: 18),
      label: Text(carregando ? textoCarregando : texto),
    );
  }
}
