import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('CarregadorWidgetViewModel', () {
    test('conecta e envia BootNotification com status inicial', () async {
      final repositorio = _CarregadorRepositoryFalso()
        ..respostas['BootNotification'] = <String, dynamic>{
          'status': 'Accepted',
          'interval': 120,
        };
      final viewModel = CarregadorWidgetViewModel(repository: repositorio);

      await viewModel.conectar(servidorTexto: 'ws://localhost:5001/OCPP/A');

      expect(viewModel.conectado.value, isTrue);
      expect(viewModel.estado.value, EstadoCarregador.disponivel);
      expect(viewModel.intervaloHeartbeat.value, const Duration(seconds: 120));
      expect(repositorio.acoes, <String>[
        'conectar',
        'BootNotification',
        'StatusNotification',
        'StatusNotification',
      ]);

      viewModel.dispose();
      await repositorio.fechar();
    });

    test('inicia transacao com autorizacao e envio de medidor', () async {
      final repositorio = _CarregadorRepositoryFalso()
        ..respostas['BootNotification'] = <String, dynamic>{
          'status': 'Accepted',
          'interval': 120,
        }
        ..respostas['Authorize'] = <String, dynamic>{
          'idTagInfo': <String, dynamic>{'status': 'Accepted'},
        }
        ..respostas['StartTransaction'] = <String, dynamic>{
          'transactionId': 42,
        };
      final viewModel = CarregadorWidgetViewModel(repository: repositorio);

      await viewModel.conectar(servidorTexto: 'ws://localhost:5001/OCPP/A');
      repositorio.registros.clear();

      await viewModel.iniciarCarregamento();

      expect(viewModel.estado.value, EstadoCarregador.carregando);
      expect(viewModel.statusConector.value, StatusConectorOcpp.charging);
      expect(viewModel.transacaoId.value, 42);
      expect(repositorio.acoes, <String>[
        'StatusNotification',
        'Authorize',
        'StartTransaction',
        'StatusNotification',
        'MeterValues',
      ]);

      viewModel.dispose();
      await repositorio.fechar();
    });
  });
}

final class _RegistroOcpp {
  const _RegistroOcpp(this.acao, this.payload);

  final String acao;
  final Map<String, dynamic> payload;
}

final class _CarregadorRepositoryFalso implements CarregadorRepository {
  final List<_RegistroOcpp> registros = <_RegistroOcpp>[];
  final Map<String, Map<String, dynamic>> respostas =
      <String, Map<String, dynamic>>{};
  final StreamController<MensagemOcpp> _mensagens =
      StreamController<MensagemOcpp>.broadcast();
  final StreamController<ChamadaOcpp> _chamadas =
      StreamController<ChamadaOcpp>.broadcast();

  var _conectado = false;

  List<String> get acoes {
    return registros.map((registro) => registro.acao).toList(growable: false);
  }

  @override
  bool get conectado => _conectado;

  @override
  Stream<MensagemOcpp> get mensagens => _mensagens.stream;

  @override
  Stream<ChamadaOcpp> get chamadasDoBackend => _chamadas.stream;

  @override
  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _conectado = true;
    _registrar('conectar', <String, dynamic>{'servidor': servidor.toString()});
  }

  @override
  Future<void> desconectar() async {
    _conectado = false;
    _registrar('desconectar', const <String, dynamic>{});
  }

  @override
  Future<Map<String, dynamic>> enviarBootNotification({
    required String fabricante,
    required String modelo,
    String? numeroSeriePontoCarga,
    String? numeroSerieChargeBox,
    String? versaoFirmware,
    String? iccid,
    String? imsi,
    String? tipoMedidor,
    String? numeroSerieMedidor,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('BootNotification', <String, dynamic>{
      'fabricante': fabricante,
      'modelo': modelo,
    });
    return respostas['BootNotification'] ??
        const <String, dynamic>{'status': 'Accepted'};
  }

  @override
  Future<Map<String, dynamic>> autorizar({
    required String idTag,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('Authorize', <String, dynamic>{'idTag': idTag});
    return respostas['Authorize'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> enviarHeartbeat({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('Heartbeat', const <String, dynamic>{});
    return respostas['Heartbeat'] ?? const <String, dynamic>{};
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
    _registrar('StatusNotification', <String, dynamic>{
      'conectorId': conectorId,
      'status': status.valor,
    });
    return respostas['StatusNotification'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> iniciarTransacao({
    required int conectorId,
    required String idTag,
    required int medidorInicialWh,
    DateTime? data,
    int? reservaId,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('StartTransaction', <String, dynamic>{
      'conectorId': conectorId,
      'idTag': idTag,
      'medidorInicialWh': medidorInicialWh,
    });
    return respostas['StartTransaction'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> enviarValoresMedidor({
    required int conectorId,
    required List<ValorMedidoOcpp> valores,
    int? transacaoId,
    DateTime? data,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('MeterValues', <String, dynamic>{
      'conectorId': conectorId,
      'transacaoId': transacaoId,
      'valores': valores.map((valor) => valor.toJson()).toList(),
    });
    return respostas['MeterValues'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> finalizarTransacao({
    required int transacaoId,
    required int medidorFinalWh,
    DateTime? data,
    String? idTag,
    MotivoFimTransacaoOcpp? motivo,
    List<ValorMedidoOcpp> valoresTransacao = const <ValorMedidoOcpp>[],
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _registrar('StopTransaction', <String, dynamic>{
      'transacaoId': transacaoId,
      'medidorFinalWh': medidorFinalWh,
      'motivo': motivo?.valor,
    });
    return respostas['StopTransaction'] ?? const <String, dynamic>{};
  }

  @override
  Future<void> responderChamadaBackend(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  ) async {
    _registrar('CallResult:${chamada.acao}', payload);
  }

  @override
  Future<void> responderErroBackend(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  }) async {
    _registrar('CallError:${chamada.acao}', <String, dynamic>{
      'codigo': codigo,
      'descricao': descricao,
      'detalhes': detalhes,
    });
  }

  Future<void> fechar() async {
    await _mensagens.close();
    await _chamadas.close();
  }

  void _registrar(String acao, Map<String, dynamic> payload) {
    registros.add(_RegistroOcpp(acao, payload));
  }
}
