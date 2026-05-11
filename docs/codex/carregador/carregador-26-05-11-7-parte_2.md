# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 2/5 derivado de @file:carregador-26-05-11-7.md.

## Arquivos
- @file:carregador-26-05-11-7-parte_1-resumo.md
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`

## Regras
- Trabalhar somente na migração dos comandos OCPP para usar o estado do conector ativo.
- Cada comando deve operar sobre o conector selecionado no momento da chamada.
- Manter compatibilidade com os `Rx` públicos existentes como espelho do conector ativo.
- Manter o comportamento atual para carregadores com um único conector.

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não refatorar temporizadores para múltiplos conectores neste slice.
- Não alterar layout ou widgets neste slice.
- Não alterar contratos de repositórios ou modelos de domínio.
- Não remover os métodos públicos existentes.

## Entregáveis
1. Ajustar `iniciarCarregamento(...)` para ler e gravar transação, medidor inicial, status e estado no conector ativo.
2. Ajustar `pausarCarregamento()`, `retomarCarregamento()` e `pararCarregamento(...)` para alterarem somente o estado do conector ativo.
3. Ajustar `enviarStatusAtual()` para enviar o status do conector ativo sem depender de um status global compartilhado.
4. Ajustar `enviarValoresMedidor(...)` e `_enviarValoresMedidorInterno()` para enviarem `MeterValues` com os valores do conector ativo.
5. Ajustar `RemoteStartTransaction` e `RemoteStopTransaction` para selecionarem e manipularem o conector correto quando o backend informar `connectorId` ou `transactionId`.
6. Garantir que `transacaoId`, `medidorInicioTransacaoWh`, `estado`, `statusConector` e demais `Rx` públicos continuem refletindo o conector ativo após cada transição.
7. Adicionar testes unitários para:
   - iniciar transação no conector 1 e no conector 2 com IDs de transação independentes;
   - enviar `MeterValues` com `connectorId` e valores do conector ativo;
   - parar um conector sem limpar a transação do outro.
8. Rodar `flutter analyze`.
9. Rodar `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`.
10. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-11-7-parte_2-resumo.md`.

# Descrição
- Migrar o fluxo OCPP para usar o estado operacional do conector ativo, mantendo os temporizadores ainda como estão.

## Objetivo
- Impedir que iniciar, parar, alterar status ou enviar medidor em um conector sobrescreva dados transacionais de outro conector.
