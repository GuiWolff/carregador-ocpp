import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart';
import 'package:simulador_ocpp/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart';
import 'package:simulador_ocpp/features/carregador/presentation/widgets/adicionar_carregador_dialog.dart';
import 'package:simulador_ocpp/features/carregador/presentation/widgets/carregador_widget.dart';
import 'package:simulador_ocpp/observable/obx.dart';
import 'package:simulador_ocpp/widget/botao_primario.dart';
import 'package:simulador_ocpp/widget/botao_secundario.dart';
import 'package:simulador_ocpp/widget/custom_alert_dialog.dart';

class CarregadoresPage extends StatefulWidget {
  const CarregadoresPage({super.key, CarregadoresPageViewModel? viewModel})
    : _viewModel = viewModel;

  final CarregadoresPageViewModel? _viewModel;

  @override
  State<CarregadoresPage> createState() => _CarregadoresPageState();
}

class _CarregadoresPageState extends State<CarregadoresPage> {
  late final CarregadoresPageViewModel _viewModel;
  late final bool _descartarViewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = widget._viewModel ?? CarregadoresPageViewModel();
    _descartarViewModel = widget._viewModel == null;
  }

  @override
  void dispose() {
    if (_descartarViewModel) {
      _viewModel.dispose();
    }

    super.dispose();
  }

  Future<void> _abrirDialogoAdicionar() async {
    final carregador = await abrirDialogoAdicionarCarregador(
      context: context,
      idsExistentes: _viewModel.idsConfigurados,
    );

    if (!mounted || carregador == null) {
      return;
    }

    final sucesso = await _viewModel.adicionar(carregador);
    if (!mounted || sucesso) {
      return;
    }

    final erro = _viewModel.erro.value?.trim();
    if (erro == null || erro.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
  }

  Future<void> _recarregar() async {
    await _viewModel.carregar();
  }

  Future<void> _confirmarRemocao(CarregadorPageItem item) async {
    final id = item.configuracao.id;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => CustomAlertDialog(
        titulo: 'Excluir carregador',
        descricao: 'O carregador $id sera removido da lista configurada.',
        acoes: <Widget>[
          BotaoSecundario(
            key: const Key('carregador_cancelar_exclusao'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            texto: 'Cancelar',
            icone: const Icon(Icons.close, size: 18),
          ),
          FilledButton.icon(
            key: const Key('carregador_confirmar_exclusao'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmado != true) {
      return;
    }

    final sucesso = await _viewModel.remover(id);
    if (!mounted || sucesso) {
      return;
    }

    final erro = _viewModel.erro.value?.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          erro == null || erro.isEmpty
              ? 'Nao foi possivel excluir o carregador.'
              : erro,
        ),
      ),
    );
  }

  Future<void> _abrirDialogoCarregador(CarregadorPageItem item) {
    final configuracao = item.configuracao;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => CustomAlertDialog(
        titulo: configuracao.id,
        descricao: _formatarSubtitulo(configuracao),
        larguraMaxima: 1040,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        espacamentoCorpo: 16,
        conteudo: CarregadorWidget(
          key: ValueKey<String>('carregador_dialogo_${configuracao.id}'),
          viewModel: item.viewModel,
          titulo: configuracao.id,
          subtitulo: _formatarSubtitulo(configuracao),
        ),
        acoes: <Widget>[
          BotaoSecundario(
            key: const Key('carregador_dialogo_fechar'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            texto: 'Fechar',
            icone: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carregadores'),
        actions: <Widget>[
          Obx(() {
            final ocupado =
                _viewModel.carregando.value || _viewModel.salvando.value;

            return IconButton(
              tooltip: 'Recarregar',
              onPressed: ocupado ? null : _recarregar,
              icon: const Icon(Icons.refresh),
            );
          }),
        ],
      ),
      body: Obx(() {
        final carregando = _viewModel.carregando.value;
        final salvando = _viewModel.salvando.value;
        final carregadores = _viewModel.carregadores.value;
        final erro = _viewModel.erro.value;
        final ocupado = carregando || salvando;

        return _CarregadoresConteudo(
          carregadores: carregadores,
          carregando: carregando,
          salvando: salvando,
          ocupado: ocupado,
          erro: erro,
          onAdicionar: ocupado ? null : _abrirDialogoAdicionar,
          onAbrirCarregador: _abrirDialogoCarregador,
          onRemoverCarregador: ocupado ? null : _confirmarRemocao,
        );
      }),
    );
  }
}

class _CarregadoresConteudo extends StatelessWidget {
  const _CarregadoresConteudo({
    required this.carregadores,
    required this.carregando,
    required this.salvando,
    required this.ocupado,
    required this.erro,
    required this.onAdicionar,
    required this.onAbrirCarregador,
    required this.onRemoverCarregador,
  });

  final List<CarregadorPageItem> carregadores;
  final bool carregando;
  final bool salvando;
  final bool ocupado;
  final String? erro;
  final VoidCallback? onAdicionar;
  final ValueChanged<CarregadorPageItem> onAbrirCarregador;
  final ValueChanged<CarregadorPageItem>? onRemoverCarregador;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return ColoredBox(
      color: cores.surfaceContainerLowest,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final paddingHorizontal = constraints.maxWidth >= 900 ? 28.0 : 16.0;
            final paddingVertical = constraints.maxWidth >= 600 ? 24.0 : 16.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    paddingHorizontal,
                    paddingVertical,
                    paddingHorizontal,
                    12,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: _CarregadoresCabecalho(
                        total: carregadores.length,
                        carregando: carregando,
                        salvando: salvando,
                        onAdicionar: onAdicionar,
                      ),
                    ),
                  ),
                ),
                if (erro != null && erro!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      paddingHorizontal,
                      0,
                      paddingHorizontal,
                      12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: _MensagemErro(mensagem: erro!),
                      ),
                    ),
                  ),
                Expanded(
                  child: carregando && carregadores.isEmpty
                      ? const _CarregandoCarregadores()
                      : carregadores.isEmpty
                      ? _EstadoVazio(onAdicionar: onAdicionar, ocupado: ocupado)
                      : _ListaCarregadores(
                          carregadores: carregadores,
                          paddingHorizontal: paddingHorizontal,
                          paddingBottom: paddingVertical,
                          onAbrirCarregador: onAbrirCarregador,
                          onRemoverCarregador: onRemoverCarregador,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CarregadoresCabecalho extends StatelessWidget {
  const _CarregadoresCabecalho({
    required this.total,
    required this.carregando,
    required this.salvando,
    required this.onAdicionar,
  });

  final int total;
  final bool carregando;
  final bool salvando;
  final VoidCallback? onAdicionar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 620;
        final botao = BotaoPrimario(
          key: const Key('carregadores_adicionar'),
          onPressed: onAdicionar,
          texto: 'Adicionar',
          textoCarregando: 'Salvando',
          carregando: salvando,
          icone: Icons.add,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: cores.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cores.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: compacto
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CabecalhoTexto(total: total, carregando: carregando),
                      const SizedBox(height: 14),
                      botao,
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                        child: _CabecalhoTexto(
                          total: total,
                          carregando: carregando,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(width: 180, child: botao),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CabecalhoTexto extends StatelessWidget {
  const _CabecalhoTexto({required this.total, required this.carregando});

  final int total;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cores.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.ev_station, color: cores.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Carregadores',
                    style: tema.textTheme.headlineSmall?.copyWith(
                      color: cores.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _rotuloTotal(total),
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (carregando) ...<Widget>[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 3,
            backgroundColor: cores.surfaceContainerHighest,
            color: cores.primary,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ],
    );
  }
}

class _MensagemErro extends StatelessWidget {
  const _MensagemErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cores.error.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: cores.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensagem,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: cores.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarregandoCarregadores extends StatelessWidget {
  const _CarregandoCarregadores();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(
        color: cores.primary,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.onAdicionar, required this.ocupado});

  final VoidCallback? onAdicionar;
  final bool ocupado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cores.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cores.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cores.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      color: cores.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum carregador configurado',
                    style: tema.textTheme.titleLarge?.copyWith(
                      color: cores.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione um carregador para iniciar simulacoes OCPP com um ou dois conectores.',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: cores.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  BotaoSecundario(
                    key: const Key('carregadores_vazio_adicionar'),
                    onPressed: onAdicionar,
                    texto: ocupado ? 'Aguarde' : 'Adicionar carregador',
                    icone: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListaCarregadores extends StatelessWidget {
  const _ListaCarregadores({
    required this.carregadores,
    required this.paddingHorizontal,
    required this.paddingBottom,
    required this.onAbrirCarregador,
    required this.onRemoverCarregador,
  });

  final List<CarregadorPageItem> carregadores;
  final double paddingHorizontal;
  final double paddingBottom;
  final ValueChanged<CarregadorPageItem> onAbrirCarregador;
  final ValueChanged<CarregadorPageItem>? onRemoverCarregador;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        paddingHorizontal,
        0,
        paddingHorizontal,
        paddingBottom,
      ),
      itemCount: carregadores.length,
      itemBuilder: (context, index) {
        final item = carregadores[index];

        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: _CarregadorBotaoVisual(
                item: item,
                onPressed: () => onAbrirCarregador(item),
                onRemover: onRemoverCarregador == null
                    ? null
                    : () => onRemoverCarregador!(item),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CarregadorBotaoVisual extends StatelessWidget {
  const _CarregadorBotaoVisual({
    required this.item,
    required this.onPressed,
    required this.onRemover,
  });

  final CarregadorPageItem item;
  final VoidCallback onPressed;
  final VoidCallback? onRemover;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tema = Theme.of(context);
      final cores = tema.colorScheme;
      final estado = item.viewModel.estado.value;
      final conectado = item.viewModel.conectado.value;
      final ocupado = item.viewModel.ocupado.value;
      final corEstado = _corEstado(tema, estado, conectado);
      final configuracao = item.configuracao;

      return Tooltip(
        message: 'Abrir painel do carregador ${configuracao.id}',
        child: Material(
          color: cores.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: conectado
                  ? corEstado.withValues(alpha: 0.44)
                  : cores.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey<String>('carregador_botao_${configuracao.id}'),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compacto = constraints.maxWidth < 620;
                  final imagem = _CarregadorSvg(
                    configuracao: configuracao,
                    compacto: compacto,
                  );
                  final detalhes = _CarregadorBotaoDetalhes(
                    configuracao: configuracao,
                    estado: estado,
                    ocupado: ocupado,
                    corEstado: corEstado,
                    onRemover: onRemover,
                  );

                  if (compacto) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(child: imagem),
                        const SizedBox(height: 16),
                        detalhes,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      imagem,
                      const SizedBox(width: 22),
                      Expanded(child: detalhes),
                      const SizedBox(width: 12),
                      Icon(Icons.chevron_right, color: cores.onSurfaceVariant),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CarregadorSvg extends StatelessWidget {
  const _CarregadorSvg({required this.configuracao, required this.compacto});

  final CarregadorConfigurado configuracao;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compacto ? 176 : 132,
      height: compacto ? 238 : 214,
      child: SvgPicture.asset(
        _assetCarregador(configuracao),
        fit: BoxFit.contain,
        semanticsLabel: 'Carregador ${configuracao.id}',
        placeholderBuilder: (context) => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

class _CarregadorBotaoDetalhes extends StatelessWidget {
  const _CarregadorBotaoDetalhes({
    required this.configuracao,
    required this.estado,
    required this.ocupado,
    required this.corEstado,
    required this.onRemover,
  });

  final CarregadorConfigurado configuracao;
  final EstadoCarregador estado;
  final bool ocupado;
  final Color corEstado;
  final VoidCallback? onRemover;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    configuracao.id,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleLarge?.copyWith(
                      color: cores.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rotuloQuantidadeConectores(configuracao),
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _EstadoCarregadorChip(
              estado: estado,
              ocupado: ocupado,
              corEstado: corEstado,
            ),
            const SizedBox(width: 8),
            IconButton(
              key: ValueKey<String>('carregador_excluir_${configuracao.id}'),
              tooltip: 'Excluir carregador ${configuracao.id}',
              onPressed: onRemover,
              icon: Icon(
                Icons.delete_outline,
                color: onRemover == null
                    ? cores.onSurface.withValues(alpha: 0.38)
                    : cores.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ConectoresConfigurados(conectores: configuracao.conectores),
      ],
    );
  }
}

class _EstadoCarregadorChip extends StatelessWidget {
  const _EstadoCarregadorChip({
    required this.estado,
    required this.ocupado,
    required this.corEstado,
  });

  final EstadoCarregador estado;
  final bool ocupado;
  final Color corEstado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: corEstado.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: corEstado.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (ocupado) ...<Widget>[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: corEstado,
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              ocupado ? 'Processando' : estado.rotulo,
              style: tema.textTheme.labelMedium?.copyWith(
                color: corEstado,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConectoresConfigurados extends StatelessWidget {
  const _ConectoresConfigurados({required this.conectores});

  final List<ConectorCarregadorConfigurado> conectores;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final conector in conectores) _ConectorConfiguradoChip(conector),
      ],
    );
  }
}

class _ConectorConfiguradoChip extends StatelessWidget {
  const _ConectorConfiguradoChip(this.conector);

  final ConectorCarregadorConfigurado conector;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cores.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                _assetConector(conector.tipo),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.cable, size: 20, color: cores.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${conector.id}: ${_rotuloTipo(conector.tipo)}',
              style: tema.textTheme.labelLarge?.copyWith(
                color: cores.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _rotuloTotal(int total) {
  if (total == 0) {
    return 'Nenhum ponto de recarga configurado';
  }

  if (total == 1) {
    return '1 ponto de recarga configurado';
  }

  return '$total pontos de recarga configurados';
}

String _formatarSubtitulo(CarregadorConfigurado configuracao) {
  final quantidade = configuracao.conectores.length;
  final conectores = configuracao.conectores
      .map((conector) => '${conector.id}: ${_rotuloTipo(conector.tipo)}')
      .join(' | ');
  final sufixo = quantidade == 1 ? 'conector' : 'conectores';

  return '$quantidade $sufixo - $conectores';
}

String _rotuloQuantidadeConectores(CarregadorConfigurado configuracao) {
  final quantidade = configuracao.conectores.length;
  final sufixo = quantidade == 1
      ? 'conector configurado'
      : 'conectores configurados';

  return '$quantidade $sufixo';
}

String _assetCarregador(CarregadorConfigurado configuracao) {
  if (configuracao.conectores.length == 1) {
    return 'assets/carregador/carregador_1_conector.svg';
  }

  return 'assets/carregador/carregador_2_conectores.svg';
}

String _assetConector(TipoConectorCarregador tipo) {
  return switch (tipo) {
    TipoConectorCarregador.ccs2 => 'assets/carregador/conector_CCS2.png',
    TipoConectorCarregador.mennekesType2 =>
      'assets/carregador/conector_MENNEKES_type_2.png',
    TipoConectorCarregador.gbt => 'assets/carregador/conector_GBT.png',
  };
}

String _rotuloTipo(TipoConectorCarregador tipo) {
  return switch (tipo) {
    TipoConectorCarregador.ccs2 => 'CCS2',
    TipoConectorCarregador.mennekesType2 => 'Mennekes Type 2',
    TipoConectorCarregador.gbt => 'GB/T',
  };
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
