import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';

abstract interface class ConfiguracaoCarregadorRepository {
  Future<List<CarregadorConfigurado>> carregar();

  Future<void> salvar(List<CarregadorConfigurado> carregadores);

  Future<void> limpar();
}
