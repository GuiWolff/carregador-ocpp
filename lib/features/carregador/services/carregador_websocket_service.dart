import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:simulador_ocpp/features/carregador/domain/models/mensagem_ocpp.dart';
import 'package:simulador_ocpp/features/carregador/services/carregador_ocpp_client.dart';

typedef TratadorChamadaCarregador =
    FutureOr<Map<String, dynamic>> Function(ChamadaOcpp chamada);

final class CarregadorWebSocketService implements CarregadorOcppClient {
  CarregadorWebSocketService({
    this.incluirAcaoNaResposta = false,
    this.tratadorChamada,
    String Function()? geradorId,
  }) : _geradorId = geradorId;

  final bool incluirAcaoNaResposta;
  final TratadorChamadaCarregador? tratadorChamada;
  final String Function()? _geradorId;

  final StreamController<MensagemOcpp> _mensagensController =
      StreamController<MensagemOcpp>.broadcast();
  final StreamController<ChamadaOcpp> _chamadasDoBackendController =
      StreamController<ChamadaOcpp>.broadcast();
  final Map<String, Completer<RespostaOcpp>> _pendentes =
      <String, Completer<RespostaOcpp>>{};

  WebSocketChannel? _canal;
  StreamSubscription<dynamic>? _assinatura;
  var _contador = 0;
  var _conectado = false;
  var _descartado = false;

  @override
  bool get conectado => _conectado;

  @override
  Stream<MensagemOcpp> get mensagens => _mensagensController.stream;

  @override
  Stream<ChamadaOcpp> get chamadasDoBackend {
    return _chamadasDoBackendController.stream;
  }

