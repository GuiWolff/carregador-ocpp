# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Esta tarefa foi dividida em 5 slices para tornar o carregamento por conector independente.

## Objetivo geral
Entregar o fluxo completo de recarga independente por conector no simulador OCPP, garantindo que cada conector mantenha separadamente:

- status;
- estado operacional;
- transação;
- medidor atual;
- medidor inicial da transação;
- potência;
- SoC;
- temperatura;
- capacidade da bateria;
- tempo de carregamento;
- temporizadores de evolução automática.

O comportamento atual para carregadores com um único conector deve ser preservado.

## Arquivos principais envolvidos
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/widgets/carregador_widget.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Slices da tarefa

### Slice 1/5 - Preparar estado operacional por conector
Arquivo: `docs/codex/carregador/carregador-26-05-11-7-parte_1.md`
Resumo esperado: `docs/codex/carregador/carregador-26-05-11-7-parte_1-resumo.md`

Atividades:

1. Criar estrutura privada de estado operacional por conector no `CarregadorWidgetViewModel`.
2. Concentrar nessa estrutura os valores que eram únicos do carregador:
   - medidor atual;
   - medidor inicial da transação;
   - potência;
   - SoC;
   - temperatura;
   - capacidade da bateria;
   - tempo de carregamento;
   - transação;
   - status e estado operacional.
3. Adicionar forma opcional de receber IDs dos conectores configurados no construtor do `CarregadorWidgetViewModel`, sem quebrar chamadas existentes.
4. Ajustar `_criarCarregadorViewModelPadrao(...)` para passar os conectores reais da configuração.
5. Fazer `selecionarConector(...)` sincronizar os `Rx` públicos com o estado do conector selecionado.
6. Fazer `atualizarPotencia`, `atualizarMedidor`, `atualizarSoc` e `atualizarTemperatura` persistirem valores no estado do conector ativo.
7. Manter `statusConectores` compatível com os chips da página.
8. Adicionar teste unitário garantindo que valores editados no conector 1 não sobrescrevem valores editados no conector 2.
9. Rodar:
   - `flutter analyze`
   - `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
   - `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`
10. Salvar o resumo do slice.

Observação de continuidade:
- Este slice já pode estar executado. Se o resumo `carregador-26-05-11-7-parte_1-resumo.md` existir e estiver válido, avance para o slice 2 sem repetir o slice 1.

### Slice 2/5 - Migrar comandos OCPP para o conector ativo
Arquivo: `docs/codex/carregador/carregador-26-05-11-7-parte_2.md`
Resumo esperado: `docs/codex/carregador/carregador-26-05-11-7-parte_2-resumo.md`

Atividades:

1. Ajustar `iniciarCarregamento(...)` para ler e gravar transação, medidor inicial, status e estado no conector ativo.
2. Ajustar `pausarCarregamento()`, `retomarCarregamento()` e `pararCarregamento(...)` para alterarem somente o estado do conector ativo.
3. Ajustar `enviarStatusAtual()` para enviar o status do conector ativo sem depender de status global compartilhado.
4. Ajustar `enviarValoresMedidor(...)` e `_enviarValoresMedidorInterno()` para enviarem `MeterValues` com os valores do conector ativo.
5. Ajustar `RemoteStartTransaction` e `RemoteStopTransaction` para selecionarem e manipularem o conector correto quando o backend informar `connectorId` ou `transactionId`.
6. Garantir que `transacaoId`, `medidorInicioTransacaoWh`, `estado`, `statusConector` e demais `Rx` públicos continuem refletindo o conector ativo após cada transição.
7. Adicionar testes unitários para:
   - iniciar transação no conector 1 e no conector 2 com IDs de transação independentes;
   - enviar `MeterValues` com `connectorId` e valores do conector ativo;
   - parar um conector sem limpar a transação do outro.
8. Rodar:
   - `flutter analyze`
   - `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
9. Salvar o resumo do slice.

### Slice 3/5 - Separar temporizadores e evolução automática por conector
Arquivo: `docs/codex/carregador/carregador-26-05-11-7-parte_3.md`
Resumo esperado: `docs/codex/carregador/carregador-26-05-11-7-parte_3-resumo.md`

Atividades:

