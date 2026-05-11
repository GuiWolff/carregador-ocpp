import 'dart:async';
import 'dart:math';

import 'package:simulador_ocpp/features/carregador/data/repositories/carregador_repository_websocket.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/mensagem_ocpp.dart';
import 'package:simulador_ocpp/features/carregador/domain/models/modelos_carregador.dart';
import 'package:simulador_ocpp/features/carregador/domain/repositories/carregador_repository.dart';
import 'package:simulador_ocpp/observable/rx.dart';

enum EstadoCarregador {
  desconectado,
  conectando,
  disponivel,
  preparando,
  carregando,
  pausado,
  finalizando,
  falha,
}

extension EstadoCarregadorDescricao on EstadoCarregador {
  String get rotulo {
    return switch (this) {
      EstadoCarregador.desconectado => 'Desconectado',
      EstadoCarregador.conectando => 'Conectando',
      EstadoCarregador.disponivel => 'Disponivel',
      EstadoCarregador.preparando => 'Preparando',
      EstadoCarregador.carregando => 'Carregando',
      EstadoCarregador.pausado => 'Pausado',
      EstadoCarregador.finalizando => 'Finalizando',
      EstadoCarregador.falha => 'Falha',
    };
  }
}

const _temperaturaAmbienteSimuladaC = 28.0;
const _temperaturaMinimaSimuladaC = 18.0;
const _temperaturaMaximaSimuladaC = 58.0;

class CarregadorWidgetViewModel {
  CarregadorWidgetViewModel({
    CarregadorRepository? repository,
    Uri? servidorInicial,
    String idTagInicial = 'TAG-001',
    int conectorIdInicial = 1,
    Iterable<int>? idsConectoresConfigurados,
    int medidorInicialWh = 0,
    double potenciaInicialW = 7400,
    double socInicial = 30,
    double temperaturaInicialC = 34,
    double capacidadeBateriaInicialKwh = 60,
    DateTime Function()? agora,
  }) : _repository = repository ?? CarregadorRepositoryWebSocket(),
       _medidorInicialPadraoWh = medidorInicialWh,
       _potenciaInicialPadraoW = potenciaInicialW,
       _socInicialPadrao = socInicial,
       _temperaturaInicialPadraoC = temperaturaInicialC,
       _capacidadeBateriaInicialPadraoKwh = capacidadeBateriaInicialKwh,
       _agora = agora ?? DateTime.now,
       servidor = Rx<Uri>(
         servidorInicial ?? Uri.parse('ws://localhost:5001/OCPP/A'),
       ),
       idTag = Rx<String>(idTagInicial),
       conectorId = Rx<int>(conectorIdInicial),
       medidorWh = Rx<int>(medidorInicialWh),
       medidorInicioTransacaoWh = Rx<int>(medidorInicialWh),
       potenciaW = Rx<double>(potenciaInicialW),
       soc = Rx<double>(socInicial),
       temperaturaC = Rx<double>(temperaturaInicialC),
       capacidadeBateriaKwh = Rx<double>(capacidadeBateriaInicialKwh),
       tempoCarregamento = Rx<Duration>(Duration.zero),
       statusConectores = Rx<Map<int, StatusConectorOcpp>>(
         _criarStatusConectoresIniciais(
           idsConectoresConfigurados,
           conectorIdInicial,
         ),
       ) {
    _inicializarEstadosConectores(
      idsConectoresConfigurados: idsConectoresConfigurados,
      conectorIdInicial: conectorIdInicial,
    );
    _sincronizarRxComEstado(
      conectorIdInicial,
      _obterEstadoConector(conectorIdInicial),
    );
    _assinarMensagens();
  }

  final CarregadorRepository _repository;
  final int _medidorInicialPadraoWh;
  final double _potenciaInicialPadraoW;
  final double _socInicialPadrao;
  final double _temperaturaInicialPadraoC;
  final double _capacidadeBateriaInicialPadraoKwh;
  final DateTime Function() _agora;

  final Rx<Uri> servidor;
  final Rx<String> idTag;
  final Rx<int> conectorId;
  final Rx<int> medidorWh;
  final Rx<int> medidorInicioTransacaoWh;
  final Rx<double> potenciaW;
  final Rx<double> soc;
  final Rx<double> temperaturaC;
  final Rx<double> capacidadeBateriaKwh;
  final Rx<Duration> tempoCarregamento;
  final Rx<Map<int, StatusConectorOcpp>> statusConectores;

  final conectado = Rx<bool>(false);
  final ocupado = Rx<bool>(false);
  final erro = Rx<String?>(null);
  final estado = Rx<EstadoCarregador>(EstadoCarregador.desconectado);
  final statusConector = Rx<StatusConectorOcpp>(StatusConectorOcpp.available);
  final transacaoId = Rx<int?>(null);
  final intervaloHeartbeat = Rx<Duration>(const Duration(minutes: 5));
  final eventos = Rx<List<String>>(const <String>[]);

  StreamSubscription<MensagemOcpp>? _assinaturaMensagens;
  StreamSubscription<ChamadaOcpp>? _assinaturaChamadas;
  Timer? _heartbeatTimer;
  final Map<int, _EstadoOperacionalConector> _estadosPorConector =
      <int, _EstadoOperacionalConector>{};
  var _conectorZeroEnviado = false;
  var _descartado = false;

  double get energiaFornecidaKwh {
    final energiaWh = max(0, medidorWh.value - medidorInicioTransacaoWh.value);
    return energiaWh / 1000;
  }

