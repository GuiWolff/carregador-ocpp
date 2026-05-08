# Resumo

Slice 4/6 concluido: a variante de chip para carregador com 1 conector foi implementada como card largo, seguindo a intencao visual de `resources/Group_36.png`.

## Alteracoes

- `_EstadoVisualCarregador(...)` passou a carregar tambem `potenciaW`, usando a fonte ja disponivel em `CarregadorWidgetViewModel`.
- `_ConectorConfiguradoChip(...)` agora bifurca o layout quando `totalConectores == 1`.
- Para o conector unico, foi implementado um card centralizado com:
  - fundo azul claro proporcional ao tema;
  - borda azul e raio maior;
  - marcador circular de status no canto superior esquerdo;
  - imagem real do conector vinda de `assets/carregador/`;
  - fallback com `Icons.cable` se o asset falhar;
  - texto `ID <carregador> / <conector>`;
  - rotulo principal `Conector Central`;
  - potencia em kW;
  - pill com o status visual atual.
- A variante de 2 conectores manteve o layout compacto anterior.

## Validacao

- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart`: sem alteracoes apos formatacao.
- `C:\src\flutter\bin\flutter.bat analyze`: sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded .\test\features\carregador\presentation\pages\carregador_page_test.dart`: todos os testes passaram.

## Observacoes

- `resources/Group_36.png` foi usado apenas como referencia visual e nao foi cadastrado como asset de runtime.
- Nenhum modelo de dominio foi alterado.
- Nenhuma regra de persistencia foi alterada.
- As variantes esquerda/direita para carregadores com 2 conectores ficaram para os proximos slices.
