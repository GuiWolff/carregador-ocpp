import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart';
import 'package:simulador_ocpp/observable/i_rx_subscribe.dart';
import 'package:simulador_ocpp/observable/obx.dart';
import 'package:simulador_ocpp/widget/botao_primario.dart';
import 'package:simulador_ocpp/widget/botao_secundario.dart';
import 'package:simulador_ocpp/widget/custom_dropdown.dart';
import 'package:simulador_ocpp/widget/custom_text_form_field.dart';

class CarregadorWidget extends StatefulWidget {
  const CarregadorWidget({
    super.key,
    this.viewModel,
    this.carregadorId,
    this.titulo = 'Carregador A',
    this.subtitulo = 'Ponto de recarga OCPP 1.6J',
    this.conectoresConfigurados = const <ConectorCarregadorConfigurado>[],
  });

  final CarregadorWidgetViewModel? viewModel;
  final String? carregadorId;
  final String titulo;
  final String subtitulo;
  final List<ConectorCarregadorConfigurado> conectoresConfigurados;

  @override
  State<CarregadorWidget> createState() => _CarregadorWidgetState();
}

class _CarregadorWidgetState extends State<CarregadorWidget> {
  late final CarregadorWidgetViewModel _viewModel;
  late final bool _descartarViewModel;

  late final TextEditingController _servidorController;
  late final TextEditingController _idTagController;
  late final TextEditingController _conectorController;
  late final TextEditingController _potenciaController;
  late final TextEditingController _medidorController;
  late final TextEditingController _socController;
  late final TextEditingController _temperaturaController;

  final _servidorFocus = FocusNode();
  final _idTagFocus = FocusNode();
  final _conectorFocus = FocusNode();
  final _potenciaFocus = FocusNode();
  final _medidorFocus = FocusNode();
  final _socFocus = FocusNode();
  final _temperaturaFocus = FocusNode();
  final List<RxSubscription> _assinaturas = <RxSubscription>[];

