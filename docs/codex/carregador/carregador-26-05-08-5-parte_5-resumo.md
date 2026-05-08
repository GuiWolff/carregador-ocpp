# Resumo

Slice 5/6 concluido: a variante de chips para carregador com 2 conectores foi implementada com cards estreitos para `Esquerdo` e `Direito`, seguindo a intencao visual de `resources/Group_34.png` e `resources/Group_35.png`.

## Alteracoes

- `_ConectoresConfigurados(...)` voltou a usar `Wrap` centralizado, com `spacing` e `runSpacing`, permitindo quebra responsiva quando faltar largura.
- `_ConectorConfiguradoChip(...)` agora possui layout especifico para `totalConectores == 2`.
- O conector de indice `0` exibe o rotulo `Esquerdo`.
- O conector de indice `1` exibe o rotulo `Direito`.
- Os chips laterais usam dimensoes estaveis (`156 x 260`) para evitar mudanca de tamanho entre estados.
- Cada chip lateral exibe:
  - imagem real do conector vinda de `assets/carregador/`;
  - fallback com `Icons.cable` se o asset falhar;
  - texto `ID <carregador> / <conector>`;
  - rotulo `Esquerdo` ou `Direito`;
  - potencia em kW;
  - pill com status visual atual.
- Adicionado teste de widget para validar a renderizacao de `Esquerdo`, `Direito` e os IDs dos conectores em carregador com 2 conectores.

## Validacao

- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart .\test\features\carregador\presentation\pages\carregador_page_test.dart`: sem alteracoes apos formatacao.
- `C:\src\flutter\bin\flutter.bat analyze`: sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded .\test\features\carregador\presentation\pages\carregador_page_test.dart`: todos os testes passaram.

## Observacoes

- `resources/Group_34.png` e `resources/Group_35.png` foram usados apenas como referencias visuais e nao foram cadastrados como assets de runtime.
- O primeiro ciclo do teste de widget detectou overflow vertical de 4 px no chip lateral com status `Desconectado`; a altura fixa foi ajustada para `260`.
- Nenhum modelo de dominio foi alterado.
- Nenhuma regra de persistencia foi alterada.
- A variante de 1 conector foi preservada.
