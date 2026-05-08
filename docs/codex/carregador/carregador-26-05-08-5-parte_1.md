# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 1/6 derivado de @file:carregador-26-05-08-5.md.

## Arquivos
- @file:carregador-26-05-08-5.md
- `pubspec.yaml`
- `assets/carregador/carregador_1_conector.png`
- `assets/carregador/carregador_2_conectores.png`
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na troca da representacao do carregador de SVG para PNG.
- Manter a interface visual dos chips de conectores como esta por enquanto.
- Usar os PNGs em `assets/carregador/` como assets de runtime.
- Nao usar imagens de `resources/` como assets de runtime neste slice.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao alterar modelos de dominio, view model, dialogo de cadastro ou comportamento de remocao.
- Nao remover a dependencia `flutter_svg` do `pubspec.yaml` sem confirmar que ela nao e usada em outro ponto do projeto.

## Entregaveis
1. Confirmar que `assets/carregador/` continua registrado no `pubspec.yaml`.
2. Alterar `_assetCarregador(...)` para retornar:
   - `assets/carregador/carregador_1_conector.png` quando houver 1 conector;
   - `assets/carregador/carregador_2_conectores.png` quando houver 2 conectores.
3. Alterar `_CarregadorSvg(...)` para renderizar `Image.asset(...)` com `fit: BoxFit.contain`, mantendo label semantico e fallback de erro.
4. Remover o import de `flutter_svg` de `carregador_page.dart` se ele ficar sem uso.
5. Rodar `flutter analyze`.
6. Rodar o teste de widget da pagina de carregadores.
7. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-5-parte_1-resumo.md`.

# Descricao
- Migracao da imagem principal do carregador para os novos PNGs equivalentes aos SVGs antigos.

## Objetivo
- Deixar o componente do carregador usando os assets PNG pedidos no prompt, sem misturar esta mudanca com a reestruturacao visual dos chips.
