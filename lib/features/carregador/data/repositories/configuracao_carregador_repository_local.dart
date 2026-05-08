import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/domain/repositories/configuracao_carregador_repository.dart';

final class ConfiguracaoCarregadorRepositoryLocal
    implements ConfiguracaoCarregadorRepository {
  ConfiguracaoCarregadorRepositoryLocal({SharedPreferences? preferencias})
    : _preferencias = preferencias;

  static const chaveConfiguracoes =
      'simulador_ocpp.features.carregador.configuracoes.v1';

  static const _versao = 1;
  final SharedPreferences? _preferencias;

  @override
  Future<List<CarregadorConfigurado>> carregar() async {
    final preferencias = await _obterPreferencias();
    final configuracoesJson = preferencias.getString(chaveConfiguracoes);

    if (configuracoesJson == null || configuracoesJson.isEmpty) {
      return const <CarregadorConfigurado>[];
    }

    try {
      final payload = jsonDecode(configuracoesJson);
      final mapa = _mapaJson(payload);

      if (mapa == null || mapa['versao'] != _versao) {
        return const <CarregadorConfigurado>[];
      }

      final carregadoresJson = mapa['carregadores'];
      if (carregadoresJson is! List) {
        return const <CarregadorConfigurado>[];
      }

      return List<CarregadorConfigurado>.unmodifiable(
        carregadoresJson.map(CarregadorConfigurado.fromJson),
      );
    } on FormatException {
      return const <CarregadorConfigurado>[];
    } on ArgumentError {
      return const <CarregadorConfigurado>[];
    } on TypeError {
      return const <CarregadorConfigurado>[];
    }
  }

  @override
  Future<void> salvar(List<CarregadorConfigurado> carregadores) async {
    final preferencias = await _obterPreferencias();
    final payload = <String, dynamic>{
      'versao': _versao,
      'carregadores': carregadores
          .map((carregador) => carregador.toJson())
          .toList(growable: false),
    };

    await preferencias.setString(chaveConfiguracoes, jsonEncode(payload));
  }

  @override
  Future<void> limpar() async {
    final preferencias = await _obterPreferencias();
    await preferencias.remove(chaveConfiguracoes);
  }

  Future<SharedPreferences> _obterPreferencias() async {
    final preferencias = _preferencias;
    if (preferencias != null) {
      return preferencias;
    }

    return SharedPreferences.getInstance();
  }

  Map<String, dynamic>? _mapaJson(Object? json) {
    if (json is! Map) {
      return null;
    }

    return <String, dynamic>{
      for (final entrada in json.entries)
        if (entrada.key is String) entrada.key as String: entrada.value,
    };
  }
}
