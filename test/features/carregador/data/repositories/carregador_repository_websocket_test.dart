import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('CarregadorRepositoryWebSocket', () {
    test('monta payload de BootNotification conforme contrato', () async {
      final cliente = _CarregadorOcppClientFalso()
        ..respostas['BootNotification'] = <String, dynamic>{
          'status': 'Accepted',
        };
      final repository = CarregadorRepositoryWebSocket(cliente: cliente);

      final resposta = await repository.enviarBootNotification(
        fabricante: 'Argo',
        modelo: 'EV-1',
        versaoFirmware: '1.0.0',
      );

      expect(resposta['status'], 'Accepted');
      expect(cliente.chamadas.single.acao, 'BootNotification');
      expect(cliente.chamadas.single.payload, <String, dynamic>{
        'chargePointVendor': 'Argo',
        'chargePointModel': 'EV-1',
        'firmwareVersion': '1.0.0',
      });
    });

    test('monta payload de MeterValues com valor medido', () async {
      final cliente = _CarregadorOcppClientFalso();
      final repository = CarregadorRepositoryWebSocket(cliente: cliente);
      final data = DateTime.utc(2026, 5, 7, 12);

      await repository.enviarValoresMedidor(
        conectorId: 1,
        transacaoId: 10,
        data: data,
        valores: const <ValorMedidoOcpp>[
          ValorMedidoOcpp(
            valor: '82',
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.soc,
            unidade: UnidadeMedicaoOcpp.percentual,
          ),
        ],
      );

      expect(cliente.chamadas.single.acao, 'MeterValues');
      expect(cliente.chamadas.single.payload, <String, dynamic>{
        'connectorId': 1,
        'transactionId': 10,
        'meterValue': <Map<String, dynamic>>[
          <String, dynamic>{
            'timestamp': '2026-05-07T12:00:00.000Z',
            'sampledValue': <Map<String, dynamic>>[
              <String, dynamic>{
                'value': '82',
                'context': 'Sample.Periodic',
                'measurand': 'SoC',
                'unit': 'Percent',
              },
            ],
          },
        ],
      });
    });

    test('valida tamanho máximo do idTag', () {
      final repository = CarregadorRepositoryWebSocket(
        cliente: _CarregadorOcppClientFalso(),
      );

      expect(
        () => repository.autorizar(idTag: '123456789012345678901'),
        throwsArgumentError,
      );
    });
  });
}

final class _CarregadorOcppClientFalso implements CarregadorOcppClient {
  final List<ChamadaOcpp> chamadas = <ChamadaOcpp>[];
  final Map<String, Map<String, dynamic>> respostas =
      <String, Map<String, dynamic>>{};
  final StreamController<MensagemOcpp> _mensagens =
      StreamController<MensagemOcpp>.broadcast();
  final StreamController<ChamadaOcpp> _chamadasDoBackend =
      StreamController<ChamadaOcpp>.broadcast();

  @override
  bool get conectado => true;

  @override
  Stream<MensagemOcpp> get mensagens => _mensagens.stream;

  @override
  Stream<ChamadaOcpp> get chamadasDoBackend => _chamadasDoBackend.stream;

  @override
  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  }) async {}

  @override
  Future<RespostaOcpp> enviarChamada(
    String acao,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final chamada = ChamadaOcpp(
      id: '${chamadas.length + 1}',
      acao: acao,
      payload: payload,
    );
    chamadas.add(chamada);

    return RespostaOcpp(
      id: chamada.id,
      acao: acao,
      payload: respostas[acao] ?? const <String, dynamic>{},
    );
  }

  @override
  Future<void> responderChamada(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  ) async {}

  @override
  Future<void> responderErro(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  }) async {}

  @override
  Future<void> desconectar({int? codigo, String? motivo}) async {}

  @override
  Future<void> dispose() async {
    await _mensagens.close();
    await _chamadasDoBackend.close();
  }
}