  @override
  void initState() {
    super.initState();

    _viewModel = widget.viewModel ?? CarregadorWidgetViewModel();
    _descartarViewModel = widget.viewModel == null;

    _servidorController = TextEditingController(
      text: _viewModel.servidor.value.toString(),
    );
    _idTagController = TextEditingController(text: _viewModel.idTag.value);
    _conectorController = TextEditingController(
      text: _viewModel.conectorId.value.toString(),
    );
    _potenciaController = TextEditingController(
      text: _viewModel.potenciaW.value.toStringAsFixed(0),
    );
    _medidorController = TextEditingController(
      text: _viewModel.medidorWh.value.toString(),
    );
    _socController = TextEditingController(
      text: _viewModel.soc.value.toStringAsFixed(1),
    );
    _temperaturaController = TextEditingController(
      text: _viewModel.temperaturaC.value.toStringAsFixed(1),
    );

    _assinaturas.addAll(<RxSubscription>[
      _viewModel.servidor.listen(
        (valor) => _sincronizarTexto(
          _servidorController,
          valor.toString(),
          _servidorFocus,
        ),
      ),
      _viewModel.idTag.listen(
        (valor) => _sincronizarTexto(_idTagController, valor, _idTagFocus),
      ),
      _viewModel.conectorId.listen(
        (valor) => _sincronizarTexto(
          _conectorController,
          valor.toString(),
          _conectorFocus,
        ),
      ),
      _viewModel.potenciaW.listen(
        (valor) => _sincronizarTexto(
          _potenciaController,
          valor.toStringAsFixed(0),
          _potenciaFocus,
        ),
      ),
      _viewModel.medidorWh.listen(
        (valor) => _sincronizarTexto(
          _medidorController,
          valor.toString(),
          _medidorFocus,
        ),
      ),
      _viewModel.soc.listen(
        (valor) => _sincronizarTexto(
          _socController,
          valor.toStringAsFixed(1),
          _socFocus,
        ),
      ),
      _viewModel.temperaturaC.listen(
        (valor) => _sincronizarTexto(
          _temperaturaController,
          valor.toStringAsFixed(1),
          _temperaturaFocus,
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    for (final assinatura in _assinaturas) {
      assinatura.dispose();
    }

    _servidorFocus.dispose();
    _idTagFocus.dispose();
    _conectorFocus.dispose();
    _potenciaFocus.dispose();
    _medidorFocus.dispose();
    _socFocus.dispose();
    _temperaturaFocus.dispose();

    _servidorController.dispose();
    _idTagController.dispose();
    _conectorController.dispose();
    _potenciaController.dispose();
    _medidorController.dispose();
    _socController.dispose();
    _temperaturaController.dispose();

    if (_descartarViewModel) {
      _viewModel.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tema = Theme.of(context);
      final estado = _viewModel.estado.value;
      final conectado = _viewModel.conectado.value;
      final ocupado = _viewModel.ocupado.value;
      final carregadorId = widget.carregadorId ?? widget.titulo;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: tema.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tema.colorScheme.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CabecalhoCarregador(
                titulo: widget.titulo,
                subtitulo: widget.subtitulo,
                estado: estado,
                conectado: conectado,
              ),
              const SizedBox(height: 18),
              _QrCodeCarregador(carregadorId: carregadorId),
              const SizedBox(height: 18),
              _MetricasCarregador(viewModel: _viewModel),
              const SizedBox(height: 18),
              _ParametrosCarregador(
                servidorController: _servidorController,
                idTagController: _idTagController,
                conectorController: _conectorController,
                potenciaController: _potenciaController,
                medidorController: _medidorController,
                socController: _socController,
                temperaturaController: _temperaturaController,
                servidorFocus: _servidorFocus,
                idTagFocus: _idTagFocus,
                conectorFocus: _conectorFocus,
                potenciaFocus: _potenciaFocus,
                medidorFocus: _medidorFocus,
                socFocus: _socFocus,
                temperaturaFocus: _temperaturaFocus,
                viewModel: _viewModel,
                conectoresConfigurados: widget.conectoresConfigurados,
              ),
              const SizedBox(height: 18),
              _StatusManual(viewModel: _viewModel),
              const SizedBox(height: 18),
              _AcoesCarregador(
                viewModel: _viewModel,
                servidorController: _servidorController,
                ocupado: ocupado,
              ),
              const SizedBox(height: 18),
              _ConsoleCarregador(viewModel: _viewModel),
            ],
          ),
        ),
      );
    });
  }

  void _sincronizarTexto(
    TextEditingController controller,
    String texto,
    FocusNode focusNode,
  ) {
    if (focusNode.hasFocus || controller.text == texto) {
      return;
    }

    controller.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _CabecalhoCarregador extends StatelessWidget {
  const _CabecalhoCarregador({
    required this.titulo,
    required this.subtitulo,
    required this.estado,
    required this.conectado,
  });

  final String titulo;
  final String subtitulo;
  final EstadoCarregador estado;
  final bool conectado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corStatus = _corEstado(tema, estado, conectado);

    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tema.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.ev_station,
            color: tema.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titulo,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: corStatus.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: corStatus.withValues(alpha: 0.32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              estado.rotulo,
              style: TextStyle(color: corStatus, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Color _corEstado(ThemeData tema, EstadoCarregador estado, bool conectado) {
    if (!conectado && estado != EstadoCarregador.conectando) {
      return tema.colorScheme.outline;
    }

    return switch (estado) {
      EstadoCarregador.carregando => Colors.green.shade700,
      EstadoCarregador.pausado => Colors.amber.shade800,
      EstadoCarregador.falha => tema.colorScheme.error,
      EstadoCarregador.finalizando => Colors.blueGrey.shade700,
      _ => tema.colorScheme.primary,
    };
  }
}

class _QrCodeCarregador extends StatelessWidget {
  const _QrCodeCarregador({required this.carregadorId});

  final String carregadorId;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'QR Code do carregador $carregadorId',
        child: Container(
          key: const Key('carregador_qrcode'),
          color: tema.colorScheme.primary,
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(8),
          child: QrImageView(
            data: carregadorId,
            version: QrVersions.auto,
            backgroundColor: Colors.white,
            semanticsLabel: 'QR Code do carregador $carregadorId',
          ),
        ),
      ),
    );
  }
}

class _MetricasCarregador extends StatelessWidget {
  const _MetricasCarregador({required this.viewModel});

