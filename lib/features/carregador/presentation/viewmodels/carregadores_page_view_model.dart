import 'dart:async';

import 'package:simulador_ocpp/features/carregador/data/repositories/configuracao_carregador_repository_local.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/domain/repositories/configuracao_carregador_repository.dart';
import 'package:simulador_ocpp/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart';
import 'package:simulador_ocpp/observable/rx.dart';

typedef CarregadorWidgetViewModelFactory =
    CarregadorWidgetViewModel Function(CarregadorConfigurado configuracao);

final class CarregadorPageItem {
  const CarregadorPageItem({
    required this.configuracao,
    required this.viewModel,
  });

  final CarregadorConfigurado configuracao;
  final CarregadorWidgetViewModel viewModel;
}

class CarregadoresPageViewModel {
  CarregadoresPageViewModel({
    ConfiguracaoCarregadorRepository? repository,
    CarregadorWidgetViewModelFactory? criarCarregadorViewModel,
    bool carregarAoInicializar = true,
  }) : _repository = repository ?? ConfiguracaoCarregadorRepositoryLocal(),
       _criarCarregadorViewModel =
           criarCarregadorViewModel ?? _criarCarregadorViewModelPadrao {
    if (carregarAoInicializar) {
      unawaited(carregar());
    }
  }

  final ConfiguracaoCarregadorRepository _repository;
  final CarregadorWidgetViewModelFactory _criarCarregadorViewModel;
  final Map<String, CarregadorWidgetViewModel> _viewModelsPorId =
      <String, CarregadorWidgetViewModel>{};

  final carregadores = Rx<List<CarregadorPageItem>>(
    const <CarregadorPageItem>[],
  );
  final carregando = Rx<bool>(false);
  final salvando = Rx<bool>(false);
  final erro = Rx<String?>(null);

  var _descartado = false;

  List<String> get idsConfigurados {
    return carregadores.value
        .map((item) => item.configuracao.id)
        .toList(growable: false);
  }

  bool get vazio => carregadores.value.isEmpty;

  Future<bool> carregar() async {
    if (_descartado || carregando.value) {
      return false;
    }

    carregando.value = true;
    erro.value = null;

    try {
      final configuracoes = await _repository.carregar();
      if (_descartado) {
        return false;
      }

      _aplicarConfiguracoes(configuracoes);
      return true;
    } catch (error) {
      _registrarErro(error);
      return false;
    } finally {
      if (!_descartado) {
        carregando.value = false;
      }
    }
  }

  Future<bool> adicionar(CarregadorConfigurado configuracao) async {
    if (_descartado || carregando.value || salvando.value) {
      return false;
    }

    final idNormalizado = _normalizarId(configuracao.id);
    if (_viewModelsPorId.containsKey(idNormalizado)) {
      erro.value = 'Ja existe um carregador com este id.';
      return false;
    }

    final proximasConfiguracoes = <CarregadorConfigurado>[
      ..._configuracoesAtuais(),
      configuracao,
    ];

    return _salvarEAplicar(proximasConfiguracoes);
  }

  Future<bool> remover(String id) async {
    if (_descartado || carregando.value || salvando.value) {
      return false;
    }

    final idNormalizado = _normalizarId(id);
    final configuracoesAtuais = _configuracoesAtuais();
    final proximasConfiguracoes = configuracoesAtuais
        .where(
          (configuracao) => _normalizarId(configuracao.id) != idNormalizado,
        )
        .toList(growable: false);

    if (proximasConfiguracoes.length == configuracoesAtuais.length) {
      return false;
    }

    return _salvarEAplicar(proximasConfiguracoes);
  }

  CarregadorWidgetViewModel? viewModelDoCarregador(String id) {
    return _viewModelsPorId[_normalizarId(id)];
  }

  void dispose() {
    if (_descartado) {
      return;
    }

    _descartado = true;

    for (final viewModel in _viewModelsPorId.values) {
      viewModel.dispose();
    }
    _viewModelsPorId.clear();

    carregadores.dispose();
    carregando.dispose();
    salvando.dispose();
    erro.dispose();
  }

  Future<bool> _salvarEAplicar(
    List<CarregadorConfigurado> configuracoes,
  ) async {
    salvando.value = true;
    erro.value = null;

    try {
      await _repository.salvar(configuracoes);
      if (_descartado) {
        return false;
      }

      _aplicarConfiguracoes(configuracoes);
      return true;
    } catch (error) {
      _registrarErro(error);
      return false;
    } finally {
      if (!_descartado) {
        salvando.value = false;
      }
    }
  }

  List<CarregadorConfigurado> _configuracoesAtuais() {
    return carregadores.value
        .map((item) => item.configuracao)
        .toList(growable: false);
  }

  void _aplicarConfiguracoes(List<CarregadorConfigurado> configuracoes) {
    final idsAtivos = configuracoes
        .map((configuracao) => _normalizarId(configuracao.id))
        .toSet();
    final idsRemovidos = _viewModelsPorId.keys
        .where((id) => !idsAtivos.contains(id))
        .toList(growable: false);

    for (final id in idsRemovidos) {
      final viewModel = _viewModelsPorId.remove(id);
      viewModel?.dispose();
    }

    final itens = <CarregadorPageItem>[];
    final idsAdicionados = <String>{};

    for (final configuracao in configuracoes) {
      final idNormalizado = _normalizarId(configuracao.id);
      if (!idsAdicionados.add(idNormalizado)) {
        continue;
      }

      final viewModel = _viewModelsPorId.putIfAbsent(
        idNormalizado,
        () => _criarCarregadorViewModel(configuracao),
      );
      itens.add(
        CarregadorPageItem(configuracao: configuracao, viewModel: viewModel),
      );
    }

    carregadores.value = List<CarregadorPageItem>.unmodifiable(itens);
  }

  void _registrarErro(Object error) {
    erro.value = error.toString();
  }
}

CarregadorWidgetViewModel _criarCarregadorViewModelPadrao(
  CarregadorConfigurado configuracao,
) {
  return CarregadorWidgetViewModel(
    servidorInicial: Uri.parse(
      'ws://localhost:5001/OCPP/${Uri.encodeComponent(configuracao.id)}',
    ),
    conectorIdInicial: configuracao.conectores.first.id,
  );
}

String _normalizarId(String id) {
  return id.trim().toLowerCase();
}
