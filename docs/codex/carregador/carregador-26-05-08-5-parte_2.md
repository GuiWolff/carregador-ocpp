# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 2/6 derivado de @file:carregador-26-05-08-5.md.

## Arquivos
- @file:carregador-26-05-08-5-parte_1-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `resources/proposta_widget_visualizacao_carregador_1_conector.png`
- `resources/proposta_widget_visualizacao_carregador_2_conectores.png`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na composicao da visualizacao do carregador.
- A imagem do carregador deve ficar no topo.
- Os chips dos conectores configurados devem ficar logo abaixo da imagem.
- O conjunto imagem + chips deve ficar centralizado.
- Manter a aparencia atual dos chips neste slice; a mudanca visual dos chips fica para slices seguintes.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos, repositorios, view model ou dialogo de cadastro.
- Nao duplicar a lista de conectores na tela.
- Nao remover o bloco de detalhes do carregador, estado ou botao de exclusao.

## Entregaveis
1. Extrair ou reorganizar a area visual do card para formar uma coluna com:
   - imagem do carregador;
   - espaco vertical;
   - `_ConectoresConfigurados(...)`.
2. Remover `_ConectoresConfigurados(...)` de dentro de `_CarregadorBotaoDetalhes(...)`, se a lista passar a ser exibida na nova area visual.
3. Ajustar o layout responsivo para manter a coluna centralizada em larguras compactas e desktop.
4. Garantir que os detalhes do carregador, estado e botao de exclusao continuem acessiveis.
5. Rodar `flutter analyze`.
6. Rodar o teste de widget da pagina de carregadores.
7. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-5-parte_2-resumo.md`.

# Descricao
- Reorganizacao da composicao para seguir as propostas visuais: carregador em cima e conectores abaixo.

## Objetivo
- Preparar a estrutura da tela para receber os chips novos sem misturar reflow de layout com estilo visual dos chips.