  Duration? get tempoRestante {
    final potenciaKw = potenciaW.value / 1000;
    final capacidade = capacidadeBateriaKwh.value;

    if (potenciaKw <= 0 || capacidade <= 0 || soc.value >= 100) {
      return null;
    }

    final energiaRestanteKwh = capacidade * ((100 - soc.value) / 100);
    return Duration(minutes: ((energiaRestanteKwh / potenciaKw) * 60).ceil());
  }

  bool get carregando {
    return estado.value == EstadoCarregador.carregando;
  }

  DadosOperacionaisConectorCarregador dadosDoConector(int id) {
    if (id == conectorId.value) {
      return DadosOperacionaisConectorCarregador(
        medidorWh: medidorWh.value,
        medidorInicioTransacaoWh: medidorInicioTransacaoWh.value,
        potenciaW: potenciaW.value,
        soc: soc.value,
        temperaturaC: temperaturaC.value,
        capacidadeBateriaKwh: capacidadeBateriaKwh.value,
        tempoCarregamento: tempoCarregamento.value,
        transacaoId: transacaoId.value,
        statusConector: statusConector.value,
        estado: estado.value,
      );
    }

    final estadoConector = _obterEstadoConector(id);

    return DadosOperacionaisConectorCarregador(
      medidorWh: estadoConector.medidorWh,
      medidorInicioTransacaoWh: estadoConector.medidorInicioTransacaoWh,
      potenciaW: estadoConector.potenciaW,
      soc: estadoConector.soc,
      temperaturaC: estadoConector.temperaturaC,
      capacidadeBateriaKwh: estadoConector.capacidadeBateriaKwh,
      tempoCarregamento: estadoConector.tempoCarregamento,
      transacaoId: estadoConector.transacaoId,
      statusConector: estadoConector.statusConector,
      estado: estadoConector.estado,
    );
  }

  StatusConectorOcpp statusDoConector(int id) {
    return statusConectores.value[id] ?? StatusConectorOcpp.available;
  }

  void _inicializarEstadosConectores({
    required Iterable<int>? idsConectoresConfigurados,
    required int conectorIdInicial,
  }) {
    for (final id in _normalizarIdsConectores(
      idsConectoresConfigurados,
      conectorIdInicial,
    )) {
      _estadosPorConector.putIfAbsent(id, _criarEstadoPadrao);
    }
  }

  _EstadoOperacionalConector _criarEstadoPadrao() {
    return _EstadoOperacionalConector(
      medidorWh: _medidorInicialPadraoWh,
      medidorInicioTransacaoWh: _medidorInicialPadraoWh,
      potenciaW: _potenciaInicialPadraoW,
      soc: _socInicialPadrao,
      temperaturaC: _temperaturaInicialPadraoC,
      capacidadeBateriaKwh: _capacidadeBateriaInicialPadraoKwh,
      tempoCarregamento: Duration.zero,
      transacaoId: null,
      statusConector: StatusConectorOcpp.available,
      estado: conectado.value
          ? EstadoCarregador.disponivel
          : EstadoCarregador.desconectado,
    );
  }

  _EstadoOperacionalConector _estadoConectorAtivo() {
    return _obterEstadoConector(conectorId.value);
  }

  _EstadoOperacionalConector _obterEstadoConector(int id) {
    return _estadosPorConector.putIfAbsent(id, _criarEstadoPadrao);
  }

  void _persistirRxNoEstadoAtivo() {
    final estadoConector = _estadoConectorAtivo()
      ..medidorWh = medidorWh.value
      ..medidorInicioTransacaoWh = medidorInicioTransacaoWh.value
      ..potenciaW = potenciaW.value
      ..soc = soc.value
      ..temperaturaC = temperaturaC.value
      ..capacidadeBateriaKwh = capacidadeBateriaKwh.value
      ..tempoCarregamento = tempoCarregamento.value
      ..transacaoId = transacaoId.value
      ..statusConector = statusConector.value
      ..estado = estado.value;

    _publicarStatusConector(conectorId.value, estadoConector.statusConector);
  }

  void _sincronizarRxComEstado(
    int id,
    _EstadoOperacionalConector estadoConector,
  ) {
    medidorWh.value = estadoConector.medidorWh;
    medidorInicioTransacaoWh.value = estadoConector.medidorInicioTransacaoWh;
    potenciaW.value = estadoConector.potenciaW;
    soc.value = estadoConector.soc;
    temperaturaC.value = estadoConector.temperaturaC;
    capacidadeBateriaKwh.value = estadoConector.capacidadeBateriaKwh;
    tempoCarregamento.value = estadoConector.tempoCarregamento;
    transacaoId.value = estadoConector.transacaoId;
    statusConector.value = estadoConector.statusConector;
    estado.value = estadoConector.estado;
    _publicarStatusConector(id, estadoConector.statusConector);
  }

  void _publicarStatusConector(int id, StatusConectorOcpp status) {
    if (id < 1) {
      return;
    }

    final statusAtuais = statusConectores.value;
    if (statusAtuais.containsKey(id) && statusAtuais[id] == status) {
      return;
    }

    statusConectores.value = Map<int, StatusConectorOcpp>.unmodifiable(
      <int, StatusConectorOcpp>{...statusAtuais, id: status},
    );
  }

  void _atualizarMedidorAtivo(int valor) {
    _atualizarMedidorDoConector(conectorId.value, valor);
  }

