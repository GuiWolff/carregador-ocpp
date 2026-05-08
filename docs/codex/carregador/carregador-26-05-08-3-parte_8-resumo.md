# Resumo

Slice executado para lapidar a listagem visual dos carregadores configurados.

## Alteracoes
- A listagem de `CarregadoresPage` deixou de renderizar o painel operacional completo em cada item.
- Cada carregador agora aparece como um botao visual com `InkWell`, exibindo o SVG correspondente:
  - `assets/carregador/carregador_1_conector.svg` para 1 conector.
  - `assets/carregador/carregador_2_conectores.svg` para 2 conectores.
- O item visual mostra o id do carregador, a quantidade de conectores, o status operacional observado do `CarregadorWidgetViewModel` e os conectores configurados.
- Os conectores configurados aparecem como chips com miniatura usando:
  - `assets/carregador/conector_CCS2.png`
  - `assets/carregador/conector_MENNEKES_type_2.png`
  - `assets/carregador/conector_GBT.png`
- Ao tocar no carregador, a pagina abre um `CustomAlertDialog` com `CarregadorWidget`.
- O dialogo usa o `CarregadorWidgetViewModel` ja existente em `CarregadorPageItem`, preservando a instancia operacional do carregador selecionado.
- O dialogo recebeu largura maxima maior e conteudo rolavel pelo proprio `CustomAlertDialog`, mantendo uso viavel em telas pequenas.

## Validacao
- `C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .\lib\features\carregador\presentation\pages\carregador_page.dart`: executado com sucesso.
- `C:\src\flutter\bin\flutter.bat analyze`: executado com sucesso, sem issues.

## Observacoes
- `dart format` pelo comando curto `dart` ficou pendurado e atingiu timeout; a formatacao foi refeita com o executavel explicito do Dart SDK do Flutter.
- O `flutter analyze` informou apenas pacotes com versoes mais novas incompativeis com as constraints atuais.
