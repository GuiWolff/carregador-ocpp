# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 7/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_6-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `lib/features/carregador/presentation/widgets/`
- `lib/widget/custom_alert_dialog.dart`
- `lib/observable/obx.dart`

## Regras
- Criar a tela `CarregadoresPage`.
- A página deve observar a `CarregadoresPageViewModel` via `Obx`.
- Usar builder para listas ou grids.
- Usar cores semânticas do tema e evitar cores hardcoded.
- Manter a página focada em renderização e orquestração de UI.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não colocar persistência diretamente na página.
- Não duplicar lógica já existente na ViewModel.
- Não fazer integração final com `SimuladorHomePage` neste slice, salvo se for necessário para compilar.

## Entregáveis
1. Criar `CarregadoresPage` em `presentation/pages/carregador_page.dart`.
2. Exibir cabeçalho, estado vazio e botão para adicionar carregador.
3. Abrir o diálogo de criação do slice 5 e enviar o resultado para a ViewModel.
4. Renderizar a lista de carregadores usando `ListView.builder` ou `GridView.builder`.
5. Garantir layout responsivo para web, desktop e mobile.
6. Rodar `flutter analyze`.
7. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_7-resumo.md`.

# Descrição
- Primeira versão da tela de listagem de carregadores.

## Objetivo
- Conectar o fluxo de adicionar carregador com a ViewModel da página.
- Entregar uma tela funcional, mesmo antes da lapidação visual com SVGs e diálogo de manipulação.
