# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 1/5 derivado de @file:carregador-26-05-11-7.md.

## Arquivos
- @file:carregador-26-05-11-7.md
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na preparação do estado operacional por conector.
- Manter o comportamento atual para carregadores com um único conector.
- Preservar as propriedades reativas públicas existentes como espelho do conector ativo.
- Não mudar ainda o fluxo OCPP de iniciar, pausar, retomar, parar ou enviar medidor.
- A configuração de conectores do carregador deve chegar ao `CarregadorWidgetViewModel`.

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não remover propriedades públicas já usadas por widgets e testes.
- Não alterar contratos de repositórios, modelos de domínio ou payloads OCPP neste slice.
- Não mudar layout visual do `CarregadorWidget` ou da `CarregadoresPage` neste slice.

## Entregáveis
1. Criar uma estrutura privada de estado operacional por conector no `CarregadorWidgetViewModel`, concentrando os valores que hoje são únicos do carregador:
   - medidor atual;
   - medidor inicial da transação;
   - potência;
   - SoC;
   - temperatura;
   - capacidade da bateria;
   - tempo de carregamento;
   - transação;
   - status e estado operacional.
2. Adicionar ao construtor do `CarregadorWidgetViewModel` uma forma opcional de receber os IDs dos conectores configurados, sem quebrar chamadas existentes.
3. Ajustar `_criarCarregadorViewModelPadrao(...)` em `CarregadoresPageViewModel` para passar os conectores reais da configuração.
4. Garantir que `selecionarConector(...)` sincronize os `Rx` públicos com o estado do conector selecionado.
5. Ajustar `atualizarPotencia`, `atualizarMedidor`, `atualizarSoc` e `atualizarTemperatura` para persistirem o valor no estado do conector ativo.
6. Manter `statusConectores` atualizado e compatível com os chips da página.
7. Adicionar teste unitário garantindo que valores editados no conector 1 não sobrescrevem valores editados no conector 2 ao alternar o conector ativo.
8. Rodar `flutter analyze`.
9. Rodar `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`.
10. Rodar `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`.
11. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-11-7-parte_1-resumo.md`.

# Descrição
- Preparar o `CarregadorWidgetViewModel` para manter estado independente por conector, sem alterar ainda o fluxo de comandos OCPP.

## Objetivo
- Criar a base interna para que medidor, potência, SoC, temperatura, tempo, status e transação deixem de ser compartilhados entre conectores.
