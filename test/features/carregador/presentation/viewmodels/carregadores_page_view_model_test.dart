import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('CarregadoresPageViewModel', () {
    test('carrega estado vazio', () async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso();
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);

      final carregou = await viewModel.carregar();

      expect(carregou, isTrue);
      expect(viewModel.vazio, isTrue);
      expect(viewModel.idsConfigurados, isEmpty);
      expect(viewModel.carregadores.value, isEmpty);
      expect(viewModel.erro.value, isNull);

      viewModel.dispose();
      await _fecharRepositorios(repositoriosOperacionais);
    });

    test('carrega configuracoes e mantem view models estaveis', () async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1'),
          _criarCarregador('CP-2', tipo: TipoConectorCarregador.gbt),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);

      final carregou = await viewModel.carregar();
      final operacionalCp1 = viewModel.viewModelDoCarregador('cp-1');

      expect(carregou, isTrue);
      expect(viewModel.carregando.value, isFalse);
      expect(viewModel.erro.value, isNull);
      expect(viewModel.idsConfigurados, <String>['CP-1', 'CP-2']);
      expect(viewModel.carregadores.value, hasLength(2));
      expect(
        viewModel.carregadores.value.first.viewModel,
        same(operacionalCp1),
      );

      await viewModel.carregar();

      expect(viewModel.viewModelDoCarregador('CP-1'), same(operacionalCp1));
      expect(repositoriosOperacionais, hasLength(2));

      viewModel.dispose();
      await _fecharRepositorios(repositoriosOperacionais);
    });

    test('adiciona carregador e persiste configuracao', () async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso();
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);

      final adicionou = await viewModel.adicionar(_criarCarregador('CP-1'));

      expect(adicionou, isTrue);
      expect(viewModel.salvando.value, isFalse);
      expect(viewModel.erro.value, isNull);
      expect(viewModel.idsConfigurados, <String>['CP-1']);
      expect(repositorio.salvamentos, hasLength(1));
      expect(repositorio.salvamentos.single.single.id, 'CP-1');
      expect(repositoriosOperacionais.keys, contains('CP-1'));

      final duplicado = await viewModel.adicionar(_criarCarregador('cp-1'));

      expect(duplicado, isFalse);
      expect(repositorio.salvamentos, hasLength(1));
      expect(viewModel.erro.value, 'Ja existe um carregador com este id.');

      viewModel.dispose();
      await _fecharRepositorios(repositoriosOperacionais);
    });

    test(
      'remove carregador, persiste lista e descarta filho removido',
      () async {
        final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
          carregadores: <CarregadorConfigurado>[
            _criarCarregador('CP-1'),
            _criarCarregador('CP-2'),
          ],
        );
        final repositoriosOperacionais =
            <String, _CarregadorRepositoryOperacionalFalso>{};
        final viewModel = _criarViewModel(
          repositorio,
          repositoriosOperacionais,
        );
        await viewModel.carregar();

        final repositorioCp1 = repositoriosOperacionais['CP-1']!;
        final repositorioCp2 = repositoriosOperacionais['CP-2']!;

        final removeu = await viewModel.remover('cp-1');

        expect(removeu, isTrue);
        expect(viewModel.idsConfigurados, <String>['CP-2']);
        expect(viewModel.viewModelDoCarregador('CP-1'), isNull);
        expect(repositorio.salvamentos, hasLength(1));
        expect(repositorio.salvamentos.single.single.id, 'CP-2');
        expect(repositorioCp1.desconexoes, 1);
        expect(repositorioCp2.desconexoes, 0);

        viewModel.dispose();

        expect(repositorioCp1.desconexoes, 1);
        expect(repositorioCp2.desconexoes, 1);

        await _fecharRepositorios(repositoriosOperacionais);
      },
    );

    test('descarta todas as view models filhas', () async {
      final repositorio = _ConfiguracaoCarregadorRepositoryFalso(
        carregadores: <CarregadorConfigurado>[
          _criarCarregador('CP-1'),
          _criarCarregador('CP-2'),
        ],
      );
      final repositoriosOperacionais =
          <String, _CarregadorRepositoryOperacionalFalso>{};
      final viewModel = _criarViewModel(repositorio, repositoriosOperacionais);
      await viewModel.carregar();

      viewModel.dispose();

      expect(
        repositoriosOperacionais.values.map(
          (repositorio) => repositorio.desconexoes,
        ),
        everyElement(1),
      );
      expect(await viewModel.adicionar(_criarCarregador('CP-3')), isFalse);

      await _fecharRepositorios(repositoriosOperacionais);
    });
  });
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

CarregadorConfigurado _criarCarregador(
  String id, {
  TipoConectorCarregador tipo = TipoConectorCarregador.ccs2,
}) {
  return CarregadorConfigurado(
    id: id,
    conectores: <ConectorCarregadorConfigurado>[
      ConectorCarregadorConfigurado(id: 1, tipo: tipo),
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
