# Contexto
Você é um desenvolvedor Senior em dart / Flutter
Leia o resumo do prompt anterior, se houver, e continue a evolução.

## Arquivos
@file:carregador_page.dart


## Regras
- vazio

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias

## Entregáveis
1. Avalie a complexidade da tarefa e, se necessário, divida o trabalho em múltiplos slices.
2. Quando houver divisão em slices:
    - Gere primeiro a lista completa dos slices necessários;
    - Utilize a mesma lógica de nomenclatura e numeração:
      `[NOME_DO_SCRIPT]-parte_1`, `parte_2`, `parte_3`...
    - Cada slice deve conter apenas uma etapa coesa e incremental da implementação.
3. Nunca misture múltiplas grandes alterações no mesmo slice.
4. Cada slice deve assumir continuidade do slice anterior.
5. Gere também um arquivo de resumo com o mesmo padrão de nomenclatura, utilizando o sufixo `-resumo`.
6. Ao finalizar um slice:
    - Oriente a continuidade para o próximo slice, se existir;
    - Nunca executar automaticamente o próximo slice;
    - Nunca manter múltiplos slices executando simultaneamente.
7. O próximo slice sempre deve considerar o estado atualizado do código produzido pelo slice anterior.
8. Após gerar os arquivos necessários, adicionar os prompts criados ao git utilizando `git add`, sem realizar commit.
9. Executar o script `@file:base-prompt-tarefas.md` utilizando o `[NOME_DA_PASTA]` definido.

# Descrição
A temperatura fica estática. Trate ela com valores flutuantes, para que o carregador pareça mais realista.
```dart
SizedBox(
  width: larguraItem,
  child: _DisplayCarregadorCampo(
    item: item,
    corIcone: cores.primary,
    estiloRotulo: tema.textTheme.labelSmall?.copyWith(
      color: cores.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    ),
    estiloValor: tema.textTheme.labelLarge?.copyWith(
      color: cores.onSurface,
      fontWeight: FontWeight.w900,
    ),
  ),
)
```


## Objetivo
- em branco
