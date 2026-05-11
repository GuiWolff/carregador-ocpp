# Resumo do slice 1/5

## O que foi feito
- Criada a estrutura privada `_EstadoOperacionalConector` no `CarregadorWidgetViewModel`.
- O estado operacional passou a ser mantido por ID de conector, incluindo:
  - medidor atual;
  - medidor inicial da transação;
  - potência;
  - SoC;
  - temperatura;
  - capacidade da bateria;
  - tempo de carregamento;
  - transação;
  - status do conector;
  - estado operacional.
- Mantidos os `Rx` públicos existentes como espelho do conector ativo.
- Adicionado o parâmetro opcional `idsConectoresConfigurados` ao construtor do `CarregadorWidgetViewModel`, sem quebrar chamadas existentes.
- Ajustado `selecionarConector(...)` para persistir o estado do conector atual e sincronizar os `Rx` públicos com o conector selecionado.
- Ajustados `atualizarPotencia`, `atualizarMedidor`, `atualizarSoc` e `atualizarTemperatura` para persistirem os valores no estado do conector ativo.
- Mantido `statusConectores` atualizado para os chips da página.
- Ajustado `_criarCarregadorViewModelPadrao(...)` para enviar os IDs reais dos conectores configurados ao `CarregadorWidgetViewModel`.
- Ajustado o helper de teste da página para criar o ViewModel operacional com os conectores da configuração.
- Adicionado teste unitário garantindo que valores editados no conector 1 não sobrescrevem valores editados no conector 2 ao alternar o conector ativo.

## Arquivos alterados
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Validações executadas
- `flutter analyze`
  - Resultado: passou sem issues.
- `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
  - Resultado: passou.
- `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`
  - Resultado: passou.

## Observações
- O fluxo OCPP de iniciar, pausar, retomar, parar e enviar medidor não foi redesenhado neste slice.
- A execução foi feita somente para o slice 1, sem execução paralela de outros slices.

## Continuidade
- Próximo slice sugerido: `docs/codex/carregador/carregador-26-05-11-7-parte_2.md`.
