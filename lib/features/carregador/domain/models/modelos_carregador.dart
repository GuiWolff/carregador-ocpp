enum TipoConectorCarregador {
  ccs2('CCS2'),
  mennekesType2('MENNEKES_TYPE_2'),
  gbt('GBT');

  const TipoConectorCarregador(this.valor);

  final String valor;

  static TipoConectorCarregador fromJson(Object? json) {
    final valor = _textoJsonNaoVazio(json, 'tipo');

    for (final tipo in TipoConectorCarregador.values) {
      if (tipo.valor == valor) {
        return tipo;
      }
    }

    throw FormatException('Tipo de conector desconhecido: $valor');
  }
}

final class ConectorCarregadorConfigurado {
  ConectorCarregadorConfigurado({required this.id, required this.tipo}) {
    if (id < 1) {
      throw ArgumentError.value(id, 'id', 'Informe um id de conector valido');
    }
  }

  factory ConectorCarregadorConfigurado.fromJson(Object? json) {
    final mapa = _mapaJson(json, 'ConectorCarregadorConfigurado');

    return ConectorCarregadorConfigurado(
      id: _inteiroJsonObrigatorio(mapa, 'id'),
      tipo: TipoConectorCarregador.fromJson(mapa['tipo']),
    );
  }

  final int id;
  final TipoConectorCarregador tipo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'tipo': tipo.valor};
  }
}

final class CarregadorConfigurado {
  CarregadorConfigurado({
    required this.id,
    required List<ConectorCarregadorConfigurado> conectores,
  }) : conectores = List<ConectorCarregadorConfigurado>.unmodifiable(
         conectores,
       ) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Informe o id do carregador');
    }

    if (conectores.isEmpty || conectores.length > 2) {
      throw ArgumentError.value(
        conectores.length,
        'conectores',
        'Configure 1 ou 2 conectores',
      );
    }
  }

  factory CarregadorConfigurado.fromJson(Object? json) {
    final mapa = _mapaJson(json, 'CarregadorConfigurado');
    final conectoresJson = mapa['conectores'];

    if (conectoresJson is! List) {
      throw const FormatException('Campo conectores deve ser uma lista');
    }

    return CarregadorConfigurado(
      id: _textoJsonObrigatorio(mapa, 'id'),
      conectores: conectoresJson
          .map(ConectorCarregadorConfigurado.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final List<ConectorCarregadorConfigurado> conectores;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'conectores': conectores
          .map((conector) => conector.toJson())
          .toList(growable: false),
    };
  }
}

enum StatusConectorOcpp {
  available('Available'),
  preparing('Preparing'),
  charging('Charging'),
  suspendedEvse('SuspendedEVSE'),
  suspendedEv('SuspendedEV'),
  finishing('Finishing'),
  reserved('Reserved'),
  unavailable('Unavailable'),
  faulted('Faulted');

  const StatusConectorOcpp(this.valor);

  final String valor;
}

enum CodigoErroOcpp {
  connectorLockFailure('ConnectorLockFailure'),
  evCommunicationError('EVCommunicationError'),
  groundFailure('GroundFailure'),
  highTemperature('HighTemperature'),
  internalError('InternalError'),
  localListConflict('LocalListConflict'),
  noError('NoError'),
  otherError('OtherError'),
  overCurrentFailure('OverCurrentFailure'),
  powerMeterFailure('PowerMeterFailure'),
  powerSwitchFailure('PowerSwitchFailure'),
  readerFailure('ReaderFailure'),
  resetFailure('ResetFailure'),
  underVoltage('UnderVoltage'),
  overVoltage('OverVoltage'),
  weakSignal('WeakSignal');

  const CodigoErroOcpp(this.valor);

  final String valor;
}

enum MotivoFimTransacaoOcpp {
  emergencyStop('EmergencyStop'),
  evDisconnected('EVDisconnected'),
  hardReset('HardReset'),
  local('Local'),
  other('Other'),
  powerLoss('PowerLoss'),
  reboot('Reboot'),
  remote('Remote'),
  softReset('SoftReset'),
  unlockCommand('UnlockCommand'),
  deAuthorized('DeAuthorized');

  const MotivoFimTransacaoOcpp(this.valor);

  final String valor;
}

enum ContextoMedicaoOcpp {
  interruptionBegin('Interruption.Begin'),
  interruptionEnd('Interruption.End'),
  sampleClock('Sample.Clock'),
  samplePeriodic('Sample.Periodic'),
  transactionBegin('Transaction.Begin'),
  transactionEnd('Transaction.End'),
  trigger('Trigger'),
  other('Other');

  const ContextoMedicaoOcpp(this.valor);

  final String valor;
}

