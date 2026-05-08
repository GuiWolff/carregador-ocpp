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

      expect(find.text('CP-1'), findsOneWidget);
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

      expect(find.text('CP-1'), findsNothing);
      expect(find.text('CP-2'), findsOneWidget);
      expect(viewModel.idsConfigurados, <String>['CP-2']);
      expect(repositorio.salvamentos, hasLength(1));
      expect(repositorio.salvamentos.single.single.id, 'CP-2');
      expect(repositorioCp1.desconexoes, 1);
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
