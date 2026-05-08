# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 5/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_4-resumo.md
- `lib/widget/custom_alert_dialog.dart`
- `lib/widget/custom_text_form_field.dart`
- `lib/widget/custom_dropdown.dart`
- `lib/features/carregador/domain/models/modelos_carregador.dart`
- `lib/features/carregador/presentation/widgets/`

## Regras
- Criar o fluxo visual específico para adicionar carregador dentro da feature `carregador`.
- Usar o `CustomAlertDialog` genérico criado no slice anterior.
- Usar estado reativo da pasta `lib/observable/` quando houver alteração dinâmica de campos.
- Manter controllers e focus nodes descartados corretamente.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não persistir dados neste slice.
- Não implementar `CarregadoresPage` neste slice.
- Evitar `setState`; usar `Rx` e `Obx` quando a quantidade de conectores alterar a UI do diálogo.

## Entregáveis
1. Criar widget ou função da feature para abrir o diálogo de adicionar carregador.
2. O diálogo deve coletar:
   - id do carregador;
   - quantidade de conectores, limitada a 1 ou 2;
   - tipo de cada conector.
3. Oferecer opções de conector com rótulos claros e, se viável, miniaturas dos assets existentes.
4. Validar id vazio e ids duplicados recebidos por parâmetro.
5. Retornar um modelo de domínio quando o usuário confirmar.
6. Rodar `flutter analyze`.
7. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_5-resumo.md`.

# Descrição
- Implementação do formulário de criação de carregador usando o diálogo genérico.

## Objetivo
- Entregar um fluxo isolado e reutilizável para coletar a configuração de um novo carregador.
- Deixar a persistência e a listagem para os próximos slices.