  void _atualizarMedidorDoConector(int id, int valor) {
    _obterEstadoConector(id).medidorWh = valor;
    if (id == conectorId.value) {
      medidorWh.value = valor;
    }
  }

  void _atualizarMedidorInicioTransacaoDoConector(int id, int valor) {
    _obterEstadoConector(id).medidorInicioTransacaoWh = valor;
    if (id == conectorId.value) {
      medidorInicioTransacaoWh.value = valor;
    }
  }

  void _atualizarPotenciaAtiva(double valor) {
    _atualizarPotenciaDoConector(conectorId.value, valor);
  }

  void _atualizarPotenciaDoConector(int id, double valor) {
    _obterEstadoConector(id).potenciaW = valor;
    if (id == conectorId.value) {
      potenciaW.value = valor;
    }
  }

  void _atualizarSocAtivo(double valor) {
    _atualizarSocDoConector(conectorId.value, valor);
  }

  void _atualizarSocDoConector(int id, double valor) {
    _obterEstadoConector(id).soc = valor;
    if (id == conectorId.value) {
      soc.value = valor;
    }
  }

  void _atualizarTemperaturaAtiva(double valor) {
    _atualizarTemperaturaDoConector(conectorId.value, valor);
  }

  void _atualizarTemperaturaDoConector(int id, double valor) {
    _obterEstadoConector(id).temperaturaC = valor;
    if (id == conectorId.value) {
      temperaturaC.value = valor;
    }
  }

  void _atualizarTempoCarregamentoDoConector(int id, Duration valor) {
    _obterEstadoConector(id).tempoCarregamento = valor;
    if (id == conectorId.value) {
      tempoCarregamento.value = valor;
    }
  }

  void _atualizarTransacaoAtiva(int? valor) {
    _atualizarTransacaoDoConector(conectorId.value, valor);
  }

  void _atualizarTransacaoDoConector(int id, int? valor) {
    _obterEstadoConector(id).transacaoId = valor;
    if (id == conectorId.value) {
      transacaoId.value = valor;
    }
  }

  void _atualizarEstadoAtivo(EstadoCarregador valor) {
    _atualizarEstadoDoConector(conectorId.value, valor);
  }

  void _atualizarEstadoDoConector(int id, EstadoCarregador valor) {
    _obterEstadoConector(id).estado = valor;
    if (id == conectorId.value) {
      estado.value = valor;
    }
  }

  Future<void> conectar({String? servidorTexto}) {
    return _executar(() => _conectarInterno(servidorTexto: servidorTexto));
  }

  Future<void> desconectar() {
    return _executar(() async {
      _pararTimers();
      _reiniciarTempoCarregamento();
      await _repository.desconectar();
      conectado.value = false;
      _atualizarTransacaoAtiva(null);
      _atualizarEstadoAtivo(EstadoCarregador.desconectado);
      _aplicarStatusConector(conectorId.value, StatusConectorOcpp.unavailable);
      _registrarEvento('WebSocket desconectado');
    });
  }

  Future<void> autorizar() {
    return _executar(() async {
      await _autorizarIdTag();
    });
  }

  Future<void> iniciarCarregamento({bool autorizarAntes = true}) {
    return _executar(() async {
      if (!conectado.value) {
        await _conectarInterno();
      }

      final idConector = conectorId.value;
      final estadoConector = _obterEstadoConector(idConector);
      final medidorInicialWh = estadoConector.medidorWh;
      final tag = idTag.value;

      _atualizarEstadoDoConector(idConector, EstadoCarregador.preparando);
      _aplicarStatusConector(idConector, StatusConectorOcpp.preparing);
      await _enviarStatusAtualDoConector(idConector);

      if (autorizarAntes) {
        await _autorizarIdTag();
      }

      final resposta = await _repository.iniciarTransacao(
        conectorId: idConector,
        idTag: tag,
        medidorInicialWh: medidorInicialWh,
      );

      final idTransacao = _lerInteiroOpcional(resposta['transactionId']);
      _atualizarTransacaoDoConector(idConector, idTransacao);
      _atualizarMedidorInicioTransacaoDoConector(idConector, medidorInicialWh);
      _reiniciarTempoCarregamentoDoConector(idConector);
      _atualizarEstadoDoConector(idConector, EstadoCarregador.carregando);
      _aplicarStatusConector(idConector, StatusConectorOcpp.charging);
      _obterEstadoConector(idConector).ultimaAtualizacaoMedidor = _agora();
      _iniciarTempoCarregamentoDoConector(idConector);
      _iniciarEnvioPeriodicoValores(idConector: idConector);

      _registrarEvento(
        'Transacao iniciada'
        '${idTransacao == null ? '' : ' #$idTransacao'}',
      );

      await _enviarStatusAtualDoConector(idConector);
      await _enviarValoresMedidorInterno(idConector: idConector);
    });
  }

  Future<void> pausarCarregamento() {
    return _executar(() async {
      final idConector = conectorId.value;
      final estadoConector = _obterEstadoConector(idConector);
      if (!conectado.value ||
          estadoConector.estado != EstadoCarregador.carregando) {
        return;
      }

      _pararEnvioPeriodicoValoresDoConector(idConector);
      _acumularTempoCarregamentoDoConector(idConector);
      _pararTimerTempoCarregamentoDoConector(idConector);
      _atualizarEstadoDoConector(idConector, EstadoCarregador.pausado);
      _aplicarStatusConector(idConector, StatusConectorOcpp.suspendedEv);
      _registrarEvento('Carregamento pausado');
      await _enviarStatusAtualDoConector(idConector);
    });
  }

