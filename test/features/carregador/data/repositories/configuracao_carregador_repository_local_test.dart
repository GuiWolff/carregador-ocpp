import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('ConfiguracaoCarregadorRepositoryLocal', () {
    test('carrega lista vazia quando nao ha configuracoes salvas', () async {
      final repositorio = await _criarRepositorio();

      final carregadores = await repositorio.carregar();

      expect(carregadores, isEmpty);
    });

    test('salva usando chave versionada e namespaced', () async {
      final repositorio = await _criarRepositorio();
      final preferencias = await SharedPreferences.getInstance();

      await repositorio.salvar(<CarregadorConfigurado>[
        _criarCarregador(id: 'CP-1', tipo: TipoConectorCarregador.ccs2),
      ]);

      expect(
        ConfiguracaoCarregadorRepositoryLocal.chaveConfiguracoes,
        'simulador_ocpp.features.carregador.configuracoes.v1',
      );
      final configuracoesJson = preferencias.getString(
        ConfiguracaoCarregadorRepositoryLocal.chaveConfiguracoes,
      );
      expect(configuracoesJson, isNotNull);

      final payload = jsonDecode(configuracoesJson!) as Map<String, dynamic>;
      expect(payload['versao'], 1);
      expect(payload['carregadores'], <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'CP-1',
          'conectores': <Map<String, dynamic>>[
            <String, dynamic>{'id': 1, 'tipo': 'CCS2'},
          ],
        },
      ]);
    });

    test('carrega configuracoes salvas', () async {
      final repositorio = await _criarRepositorio();
      await repositorio.salvar(<CarregadorConfigurado>[
        _criarCarregador(id: 'CP-1', tipo: TipoConectorCarregador.ccs2),
        _criarCarregador(id: 'CP-2', tipo: TipoConectorCarregador.gbt),
      ]);

      final carregadores = await repositorio.carregar();

      expect(carregadores, hasLength(2));
      expect(carregadores.first.id, 'CP-1');
      expect(carregadores.first.conectores.single.id, 1);
      expect(
        carregadores.first.conectores.single.tipo,
        TipoConectorCarregador.ccs2,
      );
      expect(carregadores.last.id, 'CP-2');
      expect(
        carregadores.last.conectores.single.tipo,
        TipoConectorCarregador.gbt,
      );
    });

    test('limpa configuracoes salvas', () async {
      final repositorio = await _criarRepositorio();
      final preferencias = await SharedPreferences.getInstance();

      await repositorio.salvar(<CarregadorConfigurado>[
        _criarCarregador(id: 'CP-1', tipo: TipoConectorCarregador.ccs2),
      ]);
      await repositorio.limpar();

      expect(
        preferencias.containsKey(
          ConfiguracaoCarregadorRepositoryLocal.chaveConfiguracoes,
        ),
        isFalse,
      );
      expect(await repositorio.carregar(), isEmpty);
    });

    test('retorna lista vazia quando JSON esta invalido', () async {
      final repositorio = await _criarRepositorio(<String, Object>{
        ConfiguracaoCarregadorRepositoryLocal.chaveConfiguracoes:
            '{json-invalido',
      });

      final carregadores = await repositorio.carregar();

      expect(carregadores, isEmpty);
    });

    test('retorna lista vazia quando estado salvo esta corrompido', () async {
      final repositorio = await _criarRepositorio(<String, Object>{
        ConfiguracaoCarregadorRepositoryLocal.chaveConfiguracoes: jsonEncode(
          <String, dynamic>{
            'versao': 1,
            'carregadores': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': ' ',
                'conectores': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 1, 'tipo': 'CCS2'},
                ],
              },
            ],
          },
        ),
      });

      final carregadores = await repositorio.carregar();

      expect(carregadores, isEmpty);
    });
  });
}

Future<ConfiguracaoCarregadorRepositoryLocal> _criarRepositorio([
  Map<String, Object> valoresIniciais = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(valoresIniciais);
  final preferencias = await SharedPreferences.getInstance();
  return ConfiguracaoCarregadorRepositoryLocal(preferencias: preferencias);
}

CarregadorConfigurado _criarCarregador({
  required String id,
  required TipoConectorCarregador tipo,
}) {
  return CarregadorConfigurado(
    id: id,
    conectores: <ConectorCarregadorConfigurado>[
      ConectorCarregadorConfigurado(id: 1, tipo: tipo),
    ],
  );
}
