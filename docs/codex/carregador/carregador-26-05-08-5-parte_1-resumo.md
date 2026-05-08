# Resumo

Slice 1/6 concluido: a representacao principal do carregador na pagina de carregadores foi migrada de SVG para PNG.

## Alteracoes

- Confirmado que `assets/carregador/` continua registrado em `pubspec.yaml`.
- Atualizado `_assetCarregador(...)` para retornar:
  - `assets/carregador/carregador_1_conector.png` para carregadores com 1 conector;
  - `assets/carregador/carregador_2_conectores.png` para carregadores com 2 conectores.
- Atualizado `_CarregadorSvg(...)` para renderizar `Image.asset(...)` com `fit: BoxFit.contain`, `semanticLabel` e `errorBuilder`.
- Removido o import de `package:flutter_svg/flutter_svg.dart` de `carregador_page.dart`, pois ficou sem uso nesse arquivo.

## Validacao

- `C:\src\flutter\bin\flutter.bat analyze`: sem issues.
- `C:\src\flutter\bin\flutter.bat test --reporter expanded .\test\features\carregador\presentation\pages\carregador_page_test.dart`: todos os testes passaram.

## Observacoes

- A dependencia `flutter_svg` foi mantida em `pubspec.yaml`, conforme restricao do slice.
- A interface visual dos chips de conectores nao foi alterada.
- Nenhum asset de `resources/` foi usado como asset de runtime.
