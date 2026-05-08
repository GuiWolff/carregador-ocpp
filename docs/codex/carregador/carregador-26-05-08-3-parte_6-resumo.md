# Resumo

Slice executado para criar a ViewModel coordenadora da futura tela de
carregadores.

## Alteracoes
- Criado `CarregadoresPageViewModel` em `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`.
- A ViewModel carrega configuracoes com `ConfiguracaoCarregadorRepositoryLocal` por padrao.
- Exposta lista reativa `carregadores` com `CarregadorPageItem`, contendo a configuracao e a `CarregadorWidgetViewModel` operacional correspondente.
- A criacao das VMs operacionais fica centralizada na ViewModel da pagina e preserva instancias por id normalizado.
- Implementadas operacoes de carregar, adicionar e remover com persistencia no repositorio.
- Adicao e remocao ficam bloqueadas enquanto ha carregamento ou salvamento em andamento.
- Remocoes descartam apenas a VM operacional removida.
- `dispose` descarta todas as VMs filhas e os estados reativos da pagina.
- `CarregadoresPageViewModel` foi exportada no barrel `lib/features/carregador/carregador.dart`.

## Testes
- Criado `test/features/carregador/presentation/viewmodels/carregadores_page_view_model_test.dart`.
- Coberto carregamento com preservacao de instancias.
- Coberta adicao com persistencia e rejeicao de id duplicado.
- Coberta remocao com persistencia e descarte da VM filha removida.
- Coberto descarte de todas as VMs filhas no `dispose`.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\viewmodels\carregadores_page_view_model.dart .\lib\features\carregador\carregador.dart .\test\features\carregador\presentation\viewmodels\carregadores_page_view_model_test.dart`: executado com sucesso.
- `C:\src\flutter\bin\flutter.bat test .\test\features\carregador\presentation\viewmodels\carregadores_page_view_model_test.dart --reporter expanded`: executado com sucesso, 4 testes passaram.
- `C:\src\flutter\bin\flutter.bat analyze`: executado com sucesso, sem issues.

## Observacoes
- O comando Flutter precisou ser executado fora do sandbox porque as tentativas sandboxadas ficaram presas ate o timeout.
- O `flutter analyze` informou apenas pacotes com versoes mais novas incompativeis com as constraints atuais, sem impacto na analise.
