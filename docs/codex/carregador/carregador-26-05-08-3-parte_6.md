# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 6/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_5-resumo.md
- `lib/features/carregador/domain/models/modelos_carregador.dart`
- `lib/features/carregador/domain/repositories/`
- `lib/features/carregador/data/repositories/`
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `lib/features/carregador/presentation/viewmodels/carregadores_page_view_model.dart`
- `test/features/carregador/presentation/viewmodels/`

## Regras
- Criar `CarregadoresPageViewModel` como coordenador da lista de carregadores.
- Controllers/ViewModels não devem acessar `BuildContext`.
- A ViewModel da página deve concentrar estado, carregamento, adição, remoção e persistência.
- Reutilizar `CarregadorWidgetViewModel` para o estado operacional de cada carregador.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não implementar a página visual neste slice.
- Não recriar `CarregadorWidgetViewModel` dentro de builds futuros; preparar a estrutura para manter instâncias estáveis.
- Se precisar ajustar `CarregadorWidgetViewModel`, adicionar apenas parâmetros opcionais sem quebrar chamadas existentes.

## Entregáveis
1. Criar `carregadores_page_view_model.dart`.
2. Expor lista reativa de carregadores configurados e seus respectivos `CarregadorWidgetViewModel`.
3. Carregar configurações do repositório local ao inicializar.
4. Implementar adição e remoção com persistência.
5. Descartar corretamente todas as view models filhas no `dispose`.
6. Criar testes unitários cobrindo carregar, adicionar, remover e descartar.
7. Rodar `flutter analyze`.
8. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_6-resumo.md`.

# Descrição
- Estado da tela de carregadores, separado da renderização.

## Objetivo
- Preparar uma ViewModel testável para a futura `CarregadoresPage`.
- Garantir que a tela apenas observe estado e dispare ações, sem regra de negócio.