  final CarregadorWidgetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = _larguraMetrica(constraints.maxWidth);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _MetricaCarregador(
              largura: largura,
              icone: Icons.power,
              rotulo: 'Potencia',
              valor: '${viewModel.potenciaW.value.toStringAsFixed(0)} W',
            ),
            _MetricaCarregador(
              largura: largura,
              icone: Icons.battery_charging_full,
              rotulo: 'Energia',
              valor: '${viewModel.energiaFornecidaKwh.toStringAsFixed(2)} kWh',
            ),
            _MetricaCarregador(
              largura: largura,
              icone: Icons.schedule,
              rotulo: 'Tempo restante',
              valor: _formatarDuracao(viewModel.tempoRestante),
            ),
            _MetricaCarregador(
              largura: largura,
              icone: Icons.speed,
              rotulo: 'Medidor',
              valor: '${viewModel.medidorWh.value} Wh',
            ),
          ],
        );
      },
    );
  }

  double _larguraMetrica(double larguraTotal) {
    if (larguraTotal >= 860) {
      return (larguraTotal - 36) / 4;
    }

    if (larguraTotal >= 560) {
      return (larguraTotal - 12) / 2;
    }

    return larguraTotal;
  }

  String _formatarDuracao(Duration? duracao) {
    if (duracao == null) {
      return '--';
    }

    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    if (horas <= 0) {
      return '${max(1, minutos)} min';
    }

    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }
}

