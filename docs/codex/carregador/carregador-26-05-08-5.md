# Contexto
Você é um desenvolvedor Senior em dart / Flutter
Leia o resumo do prompt anterior, se houver, e continue a evolução.

## Arquivos
proposta_widget_visualizacao_carregador_1_conector.png
proposta_widget_visualizacao_carregador_2_conectores.png
carregador_1_conector.png
carregador_2_conectores.png
conector_CCS2.png
conector_GBT.png
conector_MENNEKES_type_2.png
## Regras
- vazio

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias

## Entregáveis
2. salvar um resumo da execução com nome datado e sufixo `-resumo`;
3. rodar o script @file:base-prompt-tarefas.md com o [NOME_DA_PASTA] já definido;

# Descrição
- Melhoria de layout da pagina de carregadores

## Objetivo
- Alterar o componente `_ConectorConfiguradoChip(...)` para ficarem iguais a:
    - @file:Group_34.png
    - @file:Group_35.png
    - @file:Group_36.png
    - dependendo do tipo de conector e quantidade de conectores. Repare que o Group_36.png é utilizado para quando é um conector por carregador.
- Em `_CarregadorSvg(...)` Alterar o representacao SVG do carregador por seus equivalentes em png:
    - onde era @file:carregador_1_conector.svg fica @file:carregador_1_conector.png
    - onde era @file:carregador_2_conectores.svg fica @file:carregador_2_conectores.png
- Utilizar as imagens @file:proposta_widget_visualizacao_carregador_1_conector.png e @file:proposta_widget_visualizacao_carregador_2_conectores.png como refencia
- A composição final deve ser em formato de coluna, onde tem a imagem do carregador no topo e logo abaixo, os chips de conectores configurados, como na proposta. O alinhamento deve ser centralizado.