  Future<void> retomarCarregamento() {
    return _executar(() async {
      final idConector = conectorId.value;
      final estadoConector = _obterEstadoConector(idConector);
      if (!conectado.value ||
          estadoConector.estado != EstadoCarregador.pausado) {
        return;
      }

      _atualizarEstadoDoConector(idConector, EstadoCarregador.carregando);
      _aplicarStatusConector(idConector, StatusConectorOcpp.charging);
      estadoConector.ultimaAtualizacaoMedidor = _agora();
      _iniciarTempoCarregamentoDoConector(idConector);
      _iniciarEnvioPeriodicoValores(idConector: idConector);
      _registrarEvento('Carregamento retomado');
      await _enviarStatusAtualDoConector(idConector);
    });
  }

  Future<void> pararCarregamento({
    MotivoFimTransacaoOcpp motivo = MotivoFimTransacaoOcpp.local,
  }) {
    return _executar(() async {
      if (!conectado.value) {
        return;
      }

      final idConector = conectorId.value;
      final estadoConector = _obterEstadoConector(idConector);
      _pararEnvioPeriodicoValoresDoConector(idConector);
      _incrementarMedidorPorTempoDoConector(idConector);
      _atualizarTempoCarregamentoDoConectorAtual(idConector);
      _pararTimerTempoCarregamentoDoConector(idConector);
      _atualizarEstadoDoConector(idConector, EstadoCarregador.finalizando);
      _aplicarStatusConector(idConector, StatusConectorOcpp.finishing);
      await _enviarStatusAtualDoConector(idConector);

      final id = estadoConector.transacaoId;
      if (id != null) {
        await _enviarValoresMedidorInterno(idConector: idConector);
        await _repository.finalizarTransacao(
          transacaoId: id,
          medidorFinalWh: estadoConector.medidorWh,
          idTag: idTag.value,
          motivo: motivo,
        );
      }

      _atualizarTransacaoDoConector(idConector, null);
      _atualizarMedidorInicioTransacaoDoConector(
        idConector,
        estadoConector.medidorWh,
      );
      _atualizarEstadoDoConector(idConector, EstadoCarregador.disponivel);
      _aplicarStatusConector(idConector, StatusConectorOcpp.available);
      _registrarEvento('Transacao finalizada');
      await _enviarStatusAtualDoConector(idConector);
    });
  }

  Future<void> enviarHeartbeat() {
    return _executar(() async {
      await _repository.enviarHeartbeat();
      _registrarEvento('Heartbeat enviado');
    });
  }

  Future<void> enviarStatusAtual() {
    return _executarSemOcupacao(() async {
      await _enviarStatusAtualDoConector(conectorId.value);
    });
  }

  Future<void> enviarValoresMedidor({bool incrementarAntes = false}) {
    return _executarSemOcupacao(() async {
      final idConector = conectorId.value;
      if (incrementarAntes) {
        _incrementarMedidorPorTempoDoConector(idConector);
      }

      await _enviarValoresMedidorInterno(idConector: idConector);
    });
  }

  Future<void> alterarStatus(StatusConectorOcpp status) {
    return alterarStatusDoConector(conectorId.value, status);
  }

  Future<void> alterarStatusDoConector(int id, StatusConectorOcpp status) {
    return _executar(() async {
      selecionarConector(id);
      _aplicarStatusConector(id, status);
      _atualizarEstadoAtivo(_estadoPorStatus(status));
      await enviarStatusAtual();
    });
  }

  void selecionarConector(int id) {
    if (id < 1) {
      return;
    }

    _persistirRxNoEstadoAtivo();
    conectorId.value = id;
    _sincronizarRxComEstado(id, _obterEstadoConector(id));
  }

  void _selecionarConectorPorTransacao(int idTransacao) {
    for (final MapEntry<int, _EstadoOperacionalConector> entry
        in _estadosPorConector.entries) {
      if (entry.value.transacaoId == idTransacao) {
        selecionarConector(entry.key);
        return;
      }
    }
  }

  void atualizarIdTag(String valor) {
    idTag.value = valor.trim();
  }

  void atualizarConectorId(String valor) {
    final parsed = int.tryParse(valor.trim());
    if (parsed == null || parsed < 1) {
      return;
    }

    selecionarConector(parsed);
  }

  void atualizarPotencia(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null || parsed < 0) {
      return;
    }

