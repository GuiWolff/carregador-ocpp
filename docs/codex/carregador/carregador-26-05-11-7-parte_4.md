# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 4/5 derivado de @file:carregador-26-05-11-7.md.

## Arquivos
- @file:carregador-26-05-11-7-parte_3-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `lib/features/carregador/presentation/widgets/carregador_widget.dart`
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na integração da UI com o estado independente por conector.
- O painel do carregador deve permitir selecionar o conector configurado e refletir os dados daquele conector.
- Preservar o QR Code do carregador implementado anteriormente.
- Manter compatibilidade com uso antigo do `CarregadorWidget` sem lista de conectores.
- Usar estado reativo do viewmodel, sem `setState` para sincronização de dados de recarga.

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não alterar contratos de repositórios ou modelos de domínio.
- Não misturar ajustes visuais grandes que não sejam necessários para a seleção de conector.
- Não remover campos ou ações existentes sem necessidade.

## Entregáveis
1. Adicionar ao `CarregadorWidget` uma entrada opcional para receber os conectores configurados do carregador.
2. Passar `configuracao.conectores` ao abrir o painel em `CarregadoresPage`.
3. Exibir uma seleção de conector no painel quando houver conectores configurados, preferindo componente existente do projeto.
4. Manter o campo manual de conector apenas como compatibilidade quando o widget não receber a configuração de conectores.
5. Garantir que trocar o conector no painel atualize:
   - campos de potência, medidor, SoC e temperatura;
   - métricas;
   - status manual;
   - estado dos botões de ação.
6. Garantir que alterações feitas nos campos do painel sejam gravadas no conector ativo.
7. Ajustar os chips de conectores da página para refletirem corretamente o conector ativo e os status independentes.
8. Adicionar testes de widget cobrindo carregador com dois conectores:
   - abrir painel;
   - selecionar conector 2;
   - validar que os campos exibem os dados do conector 2;
   - executar ação usando o conector 2.
9. Rodar `flutter analyze`.
10. Rodar `flutter test test\features\carregador\presentation\pages\carregador_page_test.dart`.
11. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-11-7-parte_4-resumo.md`.

# Descrição
- Integrar o painel e os chips da página ao estado por conector, permitindo que o usuário opere o conector correto.

## Objetivo
- Tornar visível e manipulável a independência por conector sem quebrar o fluxo atual do painel do carregador.
