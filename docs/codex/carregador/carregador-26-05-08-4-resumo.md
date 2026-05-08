# Resumo

Execucao do prompt `carregador-26-05-08-4.md` para tornar possivel deletar um carregador da lista.

## Alteracoes
- Adicionada acao de exclusao em cada item da `CarregadoresPage`.
- A exclusao abre confirmacao antes de chamar `CarregadoresPageViewModel.remover`.
- Em caso de falha na remocao, a pagina mostra um `SnackBar` com a mensagem do view model ou uma mensagem padrao.
- A remocao reaproveita o fluxo ja existente do view model, preservando persistencia e descarte do `CarregadorWidgetViewModel` removido.
- Adicionado teste de widget cobrindo exclusao de carregador, persistencia da lista restante e desconexao do repositorio operacional removido.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart .\test\features\carregador\presentation\pages\carregador_page_test.dart`: sucesso.
- `C:\src\flutter\bin\flutter.bat test .\test\features\carregador\presentation\pages\carregador_page_test.dart --reporter expanded`: sucesso.
- `C:\src\flutter\bin\flutter.bat analyze`: sucesso, sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded`: sucesso, todos os testes passaram.

## Observacoes
- Os comandos Flutter precisaram rodar com permissao fora do sandbox para acessar `C:\src\flutter\bin\cache\lockfile`.
- O Flutter informou apenas pacotes com versoes mais novas incompativeis com as constraints atuais.
