# Contexto
Você é um desenvolvedor Senior em dart / Flutter
Leia o resumo do prompt anterior, se houver, e continue a evolução.

## Arquivos
Insira a referencia, exemplo: `path/to/file.ext` ou `@thisFile` para referenciar o arquivo atual.

## Regras
- vazio

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias

## Entregáveis
1. Se necessário, quere o Script em slices menores com base na quantidade de alterações necessárias, mas sempre seguindo a mesma lógica de nomeação e numeração, com `[NOME_DA_PASTA]-yy-MM-dd-n-parte_1` ... `parte_2` até a parte necessária.
2. salvar um resumo da execução com nome datado e sufixo `-resumo`;
3. rodar o script @file:base-prompt-tarefas.md com o [NOME_DA_PASTA] já definido;
4. Se este prompt fazer parte de Slices, abra um novo terminal, entre na pasta do projeto e rode o proximo slice. Após iniciar o próximo slice, encerre este terminal, para evitar conflitos de código. Repita isso para cada slice necessário.

# Descrição
- `_CarregadorBotaoDetalhes()` está vazio, refatore para eliminar este código.
```dart
class _CarregadorBotaoDetalhes extends StatelessWidget {
  const _CarregadorBotaoDetalhes({
    required this.carregadorId,
    required this.estadoVisual,
  });

  final String carregadorId;
  final _EstadoVisualCarregador estadoVisual;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        /* Align(
          alignment: Alignment.centerLeft,
          child: _EstadoCarregadorChip(
            estado: estadoVisual.estado,
            ocupado: estadoVisual.ocupado,
            corEstado: estadoVisual.corEstado,
          ),
        ),
        const SizedBox(height: 12),
        _DisplayCarregador(
          key: ValueKey<String>('carregador_display_$carregadorId'),
          estadoVisual: estadoVisual,
        ),*/
      ],
    );
  }
}
```
- Escreva `_CarregandoCarregadores` em @file:custom_circular_progress_bar.dart
```dart
class _CarregandoCarregadores extends StatelessWidget {
  const _CarregandoCarregadores();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(
        color: cores.primary,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
```

## Objetivo
- em branco
