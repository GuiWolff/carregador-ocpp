import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

void main() {
  group('CarregadorConfigurado', () {
    test('serializa carregador com um conector', () {
      final carregador = CarregadorConfigurado(
        id: 'CP-1',
        conectores: <ConectorCarregadorConfigurado>[
          ConectorCarregadorConfigurado(
            id: 1,
            tipo: TipoConectorCarregador.ccs2,
          ),
        ],
      );

      expect(carregador.toJson(), <String, dynamic>{
        'id': 'CP-1',
        'conectores': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'tipo': 'CCS2'},
        ],
      });
    });

    test('desserializa carregador com dois conectores', () {
      final carregador = CarregadorConfigurado.fromJson(<String, dynamic>{
        'id': 'CP-2',
        'conectores': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'tipo': 'MENNEKES_TYPE_2'},
          <String, dynamic>{'id': 2, 'tipo': 'GBT'},
        ],
      });

      expect(carregador.id, 'CP-2');
      expect(carregador.conectores, hasLength(2));
      expect(carregador.conectores.first.id, 1);
      expect(
        carregador.conectores.first.tipo,
        TipoConectorCarregador.mennekesType2,
      );
      expect(carregador.conectores.last.id, 2);
      expect(carregador.conectores.last.tipo, TipoConectorCarregador.gbt);
    });

    test('exige id do carregador', () {
      expect(
        () => CarregadorConfigurado(
          id: ' ',
          conectores: <ConectorCarregadorConfigurado>[
            ConectorCarregadorConfigurado(
              id: 1,
              tipo: TipoConectorCarregador.ccs2,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('exige 1 ou 2 conectores', () {
      expect(
        () => CarregadorConfigurado(
          id: 'CP-1',
          conectores: <ConectorCarregadorConfigurado>[],
        ),
        throwsArgumentError,
      );

      expect(
        () => CarregadorConfigurado(
          id: 'CP-1',
          conectores: <ConectorCarregadorConfigurado>[
            ConectorCarregadorConfigurado(
              id: 1,
              tipo: TipoConectorCarregador.ccs2,
            ),
            ConectorCarregadorConfigurado(
              id: 2,
              tipo: TipoConectorCarregador.gbt,
            ),
            ConectorCarregadorConfigurado(
              id: 3,
              tipo: TipoConectorCarregador.mennekesType2,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('exige tipo definido em cada conector', () {
      expect(
        () => CarregadorConfigurado.fromJson(<String, dynamic>{
          'id': 'CP-1',
          'conectores': <Map<String, dynamic>>[
            <String, dynamic>{'id': 1},
          ],
        }),
        throwsFormatException,
      );
    });

    test('rejeita tipo de conector desconhecido', () {
      expect(
        () => ConectorCarregadorConfigurado.fromJson(<String, dynamic>{
          'id': 1,
          'tipo': 'CHADEMO',
        }),
        throwsFormatException,
      );
    });
  });
}
