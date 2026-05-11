# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 3/5 derivado de @file:carregador-26-05-11-7.md.

## Arquivos
- @file:carregador-26-05-11-7-parte_2-resumo.md
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`

## Regras
- Trabalhar somente na independência dos temporizadores e evolução automática por conector.
- Cada conector carregando deve evoluir medidor, SoC, temperatura e tempo sem depender do conector ativo atual.
- Manter o comportamento atual para carregadores com um único conector.
- Cancelar corretamente temporizadores ao pausar, parar, desconectar e descartar o viewmodel.

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não alterar layout ou widgets neste slice.
- Não alterar contratos de repositórios ou modelos de domínio.
- Não introduzir lógica pesada em widgets.

## Entregáveis
1. Mover `_medidorTimer`, `_tempoCarregamentoTimer`, `_ultimaAtualizacaoMedidor`, `_inicioPeriodoCarregamento` e `_tempoCarregamentoAcumulado` para o estado de cada conector ou para mapas privados por conector.
2. Ajustar início, pausa, retomada e parada do carregamento para controlar somente os temporizadores do conector correspondente.
3. Permitir que dois conectores possam permanecer em carregamento ao mesmo tempo, cada um com sua evolução de medidor, SoC, temperatura e tempo.
4. Garantir que `enviarValoresMedidor(incrementarAntes: true)` incremente apenas o conector selecionado.
5. Garantir que os `Rx` públicos sejam sincronizados quando o conector ativo for o mesmo que recebeu atualização automática.
6. Cancelar todos os temporizadores de todos os conectores em `desconectar()`, `_pararTimers()` e `dispose()`.
7. Rever o controle de envio simultâneo de `MeterValues` para não bloquear permanentemente um conector por causa do envio de outro.
8. Adicionar testes unitários cobrindo:
   - evolução de medidor/SoC/temperatura isolada por conector;
   - pausa de um conector sem pausar o outro;
   - descarte do viewmodel cancelando todos os temporizadores.
9. Rodar `flutter analyze`.
10. Rodar `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`.
11. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-11-7-parte_3-resumo.md`.

# Descrição
- Separar os temporizadores e a evolução automática de recarga para que cada conector tenha ciclo próprio.

## Objetivo
- Permitir recargas simultâneas e independentes no mesmo carregador, sem que o temporizador de um conector altere os dados do outro.