1. Mover `_medidorTimer`, `_tempoCarregamentoTimer`, `_ultimaAtualizacaoMedidor`, `_inicioPeriodoCarregamento` e `_tempoCarregamentoAcumulado` para o estado de cada conector ou para mapas privados por conector.
2. Ajustar início, pausa, retomada e parada do carregamento para controlar somente os temporizadores do conector correspondente.
3. Permitir dois conectores carregando ao mesmo tempo, cada um com evolução própria de medidor, SoC, temperatura e tempo.
4. Garantir que `enviarValoresMedidor(incrementarAntes: true)` incremente apenas o conector selecionado.
5. Sincronizar os `Rx` públicos quando o conector ativo receber atualização automática.
6. Cancelar todos os temporizadores de todos os conectores em `desconectar()`, `_pararTimers()` e `dispose()`.
7. Rever controle de envio simultâneo de `MeterValues` para não bloquear um conector por causa do envio de outro.
8. Adicionar testes unitários cobrindo:
   - evolução de medidor, SoC e temperatura isolada por conector;
   - pausa de um conector sem pausar o outro;
   - descarte do ViewModel cancelando todos os temporizadores.
9. Rodar:
   - `flutter analyze`
   - `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
10. Salvar o resumo do slice.

### Slice 4/5 - Integrar UI com estado independente por conector
Arquivo: `docs/codex/carregador/carregador-26-05-11-7-parte_4.md`
Resumo esperado: `docs/codex/carregador/carregador-26-05-11-7-parte_4-resumo.md`

Atividades:

1. Adicionar ao `CarregadorWidget` entrada opcional para receber os conectores configurados do carregador.
2. Passar `configuracao.conectores` ao abrir o painel em `CarregadoresPage`.
3. Exibir seleção de conector no painel quando houver conectores configurados, preferindo componente existente do projeto.
4. Manter o campo manual de conector apenas como compatibilidade quando o widget não receber a configuração de conectores.
5. Garantir que trocar o conector no painel atualize:
   - campos de potência, medidor, SoC e temperatura;
   - métricas;
   - status manual;
   - estado dos botões de ação.
6. Garantir que alterações feitas nos campos do painel sejam gravadas no conector ativo.
7. Ajustar chips de conectores da página para refletirem corretamente conector ativo e status independentes.
8. Adicionar testes de widget cobrindo carregador com dois conectores:
   - abrir painel;
   - selecionar conector 2;
   - validar que os campos exibem os dados do conector 2;
   - executar ação usando o conector 2.
9. Rodar:
   - `flutter analyze`
   - `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`
10. Salvar o resumo do slice.

### Slice 5/5 - Fechamento funcional e validação completa
Arquivo: `docs/codex/carregador/carregador-26-05-11-7-parte_5.md`
Resumo esperado: `docs/codex/carregador/carregador-26-05-11-7-parte_5-resumo.md`

Atividades:

1. Revisar o comportamento final para garantir que:
   - cada conector mantém status próprio;
   - cada conector mantém transação própria;
   - cada conector mantém medidor, potência, SoC, temperatura e tempo próprios;
   - alternar o conector ativo não sobrescreve dados do outro;
   - card/lista e painel continuam consistentes.
2. Ajustar eventuais regressões visuais pequenas causadas pela seleção de conector.
3. Adicionar ou ajustar testes de widget e ViewModel para o fluxo completo:
   - iniciar recarga no conector 1;
   - iniciar recarga no conector 2;
   - enviar `MeterValues` para ambos;
   - parar apenas um conector;
   - confirmar que o outro permanece carregando.
4. Confirmar que QR Code, grid, exclusão de carregador, status manual e abertura do painel continuam funcionando.
5. Rodar:
   - `flutter analyze`
   - `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
   - `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`
   - `flutter test`
6. Salvar o resumo do slice.

## Regras gerais
- Executar apenas um slice por vez.
- Nunca executar slices em paralelo.
- Nunca avançar para o próximo slice sem o resumo do slice atual.
- Cada slice deve considerar o estado atualizado do código produzido pelo slice anterior.
- Preservar alterações existentes no worktree.
- Não fazer commit automaticamente.
- Não executar `git reset --hard`, `git checkout --` ou operação destrutiva sem autorização explícita.
- Não alterar contratos de repositórios, modelos de domínio ou payloads OCPP sem necessidade comprovada.
- Não remover propriedades públicas já usadas por widgets e testes.
- Preservar compatibilidade com carregadores de um único conector.
- Não misturar refatorações fora do escopo de independência por conector.

## Resultado esperado
Ao concluir todos os slices, o carregador deve suportar dois conectores independentes no mesmo equipamento, com estado operacional, transação, medição, temporizadores e UI coerentes por conector, mantendo os comportamentos antigos já cobertos pelos testes.
