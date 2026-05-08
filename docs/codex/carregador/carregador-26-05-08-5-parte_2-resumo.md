# Resumo

Slice 2/6 concluido: a composicao visual do card de carregador foi reorganizada para exibir a imagem do carregador no topo e os chips de conectores configurados logo abaixo.

## Alteracoes

- Criado `_CarregadorVisualizacao(...)` para agrupar:
  - `_CarregadorSvg(...)`;
  - espacamento vertical;
  - `_ConectoresConfigurados(...)`.
- Atualizado `_CarregadorBotaoVisual(...)` para usar a nova coluna visual nos layouts compacto e desktop.
- Removida a exibicao de `_ConectoresConfigurados(...)` de `_CarregadorBotaoDetalhes(...)`, evitando duplicacao da lista de conectores.
- Ajustado o `Wrap` de `_ConectoresConfigurados(...)` para centralizar os chips dentro da area visual, mantendo a aparencia atual dos chips.

## Validacao

- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart`: sem alteracoes apos formatacao.
- `C:\src\flutter\bin\flutter.bat analyze`: sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded .\test\features\carregador\presentation\pages\carregador_page_test.dart`: todos os testes passaram.

## Observacoes

- Nenhum modelo, repositorio, view model ou dialogo de cadastro foi alterado.
- O bloco de detalhes do carregador, chip de estado e botao de exclusao continuam no card.
- A mudanca visual dos chips foi deixada para os proximos slices.
