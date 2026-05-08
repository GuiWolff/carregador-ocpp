# Contexto
Você é um desenvolvedor Senior em dart / Flutter
Leia o resumo do prompt anterior, se houver, e continue a evolução.

## Arquivos
@file:resources/ChargerSimulator.html

## Regras
- em branco

## Restrições
- Não reescreva os arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias

## Entregáveis
2. salvar um resumo da execução com nome datado e sufixo `-resumo`;
3. rodar o script @file:base-prompt-tarefas.md com o [NOME_DA_PASTA] já definido;

# Descrição
- Criar widget de carregador para o simulador de carro eletrico, utilizando o @file:servico_ocpp_websocket.dart em um controller desse widget
- Analise @file:ChargerSimulator.html para fazer o widget
- Futuramente terá um simulador de estacionamento do carros elétrico utilizando varias instancias desse carregador

## Objetivo
- Crie um widget simulador de carregador de carro elétrico, utilizando o serviço de comunicação com o backend via OCPP implementado no arquivo @file:servico_ocpp_websocket.dart. 
- Este widget deve ser capaz de se conectar ao backend, enviar e receber mensagens seguindo o protocolo OCPP 1.6J, e exibir informações relevantes sobre o status do carregamento, como tempo restante, energia fornecida, e estado da conexão. O widget deve ser projetado para ser reutilizável e facilmente integrável em um simulador de estacionamento para carros elétricos, onde várias instâncias desse carregador podem ser utilizadas para simular diferentes pontos de carregamento.
- Crie um controller para o widget `CarregadorWidget()` e `CarregadorWidgetController()` para gerenciar a lógica de comunicação com o backend e o estado do widget, garantindo uma arquitetura limpa e modular. O controller deve ser responsável por estabelecer a conexão via websocket, enviar comandos de carregamento, receber atualizações do status do carregamento, e fornecer métodos para iniciar, pausar e parar o carregamento. O widget deve se inscrever nas mudanças de estado do controller para atualizar a interface do usuário em tempo real com as informações mais recentes sobre o processo de carregamento.
