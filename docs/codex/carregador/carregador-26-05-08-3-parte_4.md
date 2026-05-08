# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 4/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_3-resumo.md
- `lib/widget/custom_alert_dialog.dart`
- `lib/widget/botao_primario.dart`
- `lib/widget/botao_secundario.dart`
- `lib/widget/custom_text_form_field.dart`
- `lib/widget/custom_dropdown.dart`

## Regras
- Implementar um diálogo genérico e reutilizável.
- O diálogo não deve conhecer a feature `carregador`.
- Usar cores e tipografia do tema, evitando cores hardcoded.
- Permitir campos dinâmicos passados pelo chamador.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não colocar regra de negócio dentro do `custom_alert_dialog.dart`.
- Não implementar o formulário específico de carregador neste slice.
- Não criar dependência circular entre widgets globais e features.

## Entregáveis
1. Implementar `CustomAlertDialog` em `lib/widget/custom_alert_dialog.dart`.
2. Permitir título, descrição opcional, conteúdo/campos dinâmicos e ações configuráveis.
3. Se fizer sentido, criar helper tipado para abrir o diálogo e retornar resultado.
4. Garantir conteúdo rolável para telas pequenas.
5. Manter layout consistente com os widgets existentes em `lib/widget`.
6. Rodar `flutter analyze`.
7. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_4-resumo.md`.

# Descrição
- Criação do diálogo base reutilizável que será usado pela tela de carregadores e por outras partes do app.

## Objetivo
- Ter um componente genérico antes de criar o diálogo específico de adicionar carregador.
- Evitar acoplamento entre widget global e regra de negócio da feature.
