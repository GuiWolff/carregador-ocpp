# Estrutura do Projeto

Análise gerada em 2026-05-07 para o projeto `simulador_ocpp`.

## Visão geral

O projeto é uma aplicação Flutter chamada `simulador_ocpp`, focada em simular um ponto de recarga usando mensagens OCPP 1.6J via WebSocket.

A estrutura principal já segue uma organização vertical por funcionalidade em `lib/features/`, com as features `login`, `simulador` e `carregador`. Fora das features existe a pasta `lib/observable/`, que funciona como infraestrutura compartilhada para estado reativo com `Rx` e `Obx`.

Dependências principais:

- `flutter`
- `cupertino_icons`
- `web_socket_channel`
- `flutter_lints` em desenvolvimento

## Árvore do projeto

```txt
simulador_ocpp/
├── .github/
├── .idea/                         # Configurações locais da IDE
├── .dart_tool/                    # Gerado pelo Flutter/Dart
├── build/                         # Artefatos de build e testes
├── docs/
│   └── codex/
│       ├── base-prompt-tarefas.md
│       ├── carregador/
│       │   ├── carregador-26-05-07-1.md
│       │   ├── carregador-26-05-07-1-resumo.md
│       │   ├── carregador-26-05-07-2.md
│       │   ├── carregador-26-05-07-2-resumo.md
│       │   └── carregador-26-05-07-3.md
│       ├── login_page/
│       │   ├── login_page-26-05-07-1.md
│       │   ├── login_page-26-05-07-1-resumo.md
│       │   ├── login_page-26-05-07-2.md
│       │   ├── login_page-26-05-07-2-resumo.md
│       │   └── login_page-26-05-07-3.md
│       ├── servico_ocpp/
│       │   ├── servico_ocpp-26-05-07-1.md
│       │   ├── servico_ocpp-26-05-07-1-resumo.md
│       │   └── servico_ocpp-26-05-07-2.md
│       └── estrutura-projeto.md
├── lib/
│   ├── main.dart
│   ├── observable/
│   │   ├── I_rx_subscribe.dart
│   │   ├── obx.dart
│   │   ├── rx.dart
│   │   └── rx_observer.dart
│   └── features/
│       ├── simulador/
│       │   └── simulador_home_page.dart
│       ├── login/
│       │   ├── login_page.dart
│       │   ├── presentation/
│       │   │   ├── pages/
│       │   │   │   └── login_page.dart
│       │   │   └── viewmodels/
│       │   │       └── login_view_model.dart
│       │   ├── domain/
│       │   │   ├── models/
│       │   │   │   └── login_credenciais.dart
│       │   │   └── repositories/
│       │   │       └── login_repository.dart
│       │   ├── data/
│       │   │   └── repositories/
│       │   │       └── login_repository_local.dart
│       │   └── services/
│       │       └── login_service.dart
│       └── carregador/
│           ├── carregador.dart
│           ├── presentation/
│           │   ├── widgets/
│           │   │   └── carregador_widget.dart
│           │   └── viewmodels/
│           │       └── carregador_widget_view_model.dart
│           ├── domain/
│           │   ├── models/
│           │   │   ├── mensagem_ocpp.dart
│           │   │   └── modelos_carregador.dart
│           │   └── repositories/
│           │       └── carregador_repository.dart
│           ├── data/
│           │   └── repositories/
│           │       └── carregador_repository_websocket.dart
│           └── services/
│               ├── carregador_ocpp_client.dart
│               └── carregador_websocket_service.dart
├── resources/
│   ├── ChargerSimulator.html
│   └── plugin-redoc-1.yaml
├── test/
│   ├── widget_test.dart
│   └── features/
│       └── carregador/
│           ├── data/
│           │   └── repositories/
│           │       └── carregador_repository_websocket_test.dart
│           ├── domain/
│           │   └── models/
│           │       └── mensagem_ocpp_test.dart
│           └── presentation/
│               └── viewmodels/
│                   └── carregador_widget_view_model_test.dart
├── web/
│   ├── favicon.png
│   ├── index.html
│   ├── manifest.json
│   └── icons/
│       ├── Icon-192.png
│       ├── Icon-512.png
│       ├── Icon-maskable-192.png
│       └── Icon-maskable-512.png
├── windows/
│   ├── CMakeLists.txt
│   ├── flutter/
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   └── runner/
│       ├── CMakeLists.txt
│       ├── Runner.rc
│       ├── flutter_window.cpp
│       ├── flutter_window.h
│       ├── main.cpp
│       ├── resource.h
│       ├── runner.exe.manifest
│       ├── utils.cpp
│       ├── utils.h
│       ├── win32_window.cpp
│       ├── win32_window.h
│       └── resources/
│           └── app_icon.ico
├── .gitignore
├── .metadata
├── AGENTS.md
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── simulador_ocpp.iml
```

