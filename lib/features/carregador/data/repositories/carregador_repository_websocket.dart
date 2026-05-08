import 'package:simulador_ocpp/features/carregador/domain/models/mensagem_ocpp.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/domain/repositories/carregador_repository.dart';
import 'package:simulador_ocpp/features/carregador/services/carregador_ocpp_client.dart';
import 'package:simulador_ocpp/features/carregador/services/carregador_websocket_service.dart';

final class CarregadorRepositoryWebSocket implements CarregadorRepository {
  CarregadorRepositoryWebSocket({CarregadorOcppClient? cliente})
    : _cliente = cliente ?? CarregadorWebSocketService();

  final CarregadorOcppClient _cliente;

  @override
  bool get conectado => _cliente.conectado;

  @override
  Stream<MensagemOcpp> get mensagens => _cliente.mensagens;

  @override
  Stream<ChamadaOcpp> get chamadasDoBackend => _cliente.chamadasDoBackend;

  @override
  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  }) {
    return _cliente.conectar(
      servidor,
      protocolos: protocolos,
      timeout: timeout,
    );
  }

  @override
  Future<void> desconectar() {
    return _cliente.desconectar(motivo: 'Desconectado pelo repositório');
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
  }) {
    _validarTamanho('fabricante', fabricante, 20);
    _validarTamanho('modelo', modelo, 20);
    _validarTamanhoOpcional('numeroSeriePontoCarga', numeroSeriePontoCarga, 25);
    _validarTamanhoOpcional('numeroSerieChargeBox', numeroSerieChargeBox, 25);
    _validarTamanhoOpcional('versaoFirmware', versaoFirmware, 50);
    _validarTamanhoOpcional('iccid', iccid, 20);
    _validarTamanhoOpcional('imsi', imsi, 20);
    _validarTamanhoOpcional('tipoMedidor', tipoMedidor, 25);
    _validarTamanhoOpcional('numeroSerieMedidor', numeroSerieMedidor, 25);

    return _enviar(
      'BootNotification',
      removerNulos(<String, dynamic>{
        'chargePointVendor': fabricante,
        'chargePointModel': modelo,
        'chargePointSerialNumber': numeroSeriePontoCarga,
        'chargeBoxSerialNumber': numeroSerieChargeBox,
        'firmwareVersion': versaoFirmware,
        'iccid': iccid,
        'imsi': imsi,
        'meterType': tipoMedidor,
        'meterSerialNumber': numeroSerieMedidor,
      }),
      timeout: timeout,
    );
  }

  @override
  Future<Map<String, dynamic>> autorizar({
    required String idTag,
    Duration timeout = const Duration(seconds: 30),
  }) {
    _validarTamanho('idTag', idTag, 20);

    return _enviar('Authorize', <String, dynamic>{
      'idTag': idTag,
    }, timeout: timeout);
  }

  @override
  Future<Map<String, dynamic>> enviarHeartbeat({
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _enviar('Heartbeat', <String, dynamic>{}, timeout: timeout);
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
  }) {
    _validarTamanhoOpcional('info', info, 50);
    _validarTamanhoOpcional('vendorId', vendorId, 255);
    _validarTamanhoOpcional('vendorErrorCode', vendorErrorCode, 50);

    return _enviar(
      'StatusNotification',
      removerNulos(<String, dynamic>{
        'connectorId': conectorId,
        'errorCode': codigoErro.valor,
        'status': status.valor,
        'timestamp': data == null ? null : _formatarData(data),
        'info': info,
        'vendorId': vendorId,
        'vendorErrorCode': vendorErrorCode,
      }),
      timeout: timeout,
    );
  }

  @override
  Future<Map<String, dynamic>> iniciarTransacao({
    required int conectorId,
    required String idTag,
    required int medidorInicialWh,
    DateTime? data,
    int? reservaId,
    Duration timeout = const Duration(seconds: 30),
  }) {
    _validarTamanho('idTag', idTag, 20);

    return _enviar(
      'StartTransaction',
      removerNulos(<String, dynamic>{
        'connectorId': conectorId,
        'idTag': idTag,
        'meterStart': medidorInicialWh,
        'reservationId': reservaId,
        'timestamp': _formatarData(data ?? DateTime.now()),
      }),
      timeout: timeout,
    );
  }

  @override
  Future<Map<String, dynamic>> enviarValoresMedidor({
    required int conectorId,
    required List<ValorMedidoOcpp> valores,
    int? transacaoId,
    DateTime? data,
    Duration timeout = const Duration(seconds: 30),
  }) {
    if (valores.isEmpty) {
      throw ArgumentError.value(
        valores,
        'valores',
        'Informe ao menos um valor',
      );
    }

    return _enviar(
      'MeterValues',
      removerNulos(<String, dynamic>{
        'connectorId': conectorId,
        'transactionId': transacaoId,
        'meterValue': <Map<String, dynamic>>[
          <String, dynamic>{
            'timestamp': _formatarData(data ?? DateTime.now()),
            'sampledValue': valores
                .map((valor) => valor.toJson())
                .toList(growable: false),
          },
        ],
      }),
      timeout: timeout,
    );
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
  }) {
    _validarTamanhoOpcional('idTag', idTag, 20);

    return _enviar(
      'StopTransaction',
      removerNulos(<String, dynamic>{
        'transactionId': transacaoId,
        'timestamp': _formatarData(data ?? DateTime.now()),
        'meterStop': medidorFinalWh,
        'idTag': idTag,
        'reason': motivo?.valor,
        'transactionData': valoresTransacao.isEmpty
            ? null
            : <Map<String, dynamic>>[
                <String, dynamic>{
                  'timestamp': _formatarData(data ?? DateTime.now()),
                  'sampledValue': valoresTransacao
                      .map((valor) => valor.toJson())
                      .toList(growable: false),
                },
              ],
      }),
      timeout: timeout,
    );
  }

  @override
  Future<void> responderChamadaBackend(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  ) {
    return _cliente.responderChamada(chamada, payload);
  }

  @override
  Future<void> responderErroBackend(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  }) {
    return _cliente.responderErro(
      chamada,
      codigo: codigo,
      descricao: descricao,
      detalhes: detalhes,
    );
  }

  Future<Map<String, dynamic>> _enviar(
    String acao,
    Map<String, dynamic> payload, {
    required Duration timeout,
  }) async {
    final resposta = await _cliente.enviarChamada(
      acao,
      payload,
      timeout: timeout,
    );
    return resposta.payload;
  }

  String _formatarData(DateTime data) {
    return data.toUtc().toIso8601String();
  }

  void _validarTamanho(String campo, String valor, int maximo) {
    if (valor.length > maximo) {
      throw ArgumentError.value(
        valor,
        campo,
        'O contrato OCPP limita este campo a $maximo caracteres',
      );
    }
  }

  void _validarTamanhoOpcional(String campo, String? valor, int maximo) {
    if (valor == null) {
      return;
    }

    _validarTamanho(campo, valor, maximo);
  }
}
