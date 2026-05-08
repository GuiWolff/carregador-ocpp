# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 4/4 derivado de @file:carregador-26-05-08-6.md.

## Arquivos
- @file:carregador-26-05-08-6.md
- @file:carregador-26-05-08-6-parte_3-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente no estilo visual de `_ConectorConfiguradoChip` e na validacao final dos ajustes desta tarefa.
- `_ConectorConfiguradoChip` nao deve ter borda.
- `_ConectorConfiguradoChip` nao deve ter fundo azul claro ou enfase em `primary`; deve usar cor neutra do tema.
- Manter textos, imagens, tamanhos gerais e status dos conectores funcionais.
- Manter as edicoes manuais existentes e adaptar a implementacao ao estado atual do arquivo.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos, repositorios, view models ou dialogos.
- Nao refatorar a pagina inteira.
- Nao alterar a regra do grid, a posicao do botao de deletar ou o status visual do carregador, exceto para corrigir regressao diretamente causada pelo estilo dos conectores.
- Nao remover informacoes visuais essenciais dos conectores, como identificacao, posicao, potencia e status.

## Entregaveis
1. Remover as bordas dos cards/chips criados por `_ConectorConfiguradoChip`, incluindo os casos de 1 conector e 2 conectores.
2. Substituir fundos azulados ou baseados em `cores.primary` por cores neutras do tema, como `surfaceContainerHighest`, `surfaceContainer` ou combinacoes equivalentes.
3. Ajustar ou remover helpers de cor que ficarem obsoletos, mantendo o codigo simples e localizado.
4. Garantir contraste adequado para textos, imagens e chips internos de status.
5. Revisar a tela final considerando os quatro objetivos do prompt original: grid, botao de deletar no canto superior esquerdo, status visual no carregador e conectores neutros sem borda.
6. Confirmar que nao ha overflow visual em largura compacta e em largura ampla com ate 4 carregadores por linha.
7. Rodar `flutter analyze`.
8. Rodar o teste de widget da pagina de carregadores.
9. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-6-parte_4-resumo.md`.

# Descricao
- Ajuste final dos conectores para uma aparencia neutra e sem borda.

## Objetivo
- Concluir as melhorias visuais solicitadas para os conectores mantendo a pagina responsiva, testada e coerente com os slices anteriores.
