# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 1/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3.md
- `pubspec.yaml`
- `assets/carregador/carregador_1_conector.svg`
- `assets/carregador/carregador_2_conectores.svg`
- `assets/carregador/conector_CCS2.png`
- `assets/carregador/conector_MENNEKES_type_2.png`

## Regras
- Preparar somente os pré-requisitos de assets e dependências.
- Manter mudanças pequenas e localizadas.
- Preservar compatibilidade Web/Desktop/Mobile.
- Não implementar página, diálogo, armazenamento ou view model neste slice.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não referencie asset inexistente. O arquivo `assets/carregador/CCS2.png` citado no prompt original não foi localizado; se ele continuar ausente, registre isso no resumo e use apenas os assets existentes.
- Não adicionar dependências desnecessárias.

## Entregáveis
1. Ajustar o `pubspec.yaml` para registrar os assets de `assets/carregador/`.
2. Adicionar a dependência necessária para renderizar SVG no Flutter, se o projeto ainda não tiver suporte a isso.
3. Rodar `flutter pub get`, se houver alteração de dependências.
4. Rodar `flutter analyze`.
5. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_1-resumo.md`.

# Descrição
- Preparação técnica para que os próximos slices consigam renderizar os carregadores em SVG e os conectores em PNG sem quebrar build.

## Objetivo
- Garantir que os assets do carregador estejam disponíveis para uso na interface.
- Garantir que SVGs possam ser renderizados de forma correta.
- Registrar no resumo qualquer divergência entre os assets solicitados no prompt original e os arquivos realmente existentes no projeto.
