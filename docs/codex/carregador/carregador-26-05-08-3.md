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
- Implementação de `CarregadoresPage()`
```text
lib/features/carregador/
  carregador.dart
  data/
    repositories/
      carregador_repository_websocket.dart
  domain/
    models/
      mensagem_ocpp.dart
      modelos_carregador.dart
    repositories/
      carregador_repository.dart
  presentation/
    pages/
      carregador_page.dart
    viewmodels/
      carregador_widget_view_model.dart
      carregadores_page_view_model.dart
    widgets/
      carregador_widget.dart
  services/
    carregador_ocpp_client.dart
    carregador_websocket_service.dart 
```

## Objetivo
- Criar a tela `CarregadoresPage()` que listará os carregadores utilizando o widget `CarregadorWidget()`.
- Deve ter um botao de adicionar carregador.
    - Deve aparecer um @file:custom_alert_dialog.dart perguntando a quantidade de conectores (1 ou 2) e o id do carregador.
      - Esse custom_alert_dialog.dart deve ser genérico para poder ser utilizado em outras partes do app, ou seja, deve receber os campos dinamicamente.
    - para 1 conector: @file:carregador_1_conector.svg
    - para 2 conectores: @file:carregador_2_conectores.svg
    - para cada conector deve ter um dropdown para escolher o tipo do conector:
        - @file:conector_CCS2.png 
        - @file:CCS2.png 
        - @file:conector_MENNEKES_type_2.png 
- A tela deve utilizar o `CarregadoresPageViewModel()` para buscar os dados dos carregadores e atualizar a tela.
- Os carregadores criados devem ficar salvos em uma `Storage`
- Tratar os dados salvos na `Storage` como sensíveis, pois este app será buildado na web (pode ser salvar nos coockies seguros).
    - O save dos dados é importante para usos futuros da configuração administrada na tela.
- A page CarregadoresPage() irá mostrar os `.sgv` como botão para abrir em @file:custom_alert_dialog.dart para fins de manipulação/conecxão/start/stop, etc.