class _MetricaCarregador extends StatelessWidget {
  const _MetricaCarregador({
    required this.largura,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final double largura;
  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SizedBox(
      width: largura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tema.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tema.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Icon(icone, color: tema.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      rotulo,
                      style: tema.textTheme.labelMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParametrosCarregador extends StatelessWidget {
  const _ParametrosCarregador({
    required this.servidorController,
    required this.idTagController,
    required this.conectorController,
    required this.potenciaController,
    required this.medidorController,
    required this.socController,
    required this.temperaturaController,
    required this.servidorFocus,
    required this.idTagFocus,
    required this.conectorFocus,
    required this.potenciaFocus,
    required this.medidorFocus,
    required this.socFocus,
    required this.temperaturaFocus,
    required this.viewModel,
    required this.conectoresConfigurados,
  });

  final TextEditingController servidorController;
  final TextEditingController idTagController;
  final TextEditingController conectorController;
  final TextEditingController potenciaController;
  final TextEditingController medidorController;
  final TextEditingController socController;
  final TextEditingController temperaturaController;
  final FocusNode servidorFocus;
  final FocusNode idTagFocus;
  final FocusNode conectorFocus;
  final FocusNode potenciaFocus;
  final FocusNode medidorFocus;
  final FocusNode socFocus;
  final FocusNode temperaturaFocus;
  final CarregadorWidgetViewModel viewModel;
  final List<ConectorCarregadorConfigurado> conectoresConfigurados;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final larguraCampo = largura >= 780 ? (largura - 24) / 3 : largura;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: largura,
              child: _CampoCarregador(
                campoKey: const Key('carregador_servidor'),
                controller: servidorController,
                focusNode: servidorFocus,
                label: 'Central Station',
                prefixIcon: Icons.link,
                keyboardType: TextInputType.url,
              ),
            ),
            SizedBox(
              width: larguraCampo,
              child: _CampoCarregador(
                campoKey: const Key('carregador_tag'),
                controller: idTagController,
                focusNode: idTagFocus,
                label: 'Tag',
                prefixIcon: Icons.badge_outlined,
                onChanged: viewModel.atualizarIdTag,
              ),
            ),
            SizedBox(
              width: larguraCampo,
              child: conectoresConfigurados.isEmpty
                  ? _CampoCarregador(
                      campoKey: const Key('carregador_conector'),
                      controller: conectorController,
                      focusNode: conectorFocus,
                      label: 'Conector',
                      prefixIcon: Icons.cable,
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.atualizarConectorId,
                    )
                  : _SeletorConectorConfigurado(
                      conectores: conectoresConfigurados,
                      conectorId: viewModel.conectorId.value,
                      onChanged: viewModel.selecionarConector,
                    ),
            ),
            SizedBox(
              width: larguraCampo,
              child: _CampoCarregador(
                campoKey: const Key('carregador_potencia'),
                controller: potenciaController,
                focusNode: potenciaFocus,
                label: 'Potencia atual (W)',
                prefixIcon: Icons.bolt,
                keyboardType: TextInputType.number,
                onChanged: viewModel.atualizarPotencia,
              ),
            ),
            SizedBox(
              width: larguraCampo,
              child: _CampoCarregador(
                campoKey: const Key('carregador_medidor'),
                controller: medidorController,
                focusNode: medidorFocus,
                label: 'Meter value (Wh)',
                prefixIcon: Icons.speed,
                keyboardType: TextInputType.number,
                onChanged: viewModel.atualizarMedidor,
              ),
            ),
            SizedBox(
              width: larguraCampo,
              child: _CampoCarregador(
                campoKey: const Key('carregador_soc'),
                controller: socController,
                focusNode: socFocus,
                label: 'SoC (%)',
                prefixIcon: Icons.battery_5_bar,
                keyboardType: TextInputType.number,
                onChanged: viewModel.atualizarSoc,
              ),
            ),
            SizedBox(
              width: larguraCampo,
              child: _CampoCarregador(
                campoKey: const Key('carregador_temperatura'),
                controller: temperaturaController,
                focusNode: temperaturaFocus,
                label: 'Temperatura (C)',
                prefixIcon: Icons.thermostat,
                keyboardType: TextInputType.number,
                onChanged: viewModel.atualizarTemperatura,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SeletorConectorConfigurado extends StatelessWidget {
  const _SeletorConectorConfigurado({
    required this.conectores,
    required this.conectorId,
    required this.onChanged,
  });

  final List<ConectorCarregadorConfigurado> conectores;
  final int conectorId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final valorInicial = conectores.any((conector) => conector.id == conectorId)
        ? conectorId
        : conectores.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _CampoRotulo('Conector'),
        CustomDropdown<int>(
          campoKey: ValueKey<String>('carregador_conector_$valorInicial'),
          valorInicial: valorInicial,
          hintText: 'Conector',
          prefixIcon: Icons.cable,
          opcoes: conectores
              .map((conector) => conector.id)
              .toList(growable: false),
          rotuloOpcao: (id) {
            final conector = conectores.firstWhere(
              (conector) => conector.id == id,
            );
            return 'Conector ${conector.id} - ${_rotuloTipo(conector.tipo)}';
          },
          onChanged: (id) {
            if (id == null) {
              return;
            }

            onChanged(id);
          },
        ),
      ],
    );
  }
}

class _CampoCarregador extends StatelessWidget {
  const _CampoCarregador({
    required this.campoKey,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.onChanged,
  });

  final Key campoKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CampoRotulo(label),
        CustomTextFormField(
          campoKey: campoKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          hintText: label,
          prefixIcon: prefixIcon,
        ),
      ],
    );
  }
}

String _rotuloTipo(TipoConectorCarregador tipo) {
  return switch (tipo) {
    TipoConectorCarregador.ccs2 => 'CCS2',
    TipoConectorCarregador.mennekesType2 => 'Mennekes Type 2',
    TipoConectorCarregador.gbt => 'GB/T',
  };
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

class _StatusManual extends StatelessWidget {
  const _StatusManual({required this.viewModel});

  final CarregadorWidgetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ocupado = viewModel.ocupado.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _CampoRotulo('Connector Status'),
        CustomDropdown<StatusConectorOcpp>(
          campoKey: const Key('carregador_status'),
          valorInicial: viewModel.statusConector.value,
          hintText: 'Connector Status',
          prefixIcon: Icons.sensors,
          opcoes: StatusConectorOcpp.values,
          rotuloOpcao: (status) => status.valor,
          habilitado: !ocupado,
          onChanged: (status) {
            if (status == null) {
              return;
            }

            unawaited(viewModel.alterarStatus(status));
          },
        ),
      ],
    );
  }
}

class _AcoesCarregador extends StatelessWidget {
  const _AcoesCarregador({
    required this.viewModel,
    required this.servidorController,
    required this.ocupado,
  });

  final CarregadorWidgetViewModel viewModel;
  final TextEditingController servidorController;
  final bool ocupado;

