<div align="center">

# Simulador OCPP

Interface Flutter para simular um ponto de recarga veicular com comunicação OCPP 1.6J via WebSocket.

![Flutter](https://img.shields.io/badge/Flutter-3.x-439BE2?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OCPP](https://img.shields.io/badge/OCPP-1.6J-A2FF6C?style=for-the-badge)
![Plataformas](https://img.shields.io/badge/Web%20%7C%20Windows-suportado-111827?style=for-the-badge)

</div>

---

## Sobre o projeto

O **Simulador OCPP** é uma aplicação Flutter criada para testar fluxos de recarga veicular contra uma Central System compatível com **OCPP 1.6J**.

Ele permite conectar um carregador simulado por WebSocket, enviar eventos do ciclo de carregamento e acompanhar o console de mensagens em tempo real. O projeto também possui uma tela de login local para isolar o fluxo principal da simulação.

## Funcionalidades

- Login local para ambiente de testes, usando `admin/admin`.
- Alternância entre tema claro e escuro.
- Conexão WebSocket com Central Station OCPP.
- Envio de `BootNotification`.
- Envio de `StatusNotification` para conector `0` e conector principal.
- Autorização de tag com `Authorize`.
- Início e parada de transação com `StartTransaction` e `StopTransaction`.
- Envio manual e periódico de `MeterValues`.
- Envio de `Heartbeat`.
- Pausa e retomada de carregamento.
- Processamento de comandos remotos como `RemoteStartTransaction`, `RemoteStopTransaction`, `Reset`, `GetConfiguration`, `ChangeConfiguration` e `TriggerMessage`.
- Console visual com histórico recente de eventos OCPP.
- Testes unitários para modelos, repositório e ViewModel do carregador.

## Stack

| Camada | Tecnologia |
| --- | --- |
| Interface | Flutter Material |
| Linguagem | Dart |
| Comunicação | `web_socket_channel` |
| Persistência local | `shared_preferences` |
| Estado reativo | Implementação própria com `Rx` e `Obx` |
| Testes | `flutter_test` |

## Arquitetura

O projeto segue uma organização vertical por funcionalidade, mantendo UI, estado, domínio e infraestrutura próximos da feature correspondente.

```txt
lib/
  features/
    carregador/
      data/
      domain/
      presentation/
      services/

    login/
      data/
      domain/
      presentation/
      services/

    simulador/

  observable/
  utils/
  widget/
```

### Principais responsabilidades

- **View**: renderiza a tela e observa estados reativos.
- **ViewModel**: concentra estado da tela, ações do usuário e coordenação dos fluxos.
- **Repository**: adapta os casos de uso da feature para o cliente OCPP.
- **Service**: executa a comunicação WebSocket e regras reutilizáveis.
- **Models**: representam mensagens, enums e contratos OCPP.

## Fluxo OCPP simulado

```txt
Conectar
  -> BootNotification
  -> StatusNotification

Autorizar
  -> Authorize

Iniciar carregamento
  -> StatusNotification: Preparing
  -> StartTransaction
  -> StatusNotification: Charging
  -> MeterValues

Durante a carga
  -> Heartbeat periódico
  -> MeterValues periódico

Parar carregamento
  -> StatusNotification: Finishing
  -> StopTransaction
  -> StatusNotification: Available
```

## Pré-requisitos

- Flutter instalado e configurado.
- Dart compatível com o SDK definido no projeto.
- Central Station OCPP acessível por `ws://` ou `wss://`.

Para conferir o ambiente:

```bash
flutter doctor
```

## Como executar

Instale as dependências:

```bash
flutter pub get
```

Execute no navegador:

```bash
flutter run -d chrome
```

Execute no Windows:

```bash
flutter run -d windows
```

Na tela de login, use:

```txt
Usuário: admin
Senha: admin
```

Por padrão, o simulador sugere a Central Station:

```txt
ws://localhost:5001/OCPP/A
```

Esse endereço pode ser alterado diretamente no campo **Central Station** da tela do carregador.

## Testes e qualidade

Execute os testes:

```bash
flutter test
```

Execute a análise estática:

```bash
flutter analyze
```

Antes de abrir uma alteração, rode os dois comandos para garantir que os contratos principais continuam válidos.

## Estrutura de testes

```txt
test/
  features/
    carregador/
      data/
      domain/
      presentation/
```

Os testes cobrem pontos importantes do carregador:

- Decodificação e serialização de mensagens OCPP.
- Contratos do repositório WebSocket.
- Fluxos da ViewModel, como conexão, boot e início de transação.

## Convenções do projeto

- Preferir mudanças pequenas e localizadas.
- Manter a arquitetura vertical por feature.
- Usar `Rx` e `Obx` para estado observável sempre que fizer sentido.
- Evitar regras de negócio dentro dos widgets.
- Evitar cores hardcoded em widgets de negócio.
- Validar Web, Desktop e Mobile quando a alteração impactar UI.

## Roadmap sugerido

- Integração real de autenticação.
- Suporte a múltiplos carregadores simultâneos.
- Perfis de carga configuráveis.
- Exportação do console OCPP.
- Cenários de falha configuráveis.
- Mais cobertura para comandos remotos do backend.

## Licença

A licença ainda não foi definida. Antes de distribuir ou publicar o projeto para terceiros, adicione um arquivo `LICENSE` compatível com o uso pretendido.