enum FormatoMedicaoOcpp {
  raw('Raw'),
  signedData('SignedData');

  const FormatoMedicaoOcpp(this.valor);

  final String valor;
}

enum MensurandoOcpp {
  energyActiveExportRegister('Energy.Active.Export.Register'),
  energyActiveImportRegister('Energy.Active.Import.Register'),
  energyReactiveExportRegister('Energy.Reactive.Export.Register'),
  energyReactiveImportRegister('Energy.Reactive.Import.Register'),
  energyActiveExportInterval('Energy.Active.Export.Interval'),
  energyActiveImportInterval('Energy.Active.Import.Interval'),
  energyReactiveExportInterval('Energy.Reactive.Export.Interval'),
  energyReactiveImportInterval('Energy.Reactive.Import.Interval'),
  powerActiveExport('Power.Active.Export'),
  powerActiveImport('Power.Active.Import'),
  powerOffered('Power.Offered'),
  powerReactiveExport('Power.Reactive.Export'),
  powerReactiveImport('Power.Reactive.Import'),
  powerFactor('Power.Factor'),
  currentImport('Current.Import'),
  currentExport('Current.Export'),
  currentOffered('Current.Offered'),
  voltage('Voltage'),
  frequency('Frequency'),
  temperature('Temperature'),
  soc('SoC'),
  rpm('RPM');

  const MensurandoOcpp(this.valor);

  final String valor;
}

enum FaseMedicaoOcpp {
  l1('L1'),
  l2('L2'),
  l3('L3'),
  neutro('N'),
  l1N('L1-N'),
  l2N('L2-N'),
  l3N('L3-N'),
  l1L2('L1-L2'),
  l2L3('L2-L3'),
  l3L1('L3-L1');

  const FaseMedicaoOcpp(this.valor);

  final String valor;
}

enum LocalMedicaoOcpp {
  cable('Cable'),
  ev('EV'),
  inlet('Inlet'),
  outlet('Outlet'),
  body('Body');

  const LocalMedicaoOcpp(this.valor);

  final String valor;
}

enum UnidadeMedicaoOcpp {
  wattHora('Wh'),
  quilowattHora('kWh'),
  varHora('varh'),
  quilovarHora('kvarh'),
  watt('W'),
  quilowatt('kW'),
  voltAmpere('VA'),
  quilovoltAmpere('kVA'),
  voltAmpereReativo('var'),
  quilovoltAmpereReativo('kvar'),
  ampere('A'),
  volt('V'),
  kelvin('K'),
  celcius('Celcius'),
  fahrenheit('Fahrenheit'),
  percentual('Percent');

  const UnidadeMedicaoOcpp(this.valor);

  final String valor;
}

final class ValorMedidoOcpp {
  const ValorMedidoOcpp({
    required this.valor,
    this.contexto,
    this.formato,
    this.mensurando,
    this.fase,
    this.local,
    this.unidade,
  });

  final String valor;
  final ContextoMedicaoOcpp? contexto;
  final FormatoMedicaoOcpp? formato;
  final MensurandoOcpp? mensurando;
  final FaseMedicaoOcpp? fase;
  final LocalMedicaoOcpp? local;
  final UnidadeMedicaoOcpp? unidade;

  Map<String, dynamic> toJson() {
    return removerNulos(<String, dynamic>{
      'value': valor,
      'context': contexto?.valor,
      'format': formato?.valor,
      'measurand': mensurando?.valor,
      'phase': fase?.valor,
      'location': local?.valor,
      'unit': unidade?.valor,
    });
  }
}

Map<String, dynamic> _mapaJson(Object? json, String modelo) {
  if (json is! Map) {
    throw FormatException('$modelo deve ser um objeto JSON');
  }

  return <String, dynamic>{
    for (final entrada in json.entries)
      _chaveJson(entrada.key, modelo): entrada.value,
  };
}

String _chaveJson(Object? chave, String modelo) {
  if (chave is String) {
    return chave;
  }

  throw FormatException('$modelo deve conter apenas chaves texto');
}

String _textoJsonObrigatorio(Map<String, dynamic> json, String campo) {
  return _textoJsonNaoVazio(json[campo], campo);
}

String _textoJsonNaoVazio(Object? valor, String campo) {
  if (valor is String && valor.trim().isNotEmpty) {
    return valor;
  }

  throw FormatException('Campo $campo deve ser texto nao vazio');
}

int _inteiroJsonObrigatorio(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is int) {
    return valor;
  }

  throw FormatException('Campo $campo deve ser inteiro');
}

Map<String, dynamic> removerNulos(Map<String, dynamic> payload) {
  return <String, dynamic>{
    for (final entrada in payload.entries)
      if (entrada.value != null) entrada.key: entrada.value,
  };
}
