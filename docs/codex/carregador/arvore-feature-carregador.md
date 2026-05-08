# Árvore da feature carregador

## Escopo

Feature analisada: `lib/features/carregador`.

O objetivo deste documento é registrar a estrutura atual da feature e a estrutura esperada após adicionar `CarregadorPage` e `CarregadoresPageViewModel`, mantendo o uso de `CarregadorWidget`.

## Estrutura atual

```txt
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
    viewmodels/
      carregador_widget_view_model.dart
    widgets/
      carregador_widget.dart
  services/
    carregador_ocpp_client.dart
    carregador_websocket_service.dart
```

## Leitura da estrutura atual

- `carregador.dart` funciona como arquivo público de exportação da feature.
- `domain/` concentra os modelos OCPP e o contrato do repositório.
- `data/` contém a implementação WebSocket do repositório.
- `services/` contém a camada técnica de cliente OCPP e comunicação WebSocket.
- `presentation/widgets/carregador_widget.dart` renderiza a interface de um carregador.
- `presentation/viewmodels/carregador_widget_view_model.dart` concentra o estado e os fluxos operacionais usados por `CarregadorWidget`.

## Estrutura proposta

Estrutura esperada após adicionar `CarregadorPage` e `CarregadoresPageViewModel`:

```txt
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

## Papel dos novos arquivos

- `presentation/pages/carregador_page.dart`: deve representar a tela da feature. A responsabilidade dela é montar o layout da página e renderizar os carregadores usando `CarregadorWidget`.
- `presentation/viewmodels/carregadores_page_view_model.dart`: deve concentrar o estado da tela, como lista de carregadores, criação das instâncias de `CarregadorWidgetViewModel` e descarte dos recursos.
- `presentation/widgets/carregador_widget.dart`: deve continuar sendo o componente visual reutilizável de um carregador individual.
- `carregador.dart`: deve passar a exportar também a nova página e a nova view model quando esses arquivos forem implementados.

## Fluxo recomendado

1. `CarregadorPage` cria ou recebe uma instância de `CarregadoresPageViewModel`.
2. `CarregadoresPageViewModel` expõe os carregadores da tela, preferencialmente como estado reativo.
3. `CarregadorPage` observa esse estado via `Obx` e renderiza a lista com `ListView.builder`, `GridView.builder` ou outro builder adequado ao layout.
4. Cada item renderizado usa `CarregadorWidget`, recebendo uma instância específica de `CarregadorWidgetViewModel`.
5. O descarte das view models filhas deve ficar concentrado em `CarregadoresPageViewModel`, evitando que a página contenha regra de ciclo de vida além do necessário.

## Observações arquiteturais

- A página não deve concentrar regra de negócio OCPP.
- O widget existente deve continuar focado em renderizar e acionar sua própria view model.
- A view model da página deve coordenar a coleção de carregadores, não substituir a lógica individual já existente em `CarregadorWidgetViewModel`.
- Se a tela renderizar múltiplos carregadores, a lista deve usar builder para evitar custo desnecessário de renderização.
