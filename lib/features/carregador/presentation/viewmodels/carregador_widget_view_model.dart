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

class CarregadorWidgetViewModel {
  CarregadorWidgetViewModel({
    CarregadorRepository? repository,
    Uri? servidorInicial,
    String idTagInicial = 'TAG-001',
    int conectorIdInicial = 1,
    int medidorInicialWh = 0,
    double potenciaInicialW = 7400,
    double socInicial = 30,
    double temperaturaInicialC = 34,
    double capacidadeBateriaInicialKwh = 60,
  }) : _repository = repository ?? CarregadorRepositoryWebSocket(),
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
       tempoCarregamento = Rx<Duration>(Duration.zero) {
    _assinarMensagens();
  }

  final CarregadorRepository _repository;

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
  Timer? _medidorTimer;
  Timer? _tempoCarregamentoTimer;
  DateTime? _ultimaAtualizacaoMedidor;
  DateTime? _inicioPeriodoCarregamento;
  Duration _tempoCarregamentoAcumulado = Duration.zero;
  var _conectorZeroEnviado = false;
  var _descartado = false;
  var _enviandoValores = false;

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

  Future<void> conectar({String? servidorTexto}) {
    return _executar(() => _conectarInterno(servidorTexto: servidorTexto));
  }

  Future<void> desconectar() {
    return _executar(() async {
      _pararTimers();
      _reiniciarTempoCarregamento();
      await _repository.desconectar();
      conectado.value = false;
      transacaoId.value = null;
      estado.value = EstadoCarregador.desconectado;
      statusConector.value = StatusConectorOcpp.unavailable;
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

      estado.value = EstadoCarregador.preparando;
      statusConector.value = StatusConectorOcpp.preparing;
      await enviarStatusAtual();

      if (autorizarAntes) {
        await _autorizarIdTag();
      }

      final resposta = await _repository.iniciarTransacao(
        conectorId: conectorId.value,
        idTag: idTag.value,
        medidorInicialWh: medidorWh.value,
      );

      transacaoId.value = _lerInteiroOpcional(resposta['transactionId']);
      medidorInicioTransacaoWh.value = medidorWh.value;
      _reiniciarTempoCarregamento();
      estado.value = EstadoCarregador.carregando;
      statusConector.value = StatusConectorOcpp.charging;
      _ultimaAtualizacaoMedidor = DateTime.now();
      _iniciarTempoCarregamento();
      _iniciarEnvioPeriodicoValores();

      _registrarEvento(
        'Transacao iniciada'
        '${transacaoId.value == null ? '' : ' #${transacaoId.value}'}',
      );

      await enviarStatusAtual();
      await enviarValoresMedidor();
    });
  }

  Future<void> pausarCarregamento() {
    return _executar(() async {
      if (!conectado.value || estado.value != EstadoCarregador.carregando) {
        return;
      }

      _medidorTimer?.cancel();
      _medidorTimer = null;
      _acumularTempoCarregamento();
      _pararTimerTempoCarregamento();
      estado.value = EstadoCarregador.pausado;
      statusConector.value = StatusConectorOcpp.suspendedEv;
      _registrarEvento('Carregamento pausado');
      await enviarStatusAtual();
    });
  }

  Future<void> retomarCarregamento() {
    return _executar(() async {
      if (!conectado.value || estado.value != EstadoCarregador.pausado) {
        return;
      }

      estado.value = EstadoCarregador.carregando;
      statusConector.value = StatusConectorOcpp.charging;
      _ultimaAtualizacaoMedidor = DateTime.now();
      _iniciarTempoCarregamento();
      _iniciarEnvioPeriodicoValores();
      _registrarEvento('Carregamento retomado');
      await enviarStatusAtual();
    });
  }

  Future<void> pararCarregamento({
    MotivoFimTransacaoOcpp motivo = MotivoFimTransacaoOcpp.local,
  }) {
    return _executar(() async {
      if (!conectado.value) {
        return;
      }

      _medidorTimer?.cancel();
      _medidorTimer = null;
      _incrementarMedidorPorTempo();
      _atualizarTempoCarregamento();
      _pararTimerTempoCarregamento();
      estado.value = EstadoCarregador.finalizando;
      statusConector.value = StatusConectorOcpp.finishing;
      await enviarStatusAtual();

      final id = transacaoId.value;
      if (id != null) {
        await enviarValoresMedidor();
        await _repository.finalizarTransacao(
          transacaoId: id,
          medidorFinalWh: medidorWh.value,
          idTag: idTag.value,
          motivo: motivo,
        );
      }

      transacaoId.value = null;
      medidorInicioTransacaoWh.value = medidorWh.value;
      estado.value = EstadoCarregador.disponivel;
      statusConector.value = StatusConectorOcpp.available;
      _registrarEvento('Transacao finalizada');
      await enviarStatusAtual();
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

      await _repository.enviarStatusNotification(
        conectorId: conectorId.value,
        status: statusConector.value,
        data: DateTime.now(),
      );
      _registrarEvento('Status enviado: ${statusConector.value.valor}');
    });
  }

  Future<void> enviarValoresMedidor({bool incrementarAntes = false}) {
    return _executarSemOcupacao(() async {
      if (incrementarAntes) {
        _incrementarMedidorPorTempo();
      }

      await _enviarValoresMedidorInterno();
    });
  }

  Future<void> alterarStatus(StatusConectorOcpp status) {
    return _executar(() async {
      statusConector.value = status;
      estado.value = _estadoPorStatus(status);
      await enviarStatusAtual();
    });
  }

  void atualizarIdTag(String valor) {
    idTag.value = valor.trim();
  }

