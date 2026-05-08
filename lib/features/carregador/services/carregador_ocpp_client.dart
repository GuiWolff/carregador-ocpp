import 'dart:async';

import 'package:simulador_ocpp/features/carregador/domain/models/mensagem_ocpp.dart';

abstract interface class CarregadorOcppClient {
  bool get conectado;

  Stream<MensagemOcpp> get mensagens;

  Stream<ChamadaOcpp> get chamadasDoBackend;

  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  });

  Future<RespostaOcpp> enviarChamada(
    String acao,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 30),
  });

  Future<void> responderChamada(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  );

  Future<void> responderErro(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  });

  Future<void> desconectar({int? codigo, String? motivo});

  Future<void> dispose();
}