  @override
  Widget build(BuildContext context) {
    final conectado = viewModel.conectado.value;
    final estado = viewModel.estado.value;
    final emFluxo =
        estado == EstadoCarregador.preparando ||
        estado == EstadoCarregador.carregando ||
        estado == EstadoCarregador.pausado ||
        estado == EstadoCarregador.finalizando;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 880
            ? 7
            : largura >= 640
            ? 3
            : largura >= 430
            ? 2
            : 1;
        final larguraBotao = (largura - (10 * (colunas - 1))) / colunas;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _BotaoAcao(
              key: const Key('carregador_conectar'),
              largura: larguraBotao,
              icon: conectado ? Icons.link_off : Icons.link,
              label: conectado ? 'Desconectar' : 'Conectar',
              filled: !conectado,
              onPressed: ocupado
                  ? null
                  : () {
                      if (conectado) {
                        unawaited(viewModel.desconectar());
                      } else {
                        unawaited(
                          viewModel.conectar(
                            servidorTexto: servidorController.text,
                          ),
                        );
                      }
                    },
            ),
            _BotaoAcao(
              key: const Key('carregador_autorizar'),
              largura: larguraBotao,
              icon: Icons.verified_user_outlined,
              label: 'Autorizar',
              onPressed: ocupado || !conectado
                  ? null
                  : () => unawaited(viewModel.autorizar()),
            ),
            _BotaoAcao(
              key: const Key('carregador_iniciar'),
              largura: larguraBotao,
              icon: Icons.play_arrow,
              label: 'Iniciar',
              filled: true,
              onPressed: ocupado || emFluxo
                  ? null
                  : () => unawaited(viewModel.iniciarCarregamento()),
            ),
            _BotaoAcao(
              key: const Key('carregador_pausar'),
              largura: larguraBotao,
              icon: estado == EstadoCarregador.pausado
                  ? Icons.play_arrow
                  : Icons.pause,
              label: estado == EstadoCarregador.pausado ? 'Retomar' : 'Pausar',
              onPressed:
                  ocupado ||
                      !(estado == EstadoCarregador.carregando ||
                          estado == EstadoCarregador.pausado)
                  ? null
                  : () {
                      if (estado == EstadoCarregador.pausado) {
                        unawaited(viewModel.retomarCarregamento());
                      } else {
                        unawaited(viewModel.pausarCarregamento());
                      }
                    },
            ),
            _BotaoAcao(
              key: const Key('carregador_parar'),
              largura: larguraBotao,
              icon: Icons.stop,
              label: 'Parar',
              onPressed: ocupado || !conectado || !emFluxo
                  ? null
                  : () => unawaited(viewModel.pararCarregamento()),
            ),
            _BotaoAcao(
              key: const Key('carregador_meter_values'),
              largura: larguraBotao,
              icon: Icons.show_chart,
              label: 'MeterValues',
              onPressed: ocupado || !conectado
                  ? null
                  : () => unawaited(
                      viewModel.enviarValoresMedidor(incrementarAntes: true),
                    ),
            ),
            _BotaoAcao(
              key: const Key('carregador_heartbeat'),
              largura: larguraBotao,
              icon: Icons.favorite_border,
              label: 'Heartbeat',
              onPressed: ocupado || !conectado
                  ? null
                  : () => unawaited(viewModel.enviarHeartbeat()),
            ),
          ],
        );
      },
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({
    super.key,
    required this.largura,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final double largura;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      child: filled
          ? BotaoPrimario(onPressed: onPressed, texto: label, icone: icon)
          : BotaoSecundario(
              onPressed: onPressed,
              texto: label,
              icone: Icon(icon, size: 18),
            ),
    );
  }
}

class _ConsoleCarregador extends StatelessWidget {
  const _ConsoleCarregador({required this.viewModel});

  final CarregadorWidgetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final eventos = viewModel.eventos.value.take(8).toList(growable: false);
    final erro = viewModel.erro.value;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tema.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.terminal, color: tema.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Console OCPP',
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (erro != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                erro,
                style: TextStyle(
                  color: tema.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: eventos.isEmpty
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Aguardando eventos',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: eventos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        return Text(
                          eventos[index],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodySmall,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
