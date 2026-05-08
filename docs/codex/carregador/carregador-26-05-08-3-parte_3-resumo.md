# Resumo

Slice executado para persistir localmente as configuracoes de carregadores da feature `carregador`.

## Alteracoes
- Criado o contrato `ConfiguracaoCarregadorRepository` com operacoes para carregar, salvar e limpar carregadores configurados.
- Criada a implementacao `ConfiguracaoCarregadorRepositoryLocal` usando `shared_preferences`.
- Adotada chave versionada e namespaced:
  - `simulador_ocpp.features.carregador.configuracoes.v1`
- O payload salvo usa objeto JSON com `versao` e lista `carregadores`.
- A leitura retorna lista vazia quando nao ha dados, quando o JSON esta invalido, quando a versao nao e suportada ou quando o estado salvo esta corrompido.
- Exportados o contrato e a implementacao no barrel `lib/features/carregador/carregador.dart`.
- Criado teste unitario `test/features/carregador/data/repositories/configuracao_carregador_repository_local_test.dart`.

## Restricoes mantidas
- Nenhuma UI, dialogo ou pagina foi implementada neste slice.
- Nenhum import web-only foi usado.
- Nenhum valor salvo e logado.
- A implementacao fica encapsulada atras de contrato de repositorio, permitindo trocar a estrategia de storage futuramente.

## Limitacao de seguranca
- `shared_preferences` nao oferece protecao forte equivalente a cookie HttpOnly ou cofre seguro. A implementacao persiste somente a configuracao dos carregadores e nao deve ser usada para armazenar segredos desnecessarios.

## Validacao
- `C:\src\flutter\bin\flutter.bat test .\test\features\carregador\data\repositories\configuracao_carregador_repository_local_test.dart`: executado com sucesso, 6 testes passando.
- `C:\src\flutter\bin\flutter.bat analyze`: executado com sucesso, sem issues.

## Observacao
- O teste ficou sem resposta dentro do sandbox padrao; repetido fora do sandbox com permissao aprovada, concluiu com sucesso.