    _atualizarPotenciaAtiva(parsed);
  }

  void atualizarMedidor(String valor) {
    final parsed = int.tryParse(valor.trim());
    if (parsed == null || parsed < 0) {
      return;
    }

    _atualizarMedidorAtivo(parsed);
  }

  void atualizarSoc(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null) {
      return;
    }

    _atualizarSocAtivo(parsed.clamp(0, 100).toDouble());
  }

  void atualizarTemperatura(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null) {
      return;
    }

    _atualizarTemperaturaAtiva(parsed);
  }

  void dispose() {
    if (_descartado) {
      return;
    }

    _descartado = true;
    _pararTimers();
    unawaited(_assinaturaMensagens?.cancel());
    unawaited(_assinaturaChamadas?.cancel());
    unawaited(_repository.desconectar());

    servidor.dispose();
    idTag.dispose();
    conectorId.dispose();
    medidorWh.dispose();
    medidorInicioTransacaoWh.dispose();
    potenciaW.dispose();
    soc.dispose();
    temperaturaC.dispose();
    capacidadeBateriaKwh.dispose();
    tempoCarregamento.dispose();
    statusConectores.dispose();
    conectado.dispose();
    ocupado.dispose();
    erro.dispose();
    estado.dispose();
    statusConector.dispose();
    transacaoId.dispose();
    intervaloHeartbeat.dispose();
    eventos.dispose();
  }

  Future<void> _conectarInterno({String? servidorTexto}) async {
    servidor.value = _lerServidor(servidorTexto ?? servidor.value.toString());
    _atualizarEstadoAtivo(EstadoCarregador.conectando);
    _conectorZeroEnviado = false;

    await _repository.conectar(servidor.value);
    conectado.value = true;
    _atualizarEstadoAtivo(EstadoCarregador.disponivel);
    _aplicarStatusConector(conectorId.value, StatusConectorOcpp.available);
    _registrarEvento('WebSocket conectado em ${servidor.value}');

    final bootNotification = await _repository.enviarBootNotification(
      fabricante: 'Argo',
      modelo: 'Simulador-OCPP',
      numeroSeriePontoCarga: 'argo-point-${conectorId.value}',
      numeroSerieChargeBox: 'argo-box-${conectorId.value}',
      versaoFirmware: '1.0.0',
      tipoMedidor: 'SIMULATOR',
      numeroSerieMedidor: 'argo-meter-${conectorId.value}',
    );

    _aplicarRespostaBootNotification(bootNotification);
    await enviarStatusAtual();
  }

  void _assinarMensagens() {
    _assinaturaMensagens = _repository.mensagens.listen(
      (mensagem) => _registrarEvento(_descreverMensagemRecebida(mensagem)),
      onError: (Object error) => _registrarErro(error),
    );

    _assinaturaChamadas = _repository.chamadasDoBackend.listen(
      (chamada) => unawaited(_processarChamadaBackend(chamada)),
      onError: (Object error) => _registrarErro(error),
    );
  }

  Future<void> _processarChamadaBackend(ChamadaOcpp chamada) async {
    try {
      _registrarEvento('Comando remoto recebido: ${chamada.acao}');

      switch (chamada.acao) {
        case 'Reset':
          await _repository.responderChamadaBackend(
            chamada,
            const <String, dynamic>{'status': 'Accepted'},
          );
          await desconectar();
        case 'RemoteStopTransaction':
          final id = _lerInteiroOpcional(chamada.payload['transactionId']);
          final connector = _lerInteiroOpcional(chamada.payload['connectorId']);
          if (connector != null) {
            selecionarConector(connector);
          } else if (id != null) {
            _selecionarConectorPorTransacao(id);
          }
          await _repository.responderChamadaBackend(
            chamada,
            const <String, dynamic>{'status': 'Accepted'},
          );
          await pararCarregamento(motivo: MotivoFimTransacaoOcpp.remote);
        case 'RemoteStartTransaction':
          final tag = chamada.payload['idTag'];
          final connector = _lerInteiroOpcional(chamada.payload['connectorId']);
          if (tag is String) {
            idTag.value = tag;
          }
          if (connector != null) {
            selecionarConector(connector);
          }

          await _repository.responderChamadaBackend(
            chamada,
            const <String, dynamic>{'status': 'Accepted'},
          );
          await iniciarCarregamento(autorizarAntes: false);
        case 'GetConfiguration':
          await _repository.responderChamadaBackend(chamada, <String, dynamic>{
            'configurationKey': <Map<String, dynamic>>[
              <String, dynamic>{
                'key': 'HeartbeatInterval',
                'readonly': false,
                'value': intervaloHeartbeat.value.inSeconds.toString(),
              },
            ],
          });
        case 'ChangeConfiguration':
          _aplicarChangeConfiguration(chamada.payload);
          await _repository.responderChamadaBackend(
            chamada,
            const <String, dynamic>{'status': 'Accepted'},
          );
        case 'ClearChargingProfile':
        case 'SetChargingProfile':
        case 'UnlockConnector':
          await _repository.responderChamadaBackend(
            chamada,
            const <String, dynamic>{'status': 'Accepted'},
          );
        case 'TriggerMessage':
          await _processarTriggerMessage(chamada);
        default:
          await _repository.responderErroBackend(
            chamada,
            codigo: 'NotSupported',
            descricao: 'Acao OCPP nao suportada pelo simulador',
          );
      }
    } catch (error) {
      _registrarErro(error);
      await _repository.responderErroBackend(
        chamada,
        codigo: 'InternalError',
        descricao: error.toString(),
      );
    }
  }

  Future<void> _processarTriggerMessage(ChamadaOcpp chamada) async {
    final mensagemSolicitada = chamada.payload['requestedMessage'];
    if (mensagemSolicitada == 'MeterValues') {
      await _repository.responderChamadaBackend(
        chamada,
        const <String, dynamic>{'status': 'Accepted'},
      );
      await enviarValoresMedidor();
      return;
    }

    if (mensagemSolicitada == 'Heartbeat') {
      await _repository.responderChamadaBackend(
        chamada,
        const <String, dynamic>{'status': 'Accepted'},
      );
      await enviarHeartbeat();
      return;
    }

    await _repository.responderChamadaBackend(chamada, const <String, dynamic>{
      'status': 'Rejected',
    });
  }

  void _aplicarStatusConector(int id, StatusConectorOcpp status) {
    if (id < 1) {
      return;
    }

    _obterEstadoConector(id).statusConector = status;
    if (id == conectorId.value) {
      statusConector.value = status;
    }
    _publicarStatusConector(id, status);
  }

  Future<void> _autorizarIdTag() async {
    if (idTag.value.isEmpty) {
      throw StateError('Informe uma tag antes de autorizar');
    }

    final resposta = await _repository.autorizar(idTag: idTag.value);
    final idTagInfo = resposta['idTagInfo'];
    final status = idTagInfo is Map ? idTagInfo['status'] : null;

    if (status != null && status != 'Accepted') {
      throw StateError('Tag recusada pelo backend: $status');
    }

    _registrarEvento('Tag autorizada: ${idTag.value}');
  }

  Future<void> _enviarStatusAtualDoConector(int idConector) async {
    if (!conectado.value) {
      return;
    }

    if (!_conectorZeroEnviado) {
      await _repository.enviarStatusNotification(
        conectorId: 0,
        status: StatusConectorOcpp.available,
      );
      _conectorZeroEnviado = true;
    }

    final estadoConector = _obterEstadoConector(idConector);
    await _repository.enviarStatusNotification(
      conectorId: idConector,
      status: estadoConector.statusConector,
      data: _agora(),
    );
    _registrarEvento('Status enviado: ${estadoConector.statusConector.valor}');
  }

  Future<void> _enviarValoresMedidorInterno({int? idConector}) async {
    if (!conectado.value) {
      return;
    }

    final id = idConector ?? conectorId.value;
    final estadoConector = _obterEstadoConector(id);
    if (estadoConector.enviandoValores) {
      return;
    }

    estadoConector.enviandoValores = true;
    try {
      await _repository.enviarValoresMedidor(
        conectorId: id,
        transacaoId: estadoConector.transacaoId,
        valores: <ValorMedidoOcpp>[
          ValorMedidoOcpp(
            valor: estadoConector.medidorWh.toString(),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.energyActiveImportRegister,
            unidade: UnidadeMedicaoOcpp.wattHora,
          ),
          ValorMedidoOcpp(
            valor: estadoConector.potenciaW.round().toString(),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.powerActiveImport,
            unidade: UnidadeMedicaoOcpp.watt,
          ),
          ValorMedidoOcpp(
            valor: estadoConector.soc.toStringAsFixed(1),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.soc,
            unidade: UnidadeMedicaoOcpp.percentual,
          ),
          ValorMedidoOcpp(
            valor: estadoConector.temperaturaC.toStringAsFixed(1),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.temperature,
            unidade: UnidadeMedicaoOcpp.celcius,
          ),
        ],
      );
      _registrarEvento('MeterValues enviado: ${estadoConector.medidorWh} Wh');
    } finally {
      estadoConector.enviandoValores = false;
    }
  }

  void _aplicarRespostaBootNotification(Map<String, dynamic> resposta) {
    final status = resposta['status'];
    if (status != null && status != 'Accepted') {
      _registrarEvento('BootNotification retornou: $status');
    } else {
      _registrarEvento('BootNotification aceito');
    }

    final intervalo = _lerInteiroOpcional(resposta['interval']);
    if (intervalo == null || intervalo <= 0) {
      _iniciarHeartbeat(intervaloHeartbeat.value);
      return;
    }

    intervaloHeartbeat.value = Duration(seconds: intervalo);
    _iniciarHeartbeat(intervaloHeartbeat.value);
  }

  void _aplicarChangeConfiguration(Map<String, dynamic> payload) {
    if (payload['key'] != 'HeartbeatInterval') {
      return;
    }

    final valor = _lerInteiroOpcional(payload['value']);
    if (valor == null || valor <= 0) {
      return;
    }

    intervaloHeartbeat.value = Duration(seconds: valor);
    _iniciarHeartbeat(intervaloHeartbeat.value);
  }

  void _iniciarHeartbeat(Duration intervalo) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      intervalo,
      (_) => unawaited(_repository.enviarHeartbeat()),
    );
  }

  void _iniciarEnvioPeriodicoValores({int? idConector}) {
    final id = idConector ?? conectorId.value;
    final estadoConector = _obterEstadoConector(id);
    estadoConector.medidorTimer?.cancel();
    estadoConector.medidorTimer = Timer.periodic(const Duration(seconds: 10), (
      _,
    ) async {
      _incrementarMedidorPorTempoDoConector(id);
      await _enviarValoresMedidorInterno(idConector: id);
    });
  }

  void _pararEnvioPeriodicoValoresDoConector(int idConector) {
    final estadoConector = _obterEstadoConector(idConector);
    estadoConector.medidorTimer?.cancel();
    estadoConector.medidorTimer = null;
  }

  void _incrementarMedidorPorTempoDoConector(int idConector) {
    final agora = _agora();
    final estadoConector = _obterEstadoConector(idConector);
    final ultimaAtualizacao = estadoConector.ultimaAtualizacaoMedidor ?? agora;
    estadoConector.ultimaAtualizacaoMedidor = agora;

    final horas =
        agora.difference(ultimaAtualizacao).inMilliseconds /
        Duration.millisecondsPerHour;
    if (horas <= 0 || estadoConector.potenciaW <= 0) {
      return;
    }

    final incrementoWh = max(1, (estadoConector.potenciaW * horas).round());
    _atualizarMedidorDoConector(
      idConector,
      estadoConector.medidorWh + incrementoWh,
    );

    final capacidadeWh = estadoConector.capacidadeBateriaKwh * 1000;
    if (capacidadeWh > 0) {
      final incrementoSoc = (incrementoWh / capacidadeWh) * 100;
      _atualizarSocDoConector(
        idConector,
        min(100, estadoConector.soc + incrementoSoc).toDouble(),
      );
    }

    _atualizarTemperaturaSimulada(
      idConector: idConector,
      horas: horas,
      incrementoWh: incrementoWh,
    );
  }

  void _atualizarTemperaturaSimulada({
    required int idConector,
    required double horas,
    required int incrementoWh,
  }) {
    if (horas <= 0 || incrementoWh <= 0) {
      return;
    }

    final estadoConector = _obterEstadoConector(idConector);
    final potenciaKw = estadoConector.potenciaW / 1000;
    final socNormalizado = (estadoConector.soc / 100).clamp(0.0, 1.0);
    final ciclosDezSegundos = max(1.0, horas * 360);
    final alvoTermico =
        _temperaturaAmbienteSimuladaC +
        min(12.0, potenciaKw * 0.85) +
        (socNormalizado * 3.5);
    final oscilacaoOperacional = sin(
      (estadoConector.medidorWh + incrementoWh) / 260,
    );
    final alvoComOscilacao = alvoTermico + (oscilacaoOperacional * 0.35);
    final fatorAproximacao = (0.08 * ciclosDezSegundos).clamp(0.0, 0.28);
    final novaTemperatura =
        estadoConector.temperaturaC +
        ((alvoComOscilacao - estadoConector.temperaturaC) * fatorAproximacao);

    _atualizarTemperaturaDoConector(
      idConector,
      novaTemperatura
          .clamp(_temperaturaMinimaSimuladaC, _temperaturaMaximaSimuladaC)
          .toDouble(),
    );
  }

  Future<void> _executar(Future<void> Function() acao) async {
    if (_descartado || ocupado.value) {
      return;
    }

    ocupado.value = true;
    erro.value = null;
    try {
      await acao();
    } catch (error) {
      _registrarErro(error);
      _atualizarEstadoAtivo(
        conectado.value
            ? EstadoCarregador.falha
            : EstadoCarregador.desconectado,
      );
    } finally {
      ocupado.value = false;
    }
  }

  Future<void> _executarSemOcupacao(Future<void> Function() acao) async {
    if (_descartado) {
      return;
    }

    try {
      await acao();
    } catch (error) {
      _registrarErro(error);
    }
  }

  Uri _lerServidor(String valor) {
    final texto = valor.trim();
    final uri = Uri.tryParse(texto);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(valor, 'servidor', 'Informe uma URL WebSocket');
    }

    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw ArgumentError.value(valor, 'servidor', 'Use ws:// ou wss://');
    }

    return uri;
  }

  void _pararTimers() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    for (final MapEntry<int, _EstadoOperacionalConector> entry
        in _estadosPorConector.entries) {
      final idConector = entry.key;
      final estadoConector = entry.value;
      estadoConector.medidorTimer?.cancel();
      estadoConector.medidorTimer = null;
      estadoConector.tempoCarregamentoTimer?.cancel();
      estadoConector.tempoCarregamentoTimer = null;
      _atualizarTempoCarregamentoDoConectorAtual(idConector);
      estadoConector.ultimaAtualizacaoMedidor = null;
      estadoConector.inicioPeriodoCarregamento = null;
    }
  }

  void _reiniciarTempoCarregamento() {
    _reiniciarTempoCarregamentoDoConector(conectorId.value);
  }

  void _reiniciarTempoCarregamentoDoConector(int idConector) {
    final estadoConector = _obterEstadoConector(idConector)
      ..tempoCarregamentoAcumulado = Duration.zero
      ..inicioPeriodoCarregamento = null;
    estadoConector.tempoCarregamento = Duration.zero;
    _atualizarTempoCarregamentoDoConector(idConector, Duration.zero);
    _pararTimerTempoCarregamentoDoConector(idConector);
  }

  void _iniciarTempoCarregamentoDoConector(int idConector) {
    final estadoConector = _obterEstadoConector(idConector);
    _pararTimerTempoCarregamentoDoConector(idConector);
    estadoConector.inicioPeriodoCarregamento = _agora();
    _atualizarTempoCarregamentoDoConectorAtual(idConector);
    estadoConector.tempoCarregamentoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _atualizarTempoCarregamentoDoConectorAtual(idConector),
    );
  }

  void _acumularTempoCarregamentoDoConector(int idConector) {
    final estadoConector = _obterEstadoConector(idConector);
    final inicio = estadoConector.inicioPeriodoCarregamento;
    if (inicio == null) {
      return;
    }

    final decorrido = _agora().difference(inicio);
    if (!decorrido.isNegative) {
      estadoConector.tempoCarregamentoAcumulado += decorrido;
    }

    estadoConector.inicioPeriodoCarregamento = null;
    _atualizarTempoCarregamentoDoConector(
      idConector,
      estadoConector.tempoCarregamentoAcumulado,
    );
  }

  void _atualizarTempoCarregamentoDoConectorAtual(int idConector) {
    final estadoConector = _obterEstadoConector(idConector);
    final inicio = estadoConector.inicioPeriodoCarregamento;
    if (inicio == null) {
      _atualizarTempoCarregamentoDoConector(
        idConector,
        estadoConector.tempoCarregamentoAcumulado,
      );
      return;
    }

    final decorrido = _agora().difference(inicio);
    if (decorrido.isNegative) {
      _atualizarTempoCarregamentoDoConector(
        idConector,
        estadoConector.tempoCarregamentoAcumulado,
      );
      return;
    }

    _atualizarTempoCarregamentoDoConector(
      idConector,
      estadoConector.tempoCarregamentoAcumulado + decorrido,
    );
  }

  void _pararTimerTempoCarregamentoDoConector(int idConector) {
    final estadoConector = _obterEstadoConector(idConector);
    estadoConector.tempoCarregamentoTimer?.cancel();
    estadoConector.tempoCarregamentoTimer = null;
  }

  void _registrarErro(Object error) {
    final mensagem = error.toString();
    erro.value = mensagem;
    _registrarEvento('Erro: $mensagem');
  }

  void _registrarEvento(String evento) {
    final agora = _agora();
    final horario =
        '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}:'
        '${agora.second.toString().padLeft(2, '0')}';
    final proximaLista = <String>['$horario - $evento', ...eventos.value];
    eventos.value = proximaLista.take(80).toList(growable: false);
  }

  String _descreverMensagemRecebida(MensagemOcpp mensagem) {
    return switch (mensagem) {
      ChamadaOcpp(:final acao) => 'Recebido comando $acao',
      RespostaOcpp(:final acao) => 'Recebida resposta ${acao ?? mensagem.id}',
      ErroOcpp(:final codigo) => 'Recebido erro OCPP $codigo',
    };
  }

  EstadoCarregador _estadoPorStatus(StatusConectorOcpp status) {
    return switch (status) {
      StatusConectorOcpp.available => EstadoCarregador.disponivel,
      StatusConectorOcpp.preparing => EstadoCarregador.preparando,
      StatusConectorOcpp.charging => EstadoCarregador.carregando,
      StatusConectorOcpp.suspendedEvse ||
      StatusConectorOcpp.suspendedEv => EstadoCarregador.pausado,
      StatusConectorOcpp.finishing => EstadoCarregador.finalizando,
      StatusConectorOcpp.reserved => EstadoCarregador.disponivel,
      StatusConectorOcpp.unavailable => EstadoCarregador.desconectado,
      StatusConectorOcpp.faulted => EstadoCarregador.falha,
    };
  }

  int? _lerInteiroOpcional(Object? valor) {
    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    if (valor is String) {
      return int.tryParse(valor);
    }

    return null;
  }

  double? _lerDecimal(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }
}

