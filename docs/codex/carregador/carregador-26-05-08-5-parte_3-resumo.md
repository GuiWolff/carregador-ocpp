# Resumo

Slice 3/6 concluido: o contrato de apresentacao dos chips de conectores foi preparado para receber contexto de quantidade, posicao, carregador e estado visual sem alterar a aparencia atual.

## Alteracoes

- `_CarregadorVisualizacao(...)` passou a receber `_EstadoVisualCarregador(...)` com `estado`, `conectado`, `ocupado` e `corEstado` ja disponiveis no card.
- `_ConectoresConfigurados(...)` passou a receber o `carregadorId`, calcular `totalConectores` e iterar os conectores com indice.
- `_ConectorConfiguradoChip(...)` passou a receber:
  - `carregadorId`;
  - `totalConectores`;
  - `indice`;
  - `_EstadoVisualCarregador`.
- Criados helpers privados para rotulo de posicao:
  - `_temConectorCentral(...)`;
  - `_temConectoresLaterais(...)`;
  - `_rotuloPosicaoConector(...)`.
- O texto visual dos chips foi mantido no formato existente `id: tipo`.
- O rotulo de posicao e o status visual foram usados apenas no `semanticLabel` da imagem do conector, preservando o layout atual.

## Validacao

- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart`: sem alteracoes apos formatacao.
- `C:\src\flutter\bin\flutter.bat analyze`: sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded .\test\features\carregador\presentation\pages\carregador_page_test.dart`: todos os testes passaram.

## Observacoes

- Nenhum modelo de dominio foi alterado.
- Nenhuma regra de persistencia foi alterada.
- O visual final dos grupos `Group_34`, `Group_35` e `Group_36` nao foi implementado neste slice.
