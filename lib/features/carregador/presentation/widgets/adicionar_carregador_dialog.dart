import 'package:flutter/material.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/observable/obx.dart';
import 'package:simulador_ocpp/observable/rx.dart';
import 'package:simulador_ocpp/widget/botao_primario.dart';
import 'package:simulador_ocpp/widget/botao_secundario.dart';
import 'package:simulador_ocpp/widget/custom_alert_dialog.dart';
import 'package:simulador_ocpp/widget/custom_dropdown.dart';
import 'package:simulador_ocpp/widget/custom_text_form_field.dart';

Future<CarregadorConfigurado?> abrirDialogoAdicionarCarregador({
  required BuildContext context,
  Iterable<String> idsExistentes = const <String>[],
  bool barrierDismissible = true,
}) async {
  return showDialog<CarregadorConfigurado>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) =>
        _AdicionarCarregadorDialog(idsExistentes: idsExistentes),
  );
}

class _AdicionarCarregadorDialog extends StatefulWidget {
  const _AdicionarCarregadorDialog({required this.idsExistentes});

  final Iterable<String> idsExistentes;

  @override
  State<_AdicionarCarregadorDialog> createState() =>
      _AdicionarCarregadorDialogState();
}

class _AdicionarCarregadorDialogState
    extends State<_AdicionarCarregadorDialog> {
  late final _AdicionarCarregadorFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _AdicionarCarregadorFormController(widget.idsExistentes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final carregador = _controller.criarCarregador();
    if (carregador == null) {
      return;
    }

    Navigator.of(context).pop(carregador);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      titulo: 'Adicionar carregador',
      descricao: 'Configure o identificador e os conectores do carregador.',
      campos: <Widget>[_AdicionarCarregadorForm(controller: _controller)],
      acoes: <Widget>[
        BotaoSecundario(
          key: const Key('adicionar_carregador_cancelar'),
          onPressed: () => Navigator.of(context).pop(),
          texto: 'Cancelar',
          icone: const Icon(Icons.close, size: 18),
        ),
        BotaoPrimario(
          key: const Key('adicionar_carregador_confirmar'),
          onPressed: _confirmar,
          texto: 'Adicionar',
          icone: Icons.add,
        ),
      ],
    );
  }
}

final class _AdicionarCarregadorFormController {
  _AdicionarCarregadorFormController(Iterable<String> idsExistentes)
    : _idsExistentes = idsExistentes
          .map(_normalizarId)
          .where((id) => id.isNotEmpty)
          .toSet();

  final Set<String> _idsExistentes;
  final idController = TextEditingController();
  final idFocusNode = FocusNode();
  final quantidadeConectores = Rx<int>(1);
  final tipoConector1 = Rx<TipoConectorCarregador>(TipoConectorCarregador.ccs2);
  final tipoConector2 = Rx<TipoConectorCarregador>(
    TipoConectorCarregador.mennekesType2,
  );
  final erroId = Rx<String?>(null);

  void alterarQuantidade(int? valor) {
    if (valor == null || valor < 1 || valor > 2) {
      return;
    }

    quantidadeConectores.value = valor;
  }

  void alterarTipoConector1(TipoConectorCarregador? tipo) {
    if (tipo == null) {
      return;
    }

    tipoConector1.value = tipo;
  }

  void alterarTipoConector2(TipoConectorCarregador? tipo) {
    if (tipo == null) {
      return;
    }

    tipoConector2.value = tipo;
  }

  void limparErroId() {
    if (erroId.value != null) {
      erroId.value = null;
    }
  }

  CarregadorConfigurado? criarCarregador() {
    final id = idController.text.trim();
    if (id.isEmpty) {
      erroId.value = 'Informe o id do carregador.';
      idFocusNode.requestFocus();
      return null;
    }

    if (_idsExistentes.contains(_normalizarId(id))) {
      erroId.value = 'Ja existe um carregador com este id.';
      idFocusNode.requestFocus();
      return null;
    }

    erroId.value = null;

    return CarregadorConfigurado(
      id: id,
      conectores: <ConectorCarregadorConfigurado>[
        ConectorCarregadorConfigurado(id: 1, tipo: tipoConector1.value),
        if (quantidadeConectores.value == 2)
          ConectorCarregadorConfigurado(id: 2, tipo: tipoConector2.value),
      ],
    );
  }

