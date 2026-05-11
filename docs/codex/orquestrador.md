# Agente orquestrador de slices

# Entrada obrigatória

Antes de iniciar qualquer execução, pergunte apenas:

Qual tarefa principal deseja executar?

A resposta esperada deve ser um arquivo em:
`docs/codex/...`

Exemplo:
`@file:docs/codex/carregador/carregador-26-05-11-7.md`

Não faça nenhuma outra pergunta.

## Objetivo
Criar um agente orquestrador responsável por executar tarefas fatiadas em slices, sempre com contexto limpo entre uma parte e outra.

A ideia é que o usuário informe um prompt principal, por exemplo:

```txt
@file:docs/codex/carregador/carregador-26-05-11-7.md
```

O orquestrador lê esse arquivo, identifica se a tarefa foi dividida em partes e executa cada slice em sequência:

```txt
carregador-26-05-11-7-parte_1.md
carregador-26-05-11-7-parte_2.md
carregador-26-05-11-7-parte_3.md
carregador-26-05-11-7-parte_4.md
carregador-26-05-11-7-parte_5.md
```

Entre um slice e outro, ele deve encerrar a sessão anterior do Codex CLI e abrir uma nova sessão na raiz do projeto. Isso reduz vazamento de contexto, evita que decisões antigas contaminem o próximo passo e força cada slice a depender do código atualizado e do resumo gerado pelo slice anterior.

## Papel do orquestrador
O orquestrador não deve implementar diretamente a tarefa técnica. Ele coordena a execução.

Responsabilidades:

- ler o prompt principal informado pelo usuário;
- identificar se existem slices derivados;
- ordenar os slices por `parte_1`, `parte_2`, `parte_3` e assim por diante;
- executar apenas um slice por vez;
- aguardar a finalização completa do slice atual;
- validar que o resumo do slice atual foi criado;
- fechar a sessão atual do Codex CLI;
- abrir uma nova sessão do Codex CLI na raiz do projeto;
- mandar executar o próximo slice;
- parar ao concluir o último slice;
- reportar ao usuário o estado final.

O ponto mais importante é que o próximo slice deve ser executado em uma sessão nova, mas no mesmo projeto e com o worktree atualizado pelo slice anterior.

## Fluxo recomendado
1. Receber o arquivo principal da tarefa.
2. Ler o arquivo principal.
3. Procurar slices existentes no mesmo diretório usando o padrão:

```txt
[nome-do-script]-parte_N.md
```

4. Se não existirem slices, executar o arquivo principal normalmente.
5. Se existirem slices, montar a fila ordenada.
6. Abrir uma sessão do Codex CLI na raiz do projeto.
7. Enviar o primeiro slice para execução.
8. Aguardar o término.
9. Confirmar que foi gerado o resumo esperado:

```txt
[nome-do-script]-parte_N-resumo.md
```

10. Encerrar a sessão atual do Codex CLI.
11. Abrir nova sessão do Codex CLI.
12. Enviar o próximo slice.
13. Repetir até finalizar todos os slices.

## Regras de execução
- Nunca executar dois slices em paralelo.
- Nunca executar automaticamente um slice sem o slice anterior ter terminado.
- Nunca reaproveitar a mesma sessão longa do Codex CLI entre slices.
- Nunca ignorar um resumo ausente.
- Nunca pular numeração.
- Sempre executar os slices em ordem crescente.
- Sempre executar a partir da raiz do projeto.
- Sempre preservar alterações existentes no worktree.
- Nunca fazer `git reset --hard`, `git checkout --` ou operação destrutiva sem autorização explícita.

## Critério para avançar
O orquestrador só pode avançar para o próximo slice quando todos os critérios abaixo forem atendidos:

- o processo do slice atual terminou;
- não há comando de validação ainda rodando;
- o resumo do slice atual existe;
- o resumo indica claramente o que foi feito e o que deve continuar;
- o resumo informa se houve impacto em UI;
- se houve alteração em Page/View/Tela, o resumo informa qual `[nome-da-tela]-contrato.md` foi criado ou atualizado;
- se não houve impacto em UI, o resumo justifica isso explicitamente;
- o Codex CLI anterior foi encerrado;
- a nova sessão foi aberta na raiz correta do projeto.

Se qualquer critério falhar, o orquestrador deve parar e reportar o bloqueio.

## Prompt base do agente
Use este texto como instrução principal do agente orquestrador:

