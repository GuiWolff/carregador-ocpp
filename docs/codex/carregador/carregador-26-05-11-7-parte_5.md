# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 5/5 derivado de @file:carregador-26-05-11-7.md.

## Arquivos
- @file:carregador-26-05-11-7-parte_4-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/widgets/carregador_widget.dart`
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`

## Regras
- Trabalhar somente no fechamento funcional, cobertura de testes e pequenos ajustes necessários.
- Manter todos os comportamentos existentes de carregador com um conector.
- Validar explicitamente o cenário de carregador com dois conectores independentes.
- Corrigir apenas problemas diretamente ligados aos slices anteriores.

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não iniciar novas refatorações fora do escopo de independência por conector.
- Não alterar contratos de repositórios ou modelos de domínio sem necessidade comprovada.
- Não remover código legado sem confirmação explícita.

## Entregáveis
1. Revisar o comportamento final para garantir que:
   - cada conector mantém status próprio;
   - cada conector mantém transação própria;
   - cada conector mantém medidor, potência, SoC, temperatura e tempo próprios;
   - alternar o conector ativo não sobrescreve dados do outro;
   - o card/lista e o painel continuam consistentes.
2. Ajustar eventuais regressões visuais pequenas causadas pela seleção de conector.
3. Adicionar ou ajustar testes de widget e viewmodel para o fluxo completo:
   - iniciar recarga no conector 1;
   - iniciar recarga no conector 2;
   - enviar `MeterValues` para ambos;
   - parar apenas um conector;
   - confirmar que o outro permanece carregando.
4. Confirmar que QR Code, grid, exclusão de carregador, status manual e abertura do painel continuam funcionando.
5. Rodar `flutter analyze`.
6. Rodar `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`.
7. Rodar `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`.
8. Rodar `flutter test`.
9. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-11-7-parte_5-resumo.md`.

# Descrição
- Fechamento da refatoração de carregamento independente por conector.

## Objetivo
- Entregar o fluxo completo validado, com independência real de recarga entre conectores e sem regressão nos comportamentos já cobertos.