  void dispose() {
    idFocusNode.dispose();
    idController.dispose();
    quantidadeConectores.dispose();
    tipoConector1.dispose();
    tipoConector2.dispose();
    erroId.dispose();
  }
}

class _AdicionarCarregadorForm extends StatelessWidget {
  const _AdicionarCarregadorForm({required this.controller});

  final _AdicionarCarregadorFormController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const _CampoRotulo('Id do carregador'),
        CustomTextFormField(
          campoKey: const Key('adicionar_carregador_id'),
          controller: controller.idController,
          focusNode: controller.idFocusNode,
          textInputAction: TextInputAction.next,
          hintText: 'Ex.: CP-001',
          prefixIcon: Icons.ev_station,
          onChanged: (_) => controller.limparErroId(),
        ),
        Obx(
          () => controller.erroId.value == null
              ? const SizedBox.shrink()
              : Padding(
                  key: const Key('adicionar_carregador_erro_id'),
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    controller.erroId.value!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        const _CampoRotulo('Quantidade de conectores'),
        Obx(
          () => CustomDropdown<int>(
            campoKey: const Key('adicionar_carregador_quantidade'),
            valorInicial: controller.quantidadeConectores.value,
            hintText: 'Quantidade de conectores',
            prefixIcon: Icons.power_outlined,
            opcoes: const <int>[1, 2],
            rotuloOpcao: (quantidade) =>
                '$quantidade ${quantidade == 1 ? 'conector' : 'conectores'}',
            onChanged: controller.alterarQuantidade,
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ConectorDropdown(
                indice: 1,
                valor: controller.tipoConector1.value,
                onChanged: controller.alterarTipoConector1,
              ),
              if (controller.quantidadeConectores.value == 2) ...<Widget>[
                const SizedBox(height: 14),
                _ConectorDropdown(
                  indice: 2,
                  valor: controller.tipoConector2.value,
                  onChanged: controller.alterarTipoConector2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ConectorDropdown extends StatelessWidget {
  const _ConectorDropdown({
    required this.indice,
    required this.valor,
    required this.onChanged,
  });

  final int indice;
  final TipoConectorCarregador valor;
  final ValueChanged<TipoConectorCarregador?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CampoRotulo('Tipo do conector $indice'),
        CustomDropdown<TipoConectorCarregador>(
          campoKey: Key('adicionar_carregador_tipo_$indice'),
          valorInicial: valor,
          hintText: 'Tipo do conector $indice',
          prefixIcon: Icons.cable,
          opcoes: TipoConectorCarregador.values,
          rotuloOpcao: (tipo) => tipo.rotulo,
          itemBuilder: (tipo) => _ConectorOpcao(tipo: tipo),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ConectorOpcao extends StatelessWidget {
  const _ConectorOpcao({required this.tipo});

  final TipoConectorCarregador tipo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Row(
      children: <Widget>[
        _MiniaturaConector(tipo: tipo),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            tipo.rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniaturaConector extends StatelessWidget {
  const _MiniaturaConector({required this.tipo});

  final TipoConectorCarregador tipo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SizedBox(
      width: 34,
      height: 34,
      child: Image.asset(
        tipo.asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.electrical_services,
          color: tema.colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

class _CampoRotulo extends StatelessWidget {
  const _CampoRotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        texto,
        style: tema.textTheme.labelMedium?.copyWith(
          color: tema.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension _TipoConectorCarregadorUi on TipoConectorCarregador {
  String get rotulo {
    return switch (this) {
      TipoConectorCarregador.ccs2 => 'CCS2 (Combo 2)',
      TipoConectorCarregador.mennekesType2 => 'Mennekes Type 2',
      TipoConectorCarregador.gbt => 'GB/T',
    };
  }

  String get asset {
    return switch (this) {
      TipoConectorCarregador.ccs2 => 'assets/carregador/conector_CCS2.png',
      TipoConectorCarregador.mennekesType2 =>
        'assets/carregador/conector_MENNEKES_type_2.png',
      TipoConectorCarregador.gbt => 'assets/carregador/conector_GBT.png',
    };
  }
}

String _normalizarId(String id) {
  return id.trim().toLowerCase();
}
