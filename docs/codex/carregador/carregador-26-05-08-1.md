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
2. salvar um resumo da execução com nome datado e sufixo `-resumo`;
3. rodar o script @file:base-prompt-tarefas.md com o [NOME_DA_PASTA] já definido;

# Descrição
Melhorias para o layout.
O Dropdrown não está alterando as cores para o tema escuro
```dart
DropdownButtonFormField<StatusConectorOcpp>(
  key: const Key('carregador_status'),
  initialValue: viewModel.statusConector.value,
  isExpanded: true,
  decoration: _decoracaoFormulario(
    hintText: 'Connector Status',
    prefixIcon: Icons.sensors,
  ),
  items: StatusConectorOcpp.values
      .map(
        (status) => DropdownMenuItem<StatusConectorOcpp>(
          value: status,
          child: Text(status.valor),
        ),
      )
      .toList(growable: false),
  onChanged: ocupado
      ? null
      : (status) {
          if (status == null) {
            return;
          }

          unawaited(viewModel.alterarStatus(status));
        },
),
```


## Objetivo
- Altere o código do dropdown para que ele altere as cores de acordo com o tema, utilizando as cores presentes no design do figma: https://www.figma.com/design/mjOuPyTkfIQmfwp2268vtu/EVOLTBR-APP-DESIGN?node-id=0-1&p=f&t=INH17HFLc7bBwyVh-0
- Após a alteração reescreva ele em @filecustom_dropdown.dart
- Após a alteração, altere o código do dropdown presente em @file:carregador.dart para utilizar o novo componente customizado.
