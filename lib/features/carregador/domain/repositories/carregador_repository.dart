import 'package:simulador_ocpp/features/carregador/domain/models/mensagem_ocpp.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';

abstract interface class CarregadorRepository {
  bool get conectado;

  Stream<MensagemOcpp> get mensagens;

  Stream<ChamadaOcpp> get chamadasDoBackend;

  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  });

  Future<void> desconectar();

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
  });

  Future<Map<String, dynamic>> autorizar({
    required String idTag,
    Duration timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> enviarHeartbeat({
    Duration timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> enviarStatusNotification({
    required int conectorId,
    required StatusConectorOcpp status,
    CodigoErroOcpp codigoErro = CodigoErroOcpp.noError,
    DateTime? data,
    String? info,
    String? vendorId,
    String? vendorErrorCode,
    Duration timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> iniciarTransacao({
    required int conectorId,
    required String idTag,
    required int medidorInicialWh,
    DateTime? data,
    int? reservaId,
    Duration timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> enviarValoresMedidor({
    required int conectorId,
    required List<ValorMedidoOcpp> valores,
    int? transacaoId,
    DateTime? data,
    Duration timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> finalizarTransacao({
    required int transacaoId,
    required int medidorFinalWh,
    DateTime? data,
    String? idTag,
    MotivoFimTransacaoOcpp? motivo,
    List<ValorMedidoOcpp> valoresTransacao = const <ValorMedidoOcpp>[],
    Duration timeout = const Duration(seconds: 30),
  });

  Future<void> responderChamadaBackend(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  );

  Future<void> responderErroBackend(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  });
}
