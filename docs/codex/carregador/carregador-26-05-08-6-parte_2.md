# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 2/4 derivado de @file:carregador-26-05-08-6.md.

## Arquivos
- @file:carregador-26-05-08-6.md
- @file:carregador-26-05-08-6-parte_1-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente no posicionamento do botao de deletar o carregador.
- O botao de deletar deve ficar no canto superior esquerdo do widget de apresentacao do carregador.
- Manter a chave `ValueKey<String>('carregador_excluir_${configuracao.id}')`.
- Manter o fluxo atual de confirmacao e remocao do carregador.
- Manter as edicoes manuais existentes e adaptar a implementacao ao estado atual do arquivo.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos, repositorios, view models ou dialogos.
- Nao alterar o grid criado no slice anterior, exceto se for indispensavel para acomodar o botao sem overflow.
- Nao alterar neste slice o estilo de `_ConectorConfiguradoChip`.
- Nao alterar neste slice o status visual exibido na imagem do carregador.

## Entregaveis
1. Mover o `IconButton` de exclusao para o canto superior esquerdo de `_CarregadorBotaoVisual`.
2. Remover o botao de exclusao da area de detalhes, se ele permanecer duplicado apos a mudanca.
3. Ajustar parametros e construtores privados que ficarem obsoletos por causa da mudanca.
4. Garantir que tocar no botao de exclusao abre a confirmacao de remocao e nao abre o painel do carregador.
5. Preservar o estado desabilitado quando `onRemover == null`.
6. Atualizar o teste `exclui carregador da lista` se o posicionamento novo exigir ajuste no tap.
7. Rodar `flutter analyze`.
8. Rodar o teste de widget da pagina de carregadores.
9. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-6-parte_2-resumo.md`.

# Descricao
- Reposicionamento do comando de exclusao para o canto superior esquerdo do card de apresentacao do carregador.

## Objetivo
- Deixar a acao de deletar no local solicitado sem alterar o comportamento funcional de exclusao.