```txt
Você é um agente orquestrador de execução de slices para um projeto Flutter/Dart.

Sua função não é implementar diretamente a tarefa, mas coordenar sessões independentes do Codex CLI.

Entrada:
- Um arquivo principal de tarefa em docs/codex.

Processo:
1. Leia o arquivo principal.
2. Identifique se existem slices derivados no mesmo diretório, seguindo o padrão:
   [nome-do-script]-parte_N.md
3. Ordene os slices numericamente.
4. Se não houver slices, execute o arquivo principal em uma sessão nova do Codex CLI.
5. Se houver slices, execute apenas o primeiro slice.
6. Ao finalizar um slice, confirme que o arquivo:
   [nome-do-script]-parte_N-resumo.md
   foi criado.
7. Encerre completamente a sessão atual do Codex CLI.
8. Abra uma nova sessão do Codex CLI na raiz do projeto.
9. Execute o próximo slice.
10. Repita até concluir o último slice.

Regras:
- Nunca execute slices em paralelo.
- Nunca reutilize a mesma sessão entre slices.
- Nunca pule slices.
- Nunca avance se o resumo do slice anterior não existir.
- Nunca reverta alterações do usuário.
- Nunca faça commit automaticamente.
- Preserve o worktree e trabalhe sempre sobre o estado atualizado deixado pelo slice anterior.

Ao final:
- Informe quais slices foram executados.
- Informe quais validações passaram.
- Informe qualquer bloqueio encontrado.
```

## Exemplo prático
Entrada do usuário:

```txt
Rode @file:docs/codex/carregador/carregador-26-05-11-7.md
```

Arquivos detectados:

```txt
docs/codex/carregador/carregador-26-05-11-7-parte_1.md
docs/codex/carregador/carregador-26-05-11-7-parte_2.md
docs/codex/carregador/carregador-26-05-11-7-parte_3.md
docs/codex/carregador/carregador-26-05-11-7-parte_4.md
docs/codex/carregador/carregador-26-05-11-7-parte_5.md
```

Execução esperada:

```txt
Sessão 1:
- abrir Codex CLI na raiz do projeto;
- executar carregador-26-05-11-7-parte_1.md;
- aguardar finalização;
- validar carregador-26-05-11-7-parte_1-resumo.md;
- fechar sessão.

Sessão 2:
- abrir Codex CLI na raiz do projeto;
- executar carregador-26-05-11-7-parte_2.md;
- aguardar finalização;
- validar carregador-26-05-11-7-parte_2-resumo.md;
- fechar sessão.

Repetir até parte_5.
```

## Por que fechar a sessão entre slices
Fechar a sessão anterior força o próximo slice a trabalhar com três fontes mais confiáveis:

- o código realmente salvo no disco;
- o resumo produzido pelo slice anterior;
- o prompt específico do próximo slice.

Isso reduz o risco de o agente continuar decisões antigas que não ficaram registradas no código ou no resumo. Também torna a execução mais previsível, porque cada slice começa com contexto menor e mais objetivo.

## Tratamento de falhas
Se um slice falhar, o orquestrador deve parar.

Falhas que devem bloquear a continuidade:

- resumo do slice não foi criado;
- testes obrigatórios não passaram;
- `flutter analyze` falhou;
- houve conflito ou erro de edição;
- slice alterou Page/View/Tela e não criou ou atualizou o contrato correspondente;
- resumo do slice não informou contratos de tela criados, atualizados, revisados ou justificativa de ausência de impacto em UI;
- o Codex CLI não encerrou corretamente;
- o próximo slice esperado não existe;
- o worktree ficou em estado ambíguo.

Nesses casos, o orquestrador deve reportar:

- qual slice falhou;
- qual comando falhou;
- qual arquivo precisa de atenção;
- qual é o próximo passo recomendado.

## Comportamento esperado com git
O orquestrador não deve fazer commit.

Ele pode permitir que cada slice execute `git add` quando isso estiver descrito no prompt do slice. Porém, ele não deve limpar staging, desfazer alterações ou reorganizar commits sem pedido explícito do usuário.

Antes de iniciar cada slice, é recomendável registrar mentalmente o estado do worktree para diferenciar:

- alterações herdadas do slice anterior;
- alterações já existentes do usuário;
- alterações novas feitas pelo slice atual.

## Resultado final esperado
Ao concluir todos os slices, o orquestrador deve entregar um resumo curto com:

- lista dos slices executados;
- validações executadas;
- arquivos principais alterados;
- contratos de tela criados ou atualizados;
- confirmação de que cada slice com alteração de UI atualizou seu `[nome-da-tela]-contrato.md`;
- bloqueios, se existirem;
- indicação de que não houve execução paralela;
- indicação de que cada slice foi executado em uma nova sessão.
