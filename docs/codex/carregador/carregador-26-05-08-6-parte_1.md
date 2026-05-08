# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 1/4 derivado de @file:carregador-26-05-08-6.md.

## Arquivos
- @file:carregador-26-05-08-6.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na disposicao responsiva da lista de carregadores.
- A pagina `CarregadoresPage` deve exibir os carregadores em grid.
- O grid deve ter minimo de 1 carregador por linha e maximo de 4 carregadores por linha, conforme a largura disponivel.
- Manter o visual interno atual de cada card de carregador neste slice.
- Manter as edicoes manuais existentes e adaptar a implementacao ao estado atual do arquivo.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos, repositorios, view models, dialogos ou regras de cadastro/remocao.
- Nao alterar neste slice o estilo de `_ConectorConfiguradoChip`.
- Nao mover neste slice o botao de deletar do carregador.
- Nao alterar neste slice o status visual exibido na imagem do carregador.

## Entregaveis
1. Alterar `_ListaCarregadores` para usar um layout de grid responsivo no lugar da lista vertical simples.
2. Calcular a quantidade de colunas com base na largura disponivel, limitando o valor entre 1 e 4.
3. Manter os paddings da pagina e definir espacamento horizontal/vertical consistente entre os cards.
4. Garantir que cada item do grid continue usando `_CarregadorBotaoVisual` e mantenha o fluxo de abertura do painel.
5. Adicionar ou ajustar teste de widget para validar que, em largura ampla, ate 4 carregadores aparecem na mesma linha.
6. Confirmar que nao ha overflow visual em largura compacta.
7. Rodar `flutter analyze`.
8. Rodar o teste de widget da pagina de carregadores.
9. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-6-parte_1-resumo.md`.

# Descricao
- Conversao da disposicao dos carregadores para grid responsivo.

## Objetivo
- Permitir que a pagina apresente 1, 2, 3 ou 4 carregadores por linha conforme a largura disponivel, sem misturar essa mudanca com ajustes visuais internos dos cards.
