# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 8/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_7-resumo.md
- `assets/carregador/carregador_1_conector.svg`
- `assets/carregador/carregador_2_conectores.svg`
- `assets/carregador/conector_CCS2.png`
- `assets/carregador/conector_MENNEKES_type_2.png`
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/widgets/carregador_widget.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `lib/widget/custom_alert_dialog.dart`

## Regras
- Transformar cada carregador da lista em um botão visual usando o SVG correspondente à quantidade de conectores.
- Ao tocar no carregador, abrir um `CustomAlertDialog` com o `CarregadorWidget` para manipulação, conexão, start, stop e demais ações.
- Preservar a instância correta de `CarregadorWidgetViewModel` de cada carregador.
- Usar miniaturas ou indicadores dos conectores configurados quando houver espaço.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não criar nova `CarregadorWidgetViewModel` a cada abertura de diálogo.
- Não referenciar `assets/carregador/CCS2.png` se o arquivo continuar ausente.
- Não colocar lógica OCPP na página.

## Entregáveis
1. Renderizar `carregador_1_conector.svg` para carregadores com 1 conector.
2. Renderizar `carregador_2_conectores.svg` para carregadores com 2 conectores.
3. Exibir identificação do carregador e conectores configurados.
4. Abrir `CustomAlertDialog` contendo `CarregadorWidget` vinculado ao item selecionado.
5. Garantir que o diálogo seja rolável e utilizável em telas pequenas.
6. Rodar `flutter analyze`.
7. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_8-resumo.md`.

# Descrição
- Lapidação visual e fluxo de manipulação dos carregadores criados.

## Objetivo
- Fazer a tela mostrar os SVGs como botões e usar `CarregadorWidget` como painel operacional dentro do diálogo.
