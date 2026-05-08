import 'dart:convert';

enum TipoMensagemOcpp {
  chamada(2),
  resposta(3),
  erro(4);

  const TipoMensagemOcpp(this.id);

  final int id;

  static TipoMensagemOcpp porId(int id) {
    return switch (id) {
      2 => TipoMensagemOcpp.chamada,
      3 => TipoMensagemOcpp.resposta,
      4 => TipoMensagemOcpp.erro,
      _ => throw FormatException('Tipo de mensagem OCPP desconhecido: $id'),
    };
  }
}

sealed class MensagemOcpp {
  const MensagemOcpp({required this.tipo, required this.id});

  final TipoMensagemOcpp tipo;
  final String id;

  List<Object?> toJson();

  String codificar() => jsonEncode(toJson());

  static MensagemOcpp decodificar(String conteudo) {
    return fromJson(jsonDecode(conteudo));
  }

  static MensagemOcpp fromJson(Object? json) {
    if (json is! List || json.length < 3) {
      throw const FormatException('Mensagem OCPP deve ser um array JSON');
    }

    final tipo = TipoMensagemOcpp.porId(_lerInteiro(json, 0, 'messageTypeId'));

    return switch (tipo) {
      TipoMensagemOcpp.chamada => _lerChamada(json),
      TipoMensagemOcpp.resposta => _lerResposta(json),
      TipoMensagemOcpp.erro => _lerErro(json),
    };
  }

  static ChamadaOcpp _lerChamada(List<dynamic> json) {
    if (json.length != 4) {
      throw FormatException(
        'Chamada OCPP deve ter 4 itens. Recebidos: ${json.length}',
      );
    }

    return ChamadaOcpp(
      id: _lerTexto(json, 1, 'uniqueId'),
      acao: _lerTexto(json, 2, 'action'),
      payload: _lerPayload(json[3]),
    );
  }

  static RespostaOcpp _lerResposta(List<dynamic> json) {
    if (json.length == 3) {
      return RespostaOcpp(
        id: _lerTexto(json, 1, 'uniqueId'),
        payload: _lerPayload(json[2]),
      );
    }

    if (json.length == 4) {
      return RespostaOcpp(
        id: _lerTexto(json, 1, 'uniqueId'),
        acao: _lerTexto(json, 2, 'action'),
        payload: _lerPayload(json[3]),
      );
    }

    throw FormatException(
      'Resposta OCPP deve ter 3 itens no padrão 1.6J ou 4 itens no contrato local. Recebidos: ${json.length}',
    );
  }

  static ErroOcpp _lerErro(List<dynamic> json) {
    if (json.length != 5) {
      throw FormatException(
        'Erro OCPP deve ter 5 itens. Recebidos: ${json.length}',
      );
    }

    return ErroOcpp(
      id: _lerTexto(json, 1, 'uniqueId'),
      codigo: _lerTexto(json, 2, 'errorCode'),
      descricao: _lerTexto(json, 3, 'errorDescription'),
      detalhes: _lerPayload(json[4]),
    );
  }

  static int _lerInteiro(List<dynamic> json, int indice, String campo) {
    final valor = json[indice];
    if (valor is int) {
      return valor;
    }

    throw FormatException('Campo $campo deve ser inteiro');
  }

  static String _lerTexto(List<dynamic> json, int indice, String campo) {
    final valor = json[indice];
    if (valor is String) {
      return valor;
    }

    throw FormatException('Campo $campo deve ser texto');
  }

  static Map<String, dynamic> _lerPayload(Object? valor) {
    if (valor == null) {
      return <String, dynamic>{};
    }

    if (valor is Map) {
      return valor.map((chave, item) => MapEntry(chave.toString(), item));
    }

    throw const FormatException('Payload OCPP deve ser um objeto JSON');
  }
}

final class ChamadaOcpp extends MensagemOcpp {
  const ChamadaOcpp({
    required super.id,
    required this.acao,
    this.payload = const <String, dynamic>{},
  }) : super(tipo: TipoMensagemOcpp.chamada);

  final String acao;
  final Map<String, dynamic> payload;

  @override
  List<Object?> toJson() => <Object?>[tipo.id, id, acao, payload];
}

final class RespostaOcpp extends MensagemOcpp {
  const RespostaOcpp({
    required super.id,
    this.acao,
    this.payload = const <String, dynamic>{},
  }) : super(tipo: TipoMensagemOcpp.resposta);

  final String? acao;
  final Map<String, dynamic> payload;

  @override
  List<Object?> toJson() => <Object?>[tipo.id, id, payload];

  List<Object?> toJsonComAcao() => <Object?>[tipo.id, id, acao, payload];
}

final class ErroOcpp extends MensagemOcpp {
  const ErroOcpp({
    required super.id,
    required this.codigo,
    required this.descricao,
    this.detalhes = const <String, dynamic>{},
  }) : super(tipo: TipoMensagemOcpp.erro);

  final String codigo;
  final String descricao;
  final Map<String, dynamic> detalhes;

  @override
  List<Object?> toJson() => <Object?>[tipo.id, id, codigo, descricao, detalhes];
}

final class ExcecaoOcppRemota implements Exception {
  const ExcecaoOcppRemota(this.erro);

  final ErroOcpp erro;

  @override
  String toString() {
    return 'ExcecaoOcppRemota(${erro.codigo}): ${erro.descricao}';
  }
}
