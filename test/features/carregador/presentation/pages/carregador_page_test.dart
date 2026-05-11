import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';
import 'package:simulador_ocpp/utils/tema.dart';

void main() {
  group('CarregadoresPage', () {
    testWidgets('exibe estado vazio', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso();
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      expect(find.text('Nenhum carregador configurado'), findsOneWidget);
      expect(
        find.byKey(const Key('carregadores_vazio_adicionar')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('carregadores_adicionar')), findsOneWidget);
    });

    testWidgets('adiciona carregador e persiste configuracao', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso();
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      await tester.tap(find.byKey(const Key('carregadores_vazio_adicionar')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('adicionar_carregador_id')),
        'CP-1',
      );
      await tester.tap(find.byKey(const Key('adicionar_carregador_confirmar')));
      await tester.pumpAndSettle();

      expect(find.text('ID CP-1 / 1'), findsOneWidget);
      expect(viewModel.idsConfigurados, <String>['CP-1']);
      expect(repositorio.salvamentos, hasLength(1));
      expect(repositorio.salvamentos.single.single.id, 'CP-1');
      expect(repositoriosOperacionais.keys, contains('CP-1'));
    });

    testWidgets('exibe status visual do carregador com estado real', (
      tester,
    ) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      final carregadorViewModel = viewModel.viewModelDoCarregador('CP-1')!;
      carregadorViewModel.conectado.value = true;
      carregadorViewModel.estado.value = EstadoCarregador.carregando;

      await _pumpCarregadoresPage(tester, viewModel);

      final statusVisual = find.byKey(
        const ValueKey<String>('carregador_status_visual_CP-1'),
      );

      expect(statusVisual, findsOneWidget);
      expect(
        find.descendant(of: statusVisual, matching: find.text('Carregando')),
        findsOneWidget,
      );

      carregadorViewModel.ocupado.value = true;
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: statusVisual, matching: find.text('Processando')),
        findsOneWidget,
      );
    });

    testWidgets('exibe display operacional nos cards da lista', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      final carregadorViewModel = viewModel.viewModelDoCarregador('CP-1')!;
      carregadorViewModel.conectado.value = true;
      carregadorViewModel.estado.value = EstadoCarregador.carregando;
      carregadorViewModel.potenciaW.value = 11000;
      carregadorViewModel.medidorInicioTransacaoWh.value = 1200;
      carregadorViewModel.medidorWh.value = 5000;
      carregadorViewModel.soc.value = 50;
      carregadorViewModel.temperaturaC.value = 36.5;
      carregadorViewModel.tempoCarregamento.value = const Duration(
        hours: 1,
        minutes: 2,
        seconds: 3,
      );

      await _pumpCarregadoresPage(tester, viewModel);

      final display = find.byKey(
        const ValueKey<String>('carregador_display_CP-1'),
      );

      expect(display, findsOneWidget);
      expect(
        find.descendant(of: display, matching: find.text('Potencia atual')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('11000 W')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('3.80 kWh')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('50.0%')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('01:02:03')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('02:44')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: display, matching: find.text('36.5 C')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey<String>('carregador_status_visual_CP-1'),
          ),
          matching: find.text('Carregando'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('exclui carregador da lista', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1'),
          _criarCarregador('CP-2'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      final repositorioCp1 = repositoriosOperacionais['CP-1']!;

      await tester.tap(
        find.byKey(const ValueKey<String>('carregador_excluir_CP-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Excluir carregador'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('carregador_dialogo_CP-1')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('carregador_confirmar_exclusao')));
      await tester.pumpAndSettle();

      expect(find.text('ID CP-1 / 1'), findsNothing);
      expect(find.text('ID CP-2 / 1'), findsOneWidget);
      expect(viewModel.idsConfigurados, <String>['CP-2']);
      expect(repositorio.salvamentos, hasLength(1));
      expect(repositorio.salvamentos.single.single.id, 'CP-2');
      expect(repositorioCp1.desconexoes, 1);
    });

    testWidgets('exibe conectores esquerdo e direito', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1C'),
          _criarCarregadorComDoisConectores('CP-2C'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      expect(find.text('Esquerdo'), findsOneWidget);
      expect(find.text('Direito'), findsOneWidget);
      expect(find.text('ID CP-2C / 1'), findsOneWidget);
      expect(find.text('ID CP-2C / 2'), findsOneWidget);
      _expectConectorDecoracao(
        tester,
        'conector_chip_CP-2C_1',
        TemaApp.temaClaro().colorScheme.surfaceContainerHighest,
      );
      _expectConectorDecoracao(
        tester,
        'conector_chip_CP-2C_2',
        TemaApp.temaClaro().colorScheme.surfaceContainerHighest,
      );

      final posicaoEsquerdo = tester.getTopLeft(find.text('Esquerdo'));
      final posicaoDireito = tester.getTopLeft(find.text('Direito'));
      expect(posicaoEsquerdo.dx, lessThan(posicaoDireito.dx));
      expect(
        (posicaoEsquerdo.dy - posicaoDireito.dy).abs(),
        lessThanOrEqualTo(1),
      );
    });

    testWidgets('altera status pelo chip e seleciona o conector ativo', (
      tester,
    ) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregadorComDoisConectores('CP-2C'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      final carregadorViewModel = viewModel.viewModelDoCarregador('CP-2C')!;
      carregadorViewModel.conectado.value = true;

      await _pumpCarregadoresPage(tester, viewModel);

      final statusConector2 = find.byKey(
        const ValueKey<String>('conector_status_CP-2C_2'),
      );

      await tester.ensureVisible(statusConector2);
      await tester.pumpAndSettle();
      await tester.tap(statusConector2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preparing').last);
      await tester.pumpAndSettle();

      final repositorioOperacional = repositoriosOperacionais['CP-2C']!;

      expect(carregadorViewModel.conectorId.value, 2);
      expect(
        carregadorViewModel.statusDoConector(2),
        StatusConectorOcpp.preparing,
      );
      expect(
        carregadorViewModel.statusDoConector(1),
        StatusConectorOcpp.available,
      );
      expect(repositorioOperacional.statusNotifications.last['conectorId'], 2);
      expect(
        repositorioOperacional.statusNotifications.last['status'],
        StatusConectorOcpp.preparing.valor,
      );
      expect(
        find.byKey(const ValueKey<String>('carregador_dialogo_CP-2C')),
        findsNothing,
      );
    });

    testWidgets('exibe opções e altera status pelo chip sem conexão', (
      tester,
    ) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1C')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      final carregadorViewModel = viewModel.viewModelDoCarregador('CP-1C')!;

      await _pumpCarregadoresPage(tester, viewModel);

      final statusConector = find.byKey(
        const ValueKey<String>('conector_status_CP-1C_1'),
      );

      await tester.ensureVisible(statusConector);
      await tester.pumpAndSettle();
      await tester.tap(statusConector);
      await tester.pumpAndSettle();

      expect(find.text(StatusConectorOcpp.preparing.valor), findsOneWidget);

      await tester.tap(find.text(StatusConectorOcpp.preparing.valor).last);
      await tester.pumpAndSettle();

      expect(
        carregadorViewModel.statusDoConector(1),
        StatusConectorOcpp.preparing,
      );
      expect(repositoriosOperacionais['CP-1C']!.statusNotifications, isEmpty);
      expect(
        find.byKey(const ValueKey<String>('carregador_dialogo_CP-1C')),
        findsNothing,
      );
    });

    testWidgets('toque no dropdown em processamento não abre o painel', (
      tester,
    ) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1C')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      final carregadorViewModel = viewModel.viewModelDoCarregador('CP-1C')!;
      carregadorViewModel.conectado.value = true;
      carregadorViewModel.ocupado.value = true;

      await _pumpCarregadoresPage(tester, viewModel);

      final statusConector = find.byKey(
        const ValueKey<String>('conector_status_CP-1C_1'),
      );

      await tester.ensureVisible(statusConector);
      await tester.pumpAndSettle();
      await tester.tap(statusConector);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('carregador_dialogo_CP-1C')),
        findsNothing,
      );
    });

    testWidgets('exibe conector central para carregador com 1 conector', (
      tester,
    ) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1C')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      expect(find.text('Conector Central'), findsOneWidget);
      expect(find.text('ID CP-1C / 1'), findsOneWidget);
      expect(find.text('7.4 kW'), findsOneWidget);
      _expectConectorDecoracao(
        tester,
        'conector_chip_CP-1C_1',
        TemaApp.temaClaro().colorScheme.surfaceContainerHighest,
      );
    });

    testWidgets('nao gera overflow visual em largura compacta', (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1C'),
          _criarCarregadorComDoisConectores('CP-2C'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      expect(tester.takeException(), isNull);
      expect(find.text('Conector Central'), findsOneWidget);
      expect(find.text('Esquerdo'), findsOneWidget);
      expect(find.text('Direito'), findsOneWidget);
    });

    testWidgets('mantem chips de conectores com altura uniforme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1C'),
          _criarCarregadorComDoisConectores('CP-2C'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      final alturaCentral = tester
          .getSize(find.byKey(const ValueKey<String>('conector_chip_CP-1C_1')))
          .height;
      final alturaEsquerdo = tester
          .getSize(find.byKey(const ValueKey<String>('conector_chip_CP-2C_1')))
          .height;
      final alturaDireito = tester
          .getSize(find.byKey(const ValueKey<String>('conector_chip_CP-2C_2')))
          .height;

      expect(tester.takeException(), isNull);
      expect(alturaCentral, moreOrLessEquals(alturaEsquerdo, epsilon: 0.1));
      expect(alturaCentral, moreOrLessEquals(alturaDireito, epsilon: 0.1));
    });

    testWidgets('exibe ate 4 carregadores na mesma linha em largura ampla', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: List<CarregadorConfigurado>.generate(
          5,
          (index) => _criarCarregador('CP-${index + 1}'),
        ),
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      final posicoes = <Offset>[
        for (var indice = 1; indice <= 5; indice += 1)
          tester.getTopLeft(
            find.byKey(ValueKey<String>('carregador_botao_CP-$indice')),
          ),
      ];

      for (var indice = 1; indice < 4; indice += 1) {
        expect((posicoes[indice].dy - posicoes.first.dy).abs(), lessThan(1));
        expect(posicoes[indice - 1].dx, lessThan(posicoes[indice].dx));
      }
      expect(posicoes.last.dy, greaterThan(posicoes.first.dy));
      expect(posicoes.last.dx, posicoes.first.dx);
    });

    testWidgets('abre painel de manipulacao do carregador', (tester) async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[_criarCarregador('CP-1')],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        viewModel.dispose();
        await _fecharRepositorios(repositoriosOperacionais);
      });

      await viewModel.carregar();
      await _pumpCarregadoresPage(tester, viewModel);

      await tester.tap(
        find.byKey(const ValueKey<String>('carregador_botao_CP-1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('carregador_dialogo_CP-1')),
        findsOneWidget,
      );
      final qrCode = find.byKey(const Key('carregador_qrcode'));
      final qrImage = find.descendant(
        of: qrCode,
        matching: find.byType(QrImageView),
      );

      expect(qrCode, findsOneWidget);
      expect(tester.getSize(qrCode), const Size(120, 120));
      expect(
        tester.widget<QrImageView>(qrImage).semanticsLabel,
        'QR Code do carregador CP-1',
      );
      expect(find.byKey(const Key('carregador_conectar')), findsOneWidget);
      expect(
        find.byKey(const Key('carregador_dialogo_fechar')),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpCarregadoresPage(
  WidgetTester tester,
  CarregadoresPageViewModel viewModel,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaApp.temaClaro(),
      home: CarregadoresPage(viewModel: viewModel),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectConectorDecoracao(
  WidgetTester tester,
  String key,
  Color corFundoEsperada,
) {
  final decoracao =
      tester
              .widgetList<DecoratedBox>(
                find.descendant(
                  of: find.byKey(ValueKey<String>(key)),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .first
              .decoration
          as BoxDecoration;

  expect(decoracao.color, corFundoEsperada);
  expect(decoracao.border, isNull);
}

CarregadoresPageViewModel _criarViewModel(
  ConfiguracaoCarregadorRepository repositorio,
  Map<String, _CarregadorRepositoryOperacionalFalso> repositoriosOperacionais,
) {
  return CarregadoresPageViewModel(
    repository: repositorio,
    carregarAoInicializar: false,
    criarCarregadorViewModel: (configuracao) {
      final repositorioOperacional = _CarregadorRepositoryOperacionalFalso();
      repositoriosOperacionais[configuracao.id] = repositorioOperacional;
      return CarregadorWidgetViewModel(repository: repositorioOperacional);
    },
  );
}

Future<void> _fecharRepositorios(
  Map<String, _CarregadorRepositoryOperacionalFalso> repositorios,
) async {
  for (final repositorio in repositorios.values) {
    await repositorio.fechar();
  }
}

CarregadorConfigurado _criarCarregador(String id) {
  return CarregadorConfigurado(
    id: id,
    conectores: <ConectorCarregadorConfigurado>[
      ConectorCarregadorConfigurado(id: 1, tipo: TipoConectorCarregador.ccs2),
    ],
  );
}

CarregadorConfigurado _criarCarregadorComDoisConectores(String id) {
  return CarregadorConfigurado(
    id: id,
    conectores: <ConectorCarregadorConfigurado>[
      ConectorCarregadorConfigurado(id: 1, tipo: TipoConectorCarregador.ccs2),
      ConectorCarregadorConfigurado(id: 2, tipo: TipoConectorCarregador.gbt),
    ],
  );
}

final class _ConfiguracaoCarregadorRepositoryFalso
    implements ConfiguracaoCarregadorRepository {
  _ConfiguracaoCarregadorRepositoryFalso({
    List<CarregadorConfigurado> carregadores = const <CarregadorConfigurado>[],
  }) : _carregadores = List<CarregadorConfigurado>.of(carregadores);

  List<CarregadorConfigurado> _carregadores;
  final salvamentos = <List<CarregadorConfigurado>>[];

  @override
  Future<List<CarregadorConfigurado>> carregar() async {
    return List<CarregadorConfigurado>.unmodifiable(_carregadores);
  }

  @override
  Future<void> salvar(List<CarregadorConfigurado> carregadores) async {
    _carregadores = List<CarregadorConfigurado>.of(carregadores);
    salvamentos.add(List<CarregadorConfigurado>.unmodifiable(carregadores));
  }

  @override
  Future<void> limpar() async {
    _carregadores = const <CarregadorConfigurado>[];
  }
}

final class _CarregadorRepositoryOperacionalFalso
    implements CarregadorRepository {
  final _mensagens = StreamController<MensagemOcpp>.broadcast();
  final _chamadas = StreamController<ChamadaOcpp>.broadcast();
  final statusNotifications = <Map<String, dynamic>>[];
  var desconexoes = 0;

  @override
  bool get conectado => false;

  @override
  Stream<MensagemOcpp> get mensagens => _mensagens.stream;

  @override
  Stream<ChamadaOcpp> get chamadasDoBackend => _chamadas.stream;

  @override
  Future<void> desconectar() async {
    desconexoes++;
  }

  @override
  Future<Map<String, dynamic>> enviarStatusNotification({
    required int conectorId,
    required StatusConectorOcpp status,
    CodigoErroOcpp codigoErro = CodigoErroOcpp.noError,
    DateTime? data,
    String? info,
    String? vendorId,
    String? vendorErrorCode,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    statusNotifications.add(<String, dynamic>{
      'conectorId': conectorId,
      'status': status.valor,
    });
    return const <String, dynamic>{};
  }

  Future<void> fechar() async {
    await _mensagens.close();
    await _chamadas.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
