import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('MensagemOcpp', () {
    test('decodifica chamada no formato OCPP 1.6J', () {
      final mensagem = MensagemOcpp.decodificar('[2,"abc-1","Heartbeat",{}]');

      expect(mensagem, isA<ChamadaOcpp>());
      final chamada = mensagem as ChamadaOcpp;
      expect(chamada.id, 'abc-1');
      expect(chamada.acao, 'Heartbeat');
      expect(chamada.payload, isEmpty);
    });

    test('serializa chamada como array OCPP', () {
      const chamada = ChamadaOcpp(
        id: 'abc-2',
        acao: 'Authorize',
        payload: <String, dynamic>{'idTag': 'TAG-1'},
      );

      expect(chamada.toJson(), <Object?>[
        2,
        'abc-2',
        'Authorize',
        <String, dynamic>{'idTag': 'TAG-1'},
      ]);
    });

    test('decodifica resposta padrão sem action', () {
      final mensagem = MensagemOcpp.decodificar(
        '[3,"abc-3",{"currentTime":"2026-05-07T10:00:00Z"}]',
      );

      expect(mensagem, isA<RespostaOcpp>());
      final resposta = mensagem as RespostaOcpp;
      expect(resposta.id, 'abc-3');
      expect(resposta.acao, isNull);
      expect(resposta.payload['currentTime'], '2026-05-07T10:00:00Z');
    });

    test('decodifica resposta com action do contrato local', () {
      final mensagem = MensagemOcpp.decodificar(
        '[3,"abc-4","BootNotification",{"status":"Accepted"}]',
      );

      expect(mensagem, isA<RespostaOcpp>());
      final resposta = mensagem as RespostaOcpp;
      expect(resposta.id, 'abc-4');
      expect(resposta.acao, 'BootNotification');
      expect(resposta.payload['status'], 'Accepted');
    });

    test('decodifica erro remoto OCPP', () {
      final mensagem = MensagemOcpp.decodificar(
        '[4,"abc-5","NotSupported","Ação não suportada",{}]',
      );

      expect(mensagem, isA<ErroOcpp>());
      final erro = mensagem as ErroOcpp;
      expect(erro.codigo, 'NotSupported');
      expect(erro.descricao, 'Ação não suportada');
    });
  });
}
