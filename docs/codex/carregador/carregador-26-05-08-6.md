# Contexto
Você é um desenvolvedor Senior em dart / Flutter
Leia o resumo do prompt anterior, se houver, e continue a evolução.

## Arquivos
@file:carregador_page.dart

## Regras
- Mantenha as edições que fiz manualmente

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias

## Entregáveis
2. salvar um resumo da execução com nome datado e sufixo `-resumo`;
3. rodar o script @file:base-prompt-tarefas.md com o [NOME_DA_PASTA] já definido;

# Descrição
- Melhorias para os conectores

## Objetivo
- `_ConectorConfiguradoChip` não deve ter borda e fundo azul claro, Devem ter uma cor neutra
- A disposição dos carregadores na page `CarregadorPade()` deve ser com estilo grid, de modo que caiba até 4 carregadores por linha em casos de monitores bem largos
    - Mínimo 1 Carregador por linha, máximo, 4 por linha, dependendo da largura disponível
- Botão de deletar o carregador deve ir no canto superior esquerdo do widget de apresentação do carregador
- O código de status do carregador deve ser simulado dentro da tela do carregador (visualmente falando):
    - Disponivel, Desconectador, etc...
```dart
Align(
alignment: .topCenter,
child: Container(
margin: .only(top: 10),
color: Colors.green,
width: 122,
alignment: .center,
child: Text("Disponível"),
)
/*_EstadoCarregadorChip(
            estado: EstadoCarregador.disponivel,
            ocupado: false,
            corEstado: Colors.green,
          ),*/
), 
```
