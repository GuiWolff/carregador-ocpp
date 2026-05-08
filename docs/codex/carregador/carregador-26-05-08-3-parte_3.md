# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 3/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_2-resumo.md
- `lib/features/carregador/domain/models/modelos_carregador.dart`
- `lib/features/carregador/domain/repositories/`
- `lib/features/carregador/data/repositories/`
- `test/features/carregador/data/repositories/`

## Regras
- Implementar armazenamento dentro da feature `carregador`, respeitando a arquitetura vertical.
- Tratar os dados como sensíveis: não logar valores, não expor em mensagens de erro e não armazenar segredos desnecessários.
- Manter uma abstração de repositório para permitir trocar a estratégia de storage no futuro.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não usar import web-only direto, como `dart:html`, em arquivo compartilhado, para não quebrar Desktop/Mobile.
- Não implementar UI, diálogo ou página neste slice.
- Não prometer segurança forte de cookie HttpOnly via código client-side; se a implementação usar `shared_preferences`, registrar essa limitação no resumo.

## Entregáveis
1. Criar contrato de repositório para carregar, salvar e limpar configurações de carregadores.
2. Criar implementação local usando a dependência já disponível no projeto, preferencialmente `shared_preferences`.
3. Usar uma chave versionada e namespaced para os dados da feature.
4. Tratar JSON inválido ou estado corrompido sem quebrar a tela futura.
5. Criar testes unitários usando mock de `SharedPreferences`.
6. Rodar `flutter analyze`.
7. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_3-resumo.md`.

# Descrição
- Persistência local das configurações de carregadores criadas pelo usuário.

## Objetivo
- Permitir que os carregadores criados sejam recuperados em execuções futuras.
- Manter o storage encapsulado, testável e sem dependência direta da UI.
