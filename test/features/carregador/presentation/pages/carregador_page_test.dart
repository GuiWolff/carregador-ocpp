import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

      final posicaoEsquerdo = tester.getTopLeft(find.text('Esquerdo'));
      final posicaoDireito = tester.getTopLeft(find.text('Direito'));
      expect(posicaoEsquerdo.dx, lessThan(posicaoDireito.dx));
      expect(
        (posicaoEsquerdo.dy - posicaoDireito.dy).abs(),
        lessThanOrEqualTo(1),
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
      expect(find.text('Esquerdo'), findsOneWidget);
      expect(find.text('Direito'), findsOneWidget);
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

  Future<void> fechar() async {
    await _mensagens.close();
    await _chamadas.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
