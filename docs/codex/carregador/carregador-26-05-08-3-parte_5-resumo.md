# Resumo

Slice executado para criar o fluxo visual isolado de adicionar carregador.

## Alteracoes
- Criado `abrirDialogoAdicionarCarregador` em `lib/features/carregador/presentation/widgets/adicionar_carregador_dialog.dart`.
- O dialogo usa `showCustomAlertDialog<CarregadorConfigurado>` e retorna um `CarregadorConfigurado` ao confirmar.
- O formulario coleta id do carregador, quantidade de conectores limitada a 1 ou 2 e tipo de cada conector.
- A quantidade de conectores e os tipos selecionados usam `Rx` e `Obx`, sem `setState`.
- A UI valida id vazio e ids duplicados recebidos por parametro.
- Controllers, focus node e estados `Rx` sao descartados ao fechar o dialogo.
- As opcoes de conector usam rotulos claros e miniaturas dos assets existentes.
- `CustomDropdown` recebeu suporte opcional a `itemBuilder`, mantendo compatibilidade com os usos atuais.
- O novo helper foi exportado em `lib/features/carregador/carregador.dart`.

## Restricoes mantidas
- Nenhuma persistencia foi implementada neste slice.
- `CarregadoresPage` nao foi implementada.
- O fluxo ficou isolado dentro da feature `carregador`.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\widget\custom_dropdown.dart .\lib\features\carregador\presentation\widgets\adicionar_carregador_dialog.dart .\lib\features\carregador\carregador.dart`: executado com sucesso.
- `C:\src\flutter\bin\flutter.bat analyze`: executado com sucesso, sem issues.