final class DadosOperacionaisConectorCarregador {
  const DadosOperacionaisConectorCarregador({
    required this.medidorWh,
    required this.medidorInicioTransacaoWh,
    required this.potenciaW,
    required this.soc,
    required this.temperaturaC,
    required this.capacidadeBateriaKwh,
    required this.tempoCarregamento,
    required this.transacaoId,
    required this.statusConector,
    required this.estado,
  });

  final int medidorWh;
  final int medidorInicioTransacaoWh;
  final double potenciaW;
  final double soc;
  final double temperaturaC;
  final double capacidadeBateriaKwh;
  final Duration tempoCarregamento;
  final int? transacaoId;
  final StatusConectorOcpp statusConector;
  final EstadoCarregador estado;

  double get energiaFornecidaKwh {
    final energiaWh = max(0, medidorWh - medidorInicioTransacaoWh);
    return energiaWh / 1000;
  }

  Duration? get tempoRestante {
    final potenciaKw = potenciaW / 1000;

    if (potenciaKw <= 0 || capacidadeBateriaKwh <= 0 || soc >= 100) {
      return null;
    }

    final energiaRestanteKwh = capacidadeBateriaKwh * ((100 - soc) / 100);
    return Duration(minutes: ((energiaRestanteKwh / potenciaKw) * 60).ceil());
  }
}