## Pontos de entrada

### `lib/main.dart`

Responsável por inicializar a aplicação com `runApp(const MyApp())`.

O `MaterialApp` define:

- título `Simulador OCPP`;
- `debugShowCheckedModeBanner: false`;
- tema Material 3 com `ColorScheme.fromSeed`;
- `home: const LoginPage()`.

Ponto de atenção: o arquivo importa `features/login/login_page.dart` e também `features/login/presentation/pages/login_page.dart`. Como o primeiro já exporta o segundo, basta manter um caminho de importação para reduzir ambiguidade.

### `lib/features/simulador/simulador_home_page.dart`

Tela inicial após login. Ela monta o layout base do simulador e renderiza `CarregadorWidget`.

O papel dessa tela é de composição: ela não concentra regra de negócio do carregador.

## Organização por camadas

### `presentation`

Camada de interface. Contém páginas, widgets e viewmodels usados pela tela.

No projeto atual:

- `login/presentation/pages/login_page.dart` renderiza a tela de autenticação;
- `login/presentation/viewmodels/login_view_model.dart` controla estado da tela de login;
- `carregador/presentation/widgets/carregador_widget.dart` renderiza painel, métricas, parâmetros, ações e console;
- `carregador/presentation/viewmodels/carregador_widget_view_model.dart` coordena o estado e o fluxo do carregador.

### `domain`

Camada de contrato e modelo de negócio.

No projeto atual:

- `login/domain/models/login_credenciais.dart` representa credenciais normalizadas;
- `login/domain/repositories/login_repository.dart` define o contrato de autenticação;
- `carregador/domain/models/mensagem_ocpp.dart` representa mensagens OCPP;
- `carregador/domain/models/modelos_carregador.dart` reúne enums e valores medidos do OCPP;
- `carregador/domain/repositories/carregador_repository.dart` define as operações esperadas para comunicação OCPP.

### `data`

Camada de implementação de acesso externo ou persistência.

No projeto atual:

- `login/data/repositories/login_repository_local.dart` autentica localmente `admin/admin`;
- `carregador/data/repositories/carregador_repository_websocket.dart` implementa `CarregadorRepository` usando um cliente OCPP WebSocket.

### `services`

Camada de regras e serviços reutilizáveis dentro da feature.

No projeto atual:

- `login/services/login_service.dart` valida credenciais e coordena autenticação;
- `carregador/services/carregador_ocpp_client.dart` define o contrato do cliente OCPP;
- `carregador/services/carregador_websocket_service.dart` implementa conexão, envio, recebimento, resposta e tratamento de mensagens WebSocket.

## Fluxos principais

### Fluxo de login

```txt
main.dart
└── LoginPage
    └── LoginViewModel
        └── LoginService
            └── LoginRepository
                └── LoginRepositoryLocal
```

Comportamento:

- `LoginPage` coleta usuário e senha;
- `LoginViewModel` expõe estado reativo de carregamento, erro e visibilidade de senha;
- `LoginService` normaliza e valida as credenciais;
- `LoginRepositoryLocal` valida `admin/admin`;
- em caso de sucesso, a navegação usa `pushReplacement` para `SimuladorHomePage`.

### Fluxo do carregador OCPP

```txt
SimuladorHomePage
└── CarregadorWidget
    └── CarregadorWidgetViewModel
        └── CarregadorRepository
            └── CarregadorRepositoryWebSocket
                └── CarregadorOcppClient
                    └── CarregadorWebSocketService
                        └── WebSocket OCPP 1.6J
```

Comportamento:

- `CarregadorWidget` renderiza a experiência visual e encaminha ações para o viewmodel;
- `CarregadorWidgetViewModel` mantém estado reativo, timers, conexão, transação, medições e eventos;
- `CarregadorRepositoryWebSocket` transforma operações de alto nível em chamadas OCPP;
- `CarregadorWebSocketService` gerencia o canal WebSocket, mensagens pendentes, chamadas recebidas e respostas.

## Estado reativo

A pasta `lib/observable/` implementa um mecanismo próprio de estado reativo:

- `Rx<T>` armazena valor, listeners e observadores;
- `Obx` reconstrói widgets quando os `Rx` lidos durante o build mudam;
- `RxDependencyTracker` registra dependências de forma automática;
- `RxSubscription` permite assinar mudanças específicas e descartar assinaturas.

Esse padrão evita `setState` espalhado pela tela. O `setState` fica encapsulado dentro de `Obx`, enquanto controllers e widgets observam valores reativos.

## Testes

Os testes existentes cobrem:

- navegação básica após login local;
- erro de credenciais inválidas;
- parse e serialização de mensagens OCPP;
- repository WebSocket do carregador com cliente falso;
- fluxos do `CarregadorWidgetViewModel`.

Estrutura atual:

```txt
test/
├── widget_test.dart
└── features/
    └── carregador/
        ├── data/repositories/carregador_repository_websocket_test.dart
        ├── domain/models/mensagem_ocpp_test.dart
        └── presentation/viewmodels/carregador_widget_view_model_test.dart
```

O padrão mais saudável é continuar espelhando a estrutura de `lib/features/` dentro de `test/features/`.

## Arquivos grandes

Arquivos com maior número de linhas em `lib/`:

| Arquivo | Linhas | Observação |
| --- | ---: | --- |
| `lib/features/carregador/presentation/widgets/carregador_widget.dart` | 891 | Concentra vários widgets privados. Candidato a quebra gradual em arquivos menores dentro de `presentation/widgets/`. |
| `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart` | 743 | Concentra bastante coordenação de fluxo OCPP, timers e estado. Se crescer, pode extrair serviços internos da feature. |
| `lib/features/login/presentation/pages/login_page.dart` | 396 | Ainda aceitável, mas já possui widgets privados que podem virar arquivos próprios se a tela evoluir. |
| `lib/features/carregador/services/carregador_websocket_service.dart` | 295 | Serviço técnico com responsabilidade clara de WebSocket/OCPP. |
| `lib/features/carregador/data/repositories/carregador_repository_websocket.dart` | 279 | Mapeia contratos de repositório para chamadas OCPP. |

## Convenções observadas

- Arquitetura vertical por feature em `lib/features/`.
- Barrel files para facilitar imports:
    - `lib/features/login/login_page.dart`;
    - `lib/features/carregador/carregador.dart`.
- ViewModels concentram estado de tela e coordenação de fluxos.
- Repositories definem contratos no `domain` e implementações no `data`.
- Serviços ficam dentro da feature, não em uma pasta global horizontal.
- Estado reativo é feito com `Rx` e observado com `Obx`.

## Pontos de atenção para evolução

- Evitar criar pastas horizontais globais como `lib/views`, `lib/services`, `lib/repositories` ou `lib/models`.
- Para novas telas, criar ou reutilizar a feature correspondente em `lib/features/nome_da_feature/`.
- Para novos testes, espelhar a feature em `test/features/nome_da_feature/`.
- Reduzir gradualmente arquivos acima de 500 linhas quando houver mudança real na área.
- Preferir imports por barrel file quando a feature já oferece um export público.
- Manter regras de negócio fora dos widgets. A tela deve renderizar; o ViewModel deve coordenar estado e fluxo.
- Manter `build/`, `.dart_tool/` e arquivos efêmeros de plataforma fora da análise arquitetural.

## Estrutura recomendada para novas features

```txt
lib/features/nome_da_feature/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── viewmodels/
├── domain/
│   ├── models/
│   └── repositories/
├── data/
│   ├── repositories/
│   ├── datasources/
│   └── dtos/
└── services/
```

Use essa estrutura apenas quando a feature realmente precisar das camadas. Para funcionalidades pequenas, é melhor começar simples e crescer sem criar pastas vazias.