  @override
  Future<void> conectar(
    Uri servidor, {
    Iterable<String> protocolos = const <String>['ocpp1.6'],
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _garantirAtivo();
    await desconectar(motivo: 'Reconectando');

    final canal = WebSocketChannel.connect(servidor, protocols: protocolos);
    _canal = canal;

    _assinatura = canal.stream.listen(
      _processarEntrada,
      onError: _processarErroCanal,
      onDone: _processarFechamentoCanal,
      cancelOnError: false,
    );

    try {
      await canal.ready.timeout(timeout);
      _conectado = true;
    } catch (erro, stackTrace) {
      _conectado = false;
      _falharPendentes(erro, stackTrace);
      await _assinatura?.cancel();
      _assinatura = null;
      _canal = null;
      rethrow;
    }
  }

  @override
  Future<RespostaOcpp> enviarChamada(
    String acao,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    _garantirAtivo();
    final canal = _canal;
    if (canal == null || !_conectado) {
      throw StateError('Cliente OCPP não está conectado');
    }

    final id = _proximoId();
    final chamada = ChamadaOcpp(id: id, acao: acao, payload: payload);
    final completer = Completer<RespostaOcpp>();
    _pendentes[id] = completer;

    try {
      canal.sink.add(chamada.codificar());
    } catch (erro, stackTrace) {
      _pendentes.remove(id);
      completer.completeError(erro, stackTrace);
    }

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pendentes.remove(id);
        throw TimeoutException(
          'Tempo limite ao aguardar resposta OCPP para $acao',
          timeout,
        );
      },
    );
  }

  @override
  Future<void> responderChamada(
    ChamadaOcpp chamada,
    Map<String, dynamic> payload,
  ) async {
    final resposta = RespostaOcpp(
      id: chamada.id,
      acao: chamada.acao,
      payload: payload,
    );

    _enviarJson(
      incluirAcaoNaResposta ? resposta.toJsonComAcao() : resposta.toJson(),
    );
  }

  @override
  Future<void> responderErro(
    ChamadaOcpp chamada, {
    String codigo = 'InternalError',
    String descricao = '',
    Map<String, dynamic> detalhes = const <String, dynamic>{},
  }) async {
    _enviarJson(
      ErroOcpp(
        id: chamada.id,
        codigo: codigo,
        descricao: descricao,
        detalhes: detalhes,
      ).toJson(),
    );
  }

  @override
  Future<void> desconectar({int? codigo, String? motivo}) async {
    _conectado = false;
    _falharPendentes(StateError('Conexão OCPP encerrada'));

    final assinatura = _assinatura;
    _assinatura = null;
    await assinatura?.cancel();

    final canal = _canal;
    _canal = null;
    await canal?.sink.close(codigo, motivo);
  }

  @override
  Future<void> dispose() async {
    if (_descartado) {
      return;
    }

    _descartado = true;
    await desconectar(motivo: 'Cliente descartado');
    await _mensagensController.close();
    await _chamadasDoBackendController.close();
  }

  void _processarEntrada(dynamic entrada) {
    try {
      final mensagem = MensagemOcpp.decodificar(_normalizarEntrada(entrada));
      _mensagensController.add(mensagem);

      switch (mensagem) {
        case ChamadaOcpp():
          _chamadasDoBackendController.add(mensagem);
          final tratador = tratadorChamada;
          if (tratador != null) {
            unawaited(_responderComTratador(mensagem, tratador));
          }
        case RespostaOcpp():
          _resolverResposta(mensagem);
        case ErroOcpp():
          _resolverErro(mensagem);
      }
    } catch (erro, stackTrace) {
      _mensagensController.addError(erro, stackTrace);
    }
  }

  Future<void> _responderComTratador(
    ChamadaOcpp chamada,
    TratadorChamadaCarregador tratador,
  ) async {
    try {
      final payload = await tratador(chamada);
      await responderChamada(chamada, payload);
    } catch (erro) {
      await responderErro(
        chamada,
        codigo: 'InternalError',
        descricao: erro.toString(),
      );
    }
  }

  void _resolverResposta(RespostaOcpp resposta) {
    final pendente = _pendentes.remove(resposta.id);
    if (pendente == null || pendente.isCompleted) {
      return;
    }

    pendente.complete(resposta);
  }

  void _resolverErro(ErroOcpp erro) {
    final pendente = _pendentes.remove(erro.id);
    if (pendente == null || pendente.isCompleted) {
      return;
    }

    pendente.completeError(ExcecaoOcppRemota(erro));
  }

  void _processarErroCanal(Object erro, StackTrace stackTrace) {
    _conectado = false;
    _falharPendentes(erro, stackTrace);
    _mensagensController.addError(erro, stackTrace);
  }

  void _processarFechamentoCanal() {
    _conectado = false;
    _falharPendentes(StateError('Conexão OCPP encerrada pelo servidor'));
  }

  void _falharPendentes(Object erro, [StackTrace? stackTrace]) {
    final pendentes = List<Completer<RespostaOcpp>>.from(_pendentes.values);
    _pendentes.clear();

    for (final pendente in pendentes) {
      if (!pendente.isCompleted) {
        if (stackTrace == null) {
          pendente.completeError(erro);
        } else {
          pendente.completeError(erro, stackTrace);
        }
      }
    }
  }

  void _enviarJson(List<Object?> mensagem) {
    _garantirAtivo();
    final canal = _canal;
    if (canal == null || !_conectado) {
      throw StateError('Cliente OCPP não está conectado');
    }

    canal.sink.add(jsonEncode(mensagem));
  }

  String _normalizarEntrada(dynamic entrada) {
    if (entrada is String) {
      return entrada;
    }

    if (entrada is List<int>) {
      return utf8.decode(entrada);
    }

    throw FormatException(
      'Entrada WebSocket OCPP não suportada: ${entrada.runtimeType}',
    );
  }

  String _proximoId() {
    final geradorId = _geradorId;
    if (geradorId != null) {
      return geradorId();
    }

    _contador++;
    return '${DateTime.now().microsecondsSinceEpoch}-$_contador';
  }

  void _garantirAtivo() {
    if (_descartado) {
      throw StateError('Cliente OCPP já foi descartado');
    }
  }
}