Map<int, StatusConectorOcpp> _criarStatusConectoresIniciais(
  Iterable<int>? idsConectoresConfigurados,
  int conectorIdInicial,
) {
  return Map<int, StatusConectorOcpp>.unmodifiable(<int, StatusConectorOcpp>{
    for (final id in _normalizarIdsConectores(
      idsConectoresConfigurados,
      conectorIdInicial,
    ))
      id: StatusConectorOcpp.available,
  });
}

List<int> _normalizarIdsConectores(
  Iterable<int>? idsConectoresConfigurados,
  int conectorIdInicial,
) {
  final ids = <int>{};
  if (conectorIdInicial >= 1) {
    ids.add(conectorIdInicial);
  }

  for (final id in idsConectoresConfigurados ?? const <int>[]) {
    if (id >= 1) {
      ids.add(id);
    }
  }

  if (ids.isEmpty) {
    ids.add(1);
  }

  return ids.toList(growable: false);
}

final class _EstadoOperacionalConector {
  _EstadoOperacionalConector({
    required this.medidorWh,
    required this.medidorInicioTransacaoWh,
    required this.potenciaW,
    required this.soc,
    required this.temperaturaC,
    required this.capacidadeBateriaKwh,
    required this.tempoCarregamento,
    required this.transacaoId,
    required this.statusConector,
    required this.estado,
  });

  int medidorWh;
  int medidorInicioTransacaoWh;
  double potenciaW;
  double soc;
  double temperaturaC;
  double capacidadeBateriaKwh;
  Duration tempoCarregamento;
  int? transacaoId;
  StatusConectorOcpp statusConector;
  EstadoCarregador estado;
  Timer? medidorTimer;
  Timer? tempoCarregamentoTimer;
  Duration tempoCarregamentoAcumulado = Duration.zero;
  DateTime? ultimaAtualizacaoMedidor;
  DateTime? inicioPeriodoCarregamento;
  bool enviandoValores = false;
}
