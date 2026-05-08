import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    required this.titulo,
    this.descricao,
    this.conteudo,
    this.campos = const <Widget>[],
    this.acoes = const <Widget>[],
    this.larguraMaxima = 520,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 20),
    this.espacamentoCorpo = 12,
    this.espacamentoAcoes = 10,
  }) : assert(larguraMaxima > 0),
       assert(espacamentoCorpo >= 0),
       assert(espacamentoAcoes >= 0);

  final String titulo;
  final String? descricao;
  final Widget? conteudo;
  final List<Widget> campos;
  final List<Widget> acoes;
  final double larguraMaxima;
  final EdgeInsetsGeometry padding;
  final double espacamentoCorpo;
  final double espacamentoAcoes;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final tamanhoTela = MediaQuery.sizeOf(context);
    final margemHorizontal = tamanhoTela.width < 420 ? 16.0 : 24.0;
    final margemVertical = tamanhoTela.height < 520 ? 16.0 : 24.0;
    final corpo = _criarCorpo(tema);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: margemHorizontal,
        vertical: margemVertical,
      ),
      backgroundColor: cores.surfaceContainerHighest,
      surfaceTintColor: cores.surfaceTint,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cores.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: larguraMaxima,
          maxHeight: tamanhoTela.height - (margemVertical * 2),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titulo,
                style: tema.textTheme.titleLarge?.copyWith(
                  color: cores.onSurface,
                ),
              ),
              if (corpo.isNotEmpty) ...[
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _comEspacamento(corpo, espacamentoCorpo),
                    ),
                  ),
                ),
              ],
              if (acoes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: espacamentoAcoes,
                    runSpacing: espacamentoAcoes,
                    children: acoes,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _criarCorpo(ThemeData tema) {
    final cores = tema.colorScheme;
    final descricaoNormalizada = descricao?.trim();

    return [
      if (descricaoNormalizada != null && descricaoNormalizada.isNotEmpty)
        Text(
          descricaoNormalizada,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: cores.onSurfaceVariant,
          ),
        ),
      ?conteudo,
      ...campos,
    ];
  }
}

Future<T?> showCustomAlertDialog<T>({
  required BuildContext context,
  required String titulo,
  String? descricao,
  Widget? conteudo,
  List<Widget> campos = const <Widget>[],
  List<Widget> acoes = const <Widget>[],
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (context) => CustomAlertDialog(
      titulo: titulo,
      descricao: descricao,
      conteudo: conteudo,
      campos: campos,
      acoes: acoes,
    ),
  );
}

List<Widget> _comEspacamento(List<Widget> widgets, double espacamento) {
  if (widgets.length < 2) return widgets;

  return [
    for (var indice = 0; indice < widgets.length; indice++) ...[
      if (indice > 0) SizedBox(height: espacamento),
      widgets[indice],
    ],
  ];
}
