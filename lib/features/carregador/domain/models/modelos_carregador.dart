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

Map<String, dynamic> removerNulos(Map<String, dynamic> payload) {
  return <String, dynamic>{
    for (final entrada in payload.entries)
      if (entrada.value != null) entrada.key: entrada.value,
  };
}
