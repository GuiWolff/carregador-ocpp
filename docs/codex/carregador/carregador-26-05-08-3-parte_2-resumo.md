# Resumo

Slice executado para modelar a configuracao de carregadores no dominio.

## Alteracoes
- Criado `TipoConectorCarregador` com os tipos suportados:
  - `CCS2`
  - `MENNEKES_TYPE_2`
  - `GBT`
- Criado `ConectorCarregadorConfigurado` com `id`, `tipo`, `toJson` e `fromJson`.
- Criado `CarregadorConfigurado` com `id`, lista imutavel de conectores, `toJson` e `fromJson`.
- Adicionadas validacoes estruturais:
  - id do carregador nao pode ser vazio;
  - quantidade de conectores deve ser 1 ou 2;
  - cada conector desserializado precisa ter tipo textual nao vazio e suportado;
  - id do conector precisa ser inteiro positivo.
- Criado teste unitario `test/features/carregador/domain/models/configuracao_carregador_test.dart`.

## Restricoes mantidas
- Nenhuma dependencia de `BuildContext`, `Widget`, `Color` ou codigo visual foi adicionada ao dominio.
- Nenhum path de asset foi adicionado ao dominio.
- Enums OCPP existentes nao foram alterados.
- Nao houve implementacao de storage, dialogo, pagina ou view model neste slice.

## Validacao
- `flutter test .\test\features\carregador\domain\models`: executado com sucesso, 11 testes passando.
- `flutter analyze`: executado com sucesso, sem issues.

## Observacao
- O comando de teste ficou sem resposta quando executado dentro do sandbox padrao; repetido fora do sandbox com permissao aprovada, concluiu com sucesso.