  void atualizarConectorId(String valor) {
    final parsed = int.tryParse(valor.trim());
    if (parsed == null || parsed < 0) {
      return;
    }

    conectorId.value = parsed;
  }

  void atualizarPotencia(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null || parsed < 0) {
      return;
    }

    potenciaW.value = parsed;
  }

  void atualizarMedidor(String valor) {
    final parsed = int.tryParse(valor.trim());
    if (parsed == null || parsed < 0) {
      return;
    }

    medidorWh.value = parsed;
  }

  void atualizarSoc(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null) {
      return;
    }

    soc.value = parsed.clamp(0, 100);
  }

  void atualizarTemperatura(String valor) {
    final parsed = _lerDecimal(valor);
    if (parsed == null) {
      return;
    }

    temperaturaC.value = parsed;
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
    estado.value = EstadoCarregador.conectando;
    _conectorZeroEnviado = false;

    await _repository.conectar(servidor.value);
    conectado.value = true;
    estado.value = EstadoCarregador.disponivel;
    statusConector.value = StatusConectorOcpp.available;
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
          if (id != null) {
            transacaoId.value = id;
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
            conectorId.value = connector;
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

  Future<void> _enviarValoresMedidorInterno() async {
    if (!conectado.value || _enviandoValores) {
      return;
    }

    _enviandoValores = true;
    try {
      await _repository.enviarValoresMedidor(
        conectorId: conectorId.value,
        transacaoId: transacaoId.value,
        valores: <ValorMedidoOcpp>[
          ValorMedidoOcpp(
            valor: medidorWh.value.toString(),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.energyActiveImportRegister,
            unidade: UnidadeMedicaoOcpp.wattHora,
          ),
          ValorMedidoOcpp(
            valor: potenciaW.value.round().toString(),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.powerActiveImport,
            unidade: UnidadeMedicaoOcpp.watt,
          ),
          ValorMedidoOcpp(
            valor: soc.value.toStringAsFixed(1),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.soc,
            unidade: UnidadeMedicaoOcpp.percentual,
          ),
          ValorMedidoOcpp(
            valor: temperaturaC.value.toStringAsFixed(1),
            contexto: ContextoMedicaoOcpp.samplePeriodic,
            mensurando: MensurandoOcpp.temperature,
            unidade: UnidadeMedicaoOcpp.celcius,
          ),
        ],
      );
      _registrarEvento('MeterValues enviado: ${medidorWh.value} Wh');
    } finally {
      _enviandoValores = false;
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

  void _iniciarEnvioPeriodicoValores() {
    _medidorTimer?.cancel();
    _medidorTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      _incrementarMedidorPorTempo();
      await _enviarValoresMedidorInterno();
    });
  }

  void _incrementarMedidorPorTempo() {
    final agora = DateTime.now();
    final ultimaAtualizacao = _ultimaAtualizacaoMedidor ?? agora;
    _ultimaAtualizacaoMedidor = agora;

    final horas =
        agora.difference(ultimaAtualizacao).inMilliseconds /
        Duration.millisecondsPerHour;
    if (horas <= 0 || potenciaW.value <= 0) {
      return;
    }

    final incrementoWh = max(1, (potenciaW.value * horas).round());
    medidorWh.value = medidorWh.value + incrementoWh;

    final capacidadeWh = capacidadeBateriaKwh.value * 1000;
    if (capacidadeWh > 0) {
      final incrementoSoc = (incrementoWh / capacidadeWh) * 100;
      soc.value = min(100, soc.value + incrementoSoc);
    }
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
      estado.value = conectado.value
          ? EstadoCarregador.falha
          : EstadoCarregador.desconectado;
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
    _medidorTimer?.cancel();
    _medidorTimer = null;
    _pararTimerTempoCarregamento();
    _ultimaAtualizacaoMedidor = null;
    _inicioPeriodoCarregamento = null;
  }

  void _reiniciarTempoCarregamento() {
    _tempoCarregamentoAcumulado = Duration.zero;
    _inicioPeriodoCarregamento = null;
    tempoCarregamento.value = Duration.zero;
    _pararTimerTempoCarregamento();
  }

  void _iniciarTempoCarregamento() {
    _pararTimerTempoCarregamento();
    _inicioPeriodoCarregamento = DateTime.now();
    _atualizarTempoCarregamento();
    _tempoCarregamentoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _atualizarTempoCarregamento(),
    );
  }

  void _acumularTempoCarregamento() {
    final inicio = _inicioPeriodoCarregamento;
    if (inicio == null) {
      return;
    }

    final decorrido = DateTime.now().difference(inicio);
    if (!decorrido.isNegative) {
      _tempoCarregamentoAcumulado += decorrido;
    }

    _inicioPeriodoCarregamento = null;
    tempoCarregamento.value = _tempoCarregamentoAcumulado;
  }

  void _atualizarTempoCarregamento() {
    final inicio = _inicioPeriodoCarregamento;
    if (inicio == null) {
      tempoCarregamento.value = _tempoCarregamentoAcumulado;
      return;
    }

    final decorrido = DateTime.now().difference(inicio);
    if (decorrido.isNegative) {
      tempoCarregamento.value = _tempoCarregamentoAcumulado;
      return;
    }

    tempoCarregamento.value = _tempoCarregamentoAcumulado + decorrido;
  }

  void _pararTimerTempoCarregamento() {
    _tempoCarregamentoTimer?.cancel();
    _tempoCarregamentoTimer = null;
  }

  void _registrarErro(Object error) {
    final mensagem = error.toString();
    erro.value = mensagem;
    _registrarEvento('Erro: $mensagem');
  }

  void _registrarEvento(String evento) {
    final agora = DateTime.now();
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
