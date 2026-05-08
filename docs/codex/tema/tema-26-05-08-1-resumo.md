# Resumo

- Tarefa executada: teste de cores no tema do app.
- Arquivo alterado: `lib/utils/tema.dart`.
- Implementado `TemaCorAcento` com as cores equivalentes à função Sass `get_accent_color`.
- `TemaApp`, `TemaService` e `TemaCores` agora aceitam `corAcento`, mantendo chamadas existentes compatíveis por parâmetro opcional.
- `primaria`, `acaoPrimaria` e `acento` passam a usar a cor de acento configurada, com padrão `default` (`#E95420`).
- `contrastePrimaria` agora escolhe automaticamente a melhor cor de texto entre claro e escuro com base no contraste.
- `containerPrimario` e `textoPrimarioContainer` agora são derivados da cor primária para manter coerência visual entre os acentos.
- Validação executada: `dart format lib/utils/tema.dart`.
- Validação executada: `flutter analyze` sem issues.
- Observação: alterações pré-existentes em `lib/features/carregador/presentation/pages/carregador_page.dart` e arquivos não rastreados fora da tarefa não foram modificados.
