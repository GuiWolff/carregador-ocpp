# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 9/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_8-resumo.md
- `lib/features/carregador/carregador.dart`
- `lib/features/simulador/simulador_home_page.dart`
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/viewmodels/`
- `lib/features/carregador/presentation/widgets/`
- `test/features/carregador/`
- `test/widget_test.dart`

## Regras
- Fazer a integração final da feature sem alterar APIs públicas além do necessário.
- Exportar apenas o que precisa ser público no barrel `carregador.dart`.
- Corrigir imports não utilizados e inconsistências de nomenclatura.
- Priorizar testes dos fluxos de maior risco.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não remover código legado sem confirmação explícita.
- Não fazer refatorações fora do escopo da feature.
- Não fazer commit.

## Entregáveis
1. Exportar `CarregadoresPage` e `CarregadoresPageViewModel` em `carregador.dart`, se forem parte da API pública da feature.
2. Integrar a nova tela ao fluxo existente do simulador, substituindo o uso direto de `CarregadorWidget` quando fizer sentido.
3. Revisar nomes públicos para manter consistência: `CarregadoresPage`, `CarregadoresPageViewModel` e modelos de configuração.
4. Adicionar ou ajustar testes de widget e de view model para cobrir:
   - estado vazio;
   - adição de carregador;
   - persistência;
   - abertura do painel de manipulação.
5. Rodar `flutter analyze`.
6. Rodar `flutter test`, se os testes existentes estiverem preparados para isso.
7. Salvar um resumo final em `docs/codex/carregador/carregador-26-05-08-3-parte_9-resumo.md`.

# Descrição
- Integração e validação final da implementação fatiada da `CarregadoresPage`.

## Objetivo
- Fechar a entrega com exports, integração no fluxo atual, testes e validação estática.
- Deixar registrado qualquer risco residual ou decisão técnica pendente no resumo final.
