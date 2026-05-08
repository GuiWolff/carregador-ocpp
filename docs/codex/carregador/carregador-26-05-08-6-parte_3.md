# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 3/4 derivado de @file:carregador-26-05-08-6.md.

## Arquivos
- @file:carregador-26-05-08-6.md
- @file:carregador-26-05-08-6-parte_2-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na simulacao visual do status dentro da tela do carregador.
- O texto exibido deve vir do estado real do carregador, por meio de `_EstadoVisualCarregador`, e nao de um valor fixo como `Disponivel`.
- O status deve ficar visualmente sobre a imagem do carregador, alinhado ao topo central, como se estivesse na tela do equipamento.
- Manter o layout responsivo criado nos slices anteriores.
- Manter as edicoes manuais existentes e adaptar a implementacao ao estado atual do arquivo.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos, repositorios, view models ou dialogos.
- Nao alterar neste slice o estilo de `_ConectorConfiguradoChip`.
- Nao alterar neste slice a regra do grid, exceto se for necessario para corrigir overflow causado pelo status visual.
- Nao introduzir status hardcoded que fique desconectado dos valores observaveis do carregador.

## Entregaveis
1. Passar `_EstadoVisualCarregador` para `_ImagemCarregador`, se ainda nao estiver disponivel nesse widget.
2. Substituir qualquer placeholder manual/hardcoded de status dentro de `_ImagemCarregador` por um widget dedicado e valido em Dart.
3. Exibir `estadoVisual.rotuloStatus` com cor derivada do estado atual, cobrindo casos como disponivel, desconectado, carregando, pausado, falha e processando.
4. Posicionar o status no topo central da imagem sem cobrir incoerentemente o restante da composicao.
5. Garantir que o status nao gere overflow em largura compacta nem em cards do grid.
6. Adicionar ou ajustar teste de widget para validar a presenca do status visual do carregador.
7. Rodar `flutter analyze`.
8. Rodar o teste de widget da pagina de carregadores.
9. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-6-parte_3-resumo.md`.

# Descricao
- Simulacao visual do codigo de status na tela do carregador.

## Objetivo
- Mostrar o status operacional no proprio desenho do carregador, usando dados reais do view model e sem misturar essa mudanca com o estilo dos conectores.
