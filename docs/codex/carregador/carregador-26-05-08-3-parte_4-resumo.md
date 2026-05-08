# Resumo

Slice executado para criar o dialogo base reutilizavel da aplicacao.

## Alteracoes
- Implementado `CustomAlertDialog` em `lib/widget/custom_alert_dialog.dart`.
- O dialogo recebe titulo, descricao opcional, conteudo opcional, lista de campos dinamicos e lista de acoes configuraveis.
- Criado helper tipado `showCustomAlertDialog<T>` para abrir o dialogo com `showDialog<T>` e retornar o resultado do `Navigator.pop`.
- O corpo do dialogo usa `SingleChildScrollView` dentro de area flexivel, mantendo titulo e acoes visiveis em telas pequenas.
- O layout usa `Theme.of(context)`, `ColorScheme` e `TextTheme`, sem acoplamento com a feature `carregador`.
- As acoes sao widgets passados pelo chamador, permitindo reutilizar `BotaoPrimario`, `BotaoSecundario` ou outro controle global sem regra de negocio no dialogo.

## Restricoes mantidas
- Nenhuma regra de negocio de carregador foi adicionada ao widget global.
- Nenhum formulario especifico de carregador foi implementado neste slice.
- Nenhuma dependencia circular entre `lib/widget` e features foi criada.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\widget\custom_alert_dialog.dart`: executado com sucesso.
- `C:\src\flutter\bin\flutter.bat analyze`: executado com sucesso, sem issues.

## Observacao
- `dart format .\lib\widget\custom_alert_dialog.dart` via PATH ficou sem retorno dentro de 30s; o mesmo formatador executado diretamente pelo SDK do Flutter concluiu com sucesso.
