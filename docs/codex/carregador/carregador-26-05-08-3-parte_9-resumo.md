# Resumo

Slice final executado para integrar e validar a feature `CarregadoresPage`.

## Alteracoes
- `SimuladorHomePage` passou a delegar o fluxo principal para `CarregadoresPage`, removendo o uso direto de `CarregadorWidget` no ponto de entrada apos login.
- O barrel `lib/features/carregador/carregador.dart` ja exportava `CarregadoresPage` e `CarregadoresPageViewModel`; os exports foram mantidos.
- O dialogo de adicionar carregador agora mantem o controller e o `FocusNode` dentro do ciclo de vida de um `StatefulWidget`, evitando descarte antes da desmontagem completa da rota.
- `test/widget_test.dart` foi ajustado para validar a abertura de `CarregadoresPage` apos login e inicializar `SharedPreferences` em modo mock.
- Adicionado teste de widget para `CarregadoresPage` cobrindo:
  - estado vazio;
  - adicao de carregador via dialogo;
  - persistencia da configuracao;
  - abertura do painel de manipulacao com `CarregadorWidget`.
- Adicionado teste de view model para carregamento em estado vazio.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format ...`: executado nos arquivos alterados.
- `C:\src\flutter\bin\flutter.bat test .\test\features\carregador\presentation\pages\carregador_page_test.dart --reporter expanded`: sucesso.
- `C:\src\flutter\bin\flutter.bat test .\test\features\carregador\presentation\viewmodels\carregadores_page_view_model_test.dart .\test\widget_test.dart --reporter expanded`: sucesso.
- `C:\src\flutter\bin\flutter.bat analyze`: sucesso, sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded`: sucesso, todos os testes passaram.

## Observacoes
- Os comandos Flutter precisaram ser executados com permissao fora do sandbox para acessar `C:\src\flutter\bin\cache\lockfile`.
- O Flutter informou apenas pacotes com versoes mais novas incompativeis com as constraints atuais.
- Nao ha risco residual identificado neste slice.
