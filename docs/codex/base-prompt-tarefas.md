Este prompt deve funcionar como gerador de prompts mestres de tarefa para o Codex.

O objetivo não é implementar a tarefa solicitada.
O objetivo é transformar o pedido do usuário em arquivos de planejamento e execução bem estruturados, capazes de serem executados diretamente ou fatiados em slices sequenciais.

## Regras de execução deste gerador

- Não execute a implementação da tarefa.
- Não altere arquivos reais do projeto, exceto arquivos de prompt, análise, resumo e contratos de tela necessários ao planejamento.
- Não faça commit.
- Preserve alterações existentes no worktree.
- Não use operações destrutivas como `git reset --hard`, `git checkout --` ou limpeza de arquivos sem autorização explícita.

## Entrada obrigatória

A única interação permitida antes de iniciar é perguntar:

1. `[NOME_DA_PASTA]`
2. Qual tarefa deseja realizar e em qual parte do projeto?

Não faça nenhuma outra pergunta.

## Local e nome dos arquivos

Com base no `[NOME_DA_PASTA]`, defina o diretório de saída como:

```txt
docs/codex/[NOME_DA_PASTA]
```

Defina o `[NOME_DO_SCRIPT]` usando a data atual no formato:

```txt
[NOME_DA_PASTA]-yy-MM-dd-n
```

Quando este prompt for executado a partir de um arquivo de tarefa já datado, o próximo script deve usar o mesmo padrão do arquivo atual e incrementar somente o último número em `+1`.

Não pule numeração por causa de outros arquivos existentes no diretório.
Não explique essa lógica ao usuário; apenas aplique.

## Fluxo obrigatório

Antes de criar qualquer prompt mestre ou slice, execute uma análise local do projeto em torno da tarefa informada.

A análise deve identificar:

- feature correspondente, seguindo a arquitetura vertical feature-first;
- arquivos, telas, widgets, ViewModels, controllers, services, repositories, models e testes relacionados;
- estado atual da implementação;
- comportamento esperado após a tarefa;
- riscos técnicos;
- dependências entre etapas;
- pontos de compatibilidade com código legado;
- contratos públicos que não devem ser quebrados;
- telas modificadas ou impactadas;
- contratos de tela existentes que devem ser lidos antes da alteração;
- contratos de tela que precisam ser criados, atualizados ou revisados;
- justificativa explícita quando não houver impacto em UI;
- validações necessárias, incluindo testes específicos e `flutter analyze`;
- se a tarefa deve ou não ser dividida em slices.

Salve a análise em:

```txt
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-analise.md
```

Depois da análise, gere sempre um prompt mestre:

```txt
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT].md
```

Se a análise indicar que a tarefa precisa ser fatiada, gere também os slices:

```txt
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_1.md
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_2.md
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_3.md
```

Crie quantas partes forem necessárias, mantendo cada slice pequeno, coeso e incremental.

Gere também o resumo geral da tarefa:

```txt
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-resumo.md
```

O resumo geral deve registrar:

- tarefa solicitada;
- arquivos de prompt criados;
- lista de slices, se existirem;
- ordem correta de execução;
- validações esperadas;
- contratos de tela criados, atualizados ou revisados;
- observações importantes para continuidade.

## Contratos de tela

Para cada Page/View/Tela criada, modificada ou impactada, crie, revise ou atualize um arquivo seguindo obrigatoriamente o padrão:

```txt
[nome-da-tela]-contrato.md
```

O contrato da tela deve ficar junto da tela correspondente, preferencialmente na mesma pasta da Page/View.

Exemplo:

```txt
lib/features/carregadores/presentation/pages/carregadores_page.dart
lib/features/carregadores/presentation/pages/carregadores_page-contrato.md
```

Regras obrigatórias:

- Toda Page/View/Tela criada deve ter seu contrato criado.
- Toda Page/View/Tela modificada deve ter seu contrato atualizado.
- Toda Page/View/Tela impactada indiretamente deve ter seu contrato revisado e atualizado quando necessário.
- Nenhum prompt mestre ou slice que altere UI deve ser considerado completo sem criar ou atualizar o contrato correspondente.
- Quando não houver impacto em UI, o prompt deve informar claramente que não há contrato de tela a criar ou atualizar.

O `[nome-da-tela]-contrato.md` deve conter:

- nome da tela;
- objetivo da tela;
- estado atual da tela;
- estado esperado após a tarefa;
- estados visuais possíveis;
- dados necessários para renderização;
- ações do usuário disponíveis;
- regras de interação;
- dependências da tela;
- widgets principais;
- ViewModel/Controller relacionado, se houver;
- pontos que cada slice precisa preservar;
- pendências conhecidas;
- continuidade esperada para os próximos slices.

Não crie contrato de tela quando a tarefa não impactar UI.

## Como decidir se haverá slices

Use slices quando a tarefa tiver pelo menos uma destas características:

- altera múltiplas responsabilidades, como ViewModel, UI e testes;
- envolve fluxo transacional, estado reativo, timers ou integração com repository/service;
- afeta mais de uma tela ou componente principal;
- exige migração incremental para preservar comportamento existente;
- tem risco de regressão alto;
- precisa de validações intermediárias para reduzir incerteza.

Não use slices quando a tarefa for pequena, localizada e validável em uma única execução.

## Regras para prompts mestres

O prompt mestre deve ser útil mesmo quando existirem slices.
Ele não pode ser apenas um texto dizendo para gerar slices.

Quando houver slices, o prompt mestre deve conter:

- contexto técnico da tarefa;
- objetivo geral;
- arquivos principais envolvidos;
- análise resumida;
- contratos de tela relacionados;
- lista completa dos slices;
- atividades de cada slice;
- arquivo de resumo esperado para cada slice;
- validações esperadas por slice;
- regras gerais de execução sequencial;
- instrução para não repetir slice já concluído quando o resumo correspondente existir e estiver válido;
- resultado final esperado.

Quando não houver slices, o prompt mestre deve conter:

- contexto técnico;
- arquivos envolvidos;
- contratos de tela relacionados, usando o padrão `[nome-da-tela]-contrato.md`, ou justificativa de ausência de impacto em UI;
- regras;
- restrições;
- entregáveis;
- validações obrigatórias;
- caminho do resumo final a ser criado.

## Regras para slices

Cada slice deve:

- executar apenas uma etapa coesa e incremental;
- assumir continuidade do slice anterior;
- ler o resumo do slice anterior, quando houver;
- referenciar o arquivo de análise;
- referenciar o prompt mestre;
- listar apenas os arquivos necessários para aquele slice;
- listar contratos de tela relacionados, usando o padrão `[nome-da-tela]-contrato.md`;
- preservar APIs públicas e comportamento existente, salvo quando a tarefa exigir explicitamente mudança;
- evitar refatorações fora do escopo;
- declarar claramente o que não deve ser alterado naquele slice;
- exigir validações específicas;
- criar seu próprio resumo ao final.

Cada slice deve salvar seu resumo em:

```txt
docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_N-resumo.md
```

O resumo do slice deve conter:

- o que foi feito;
- arquivos alterados;
- contratos de tela criados, atualizados ou revisados, ou justificativa de ausência de impacto em UI;
- validações executadas;
- resultado das validações;
- pendências;
- próximo slice sugerido, se existir;
- pontos de atenção para continuidade.

## Regras gerais para os prompts gerados

- Usar português pt-BR.
- Manter UTF-8.
- Não reescrever arquivos inteiros sem necessidade.
- Preservar padrões já existentes no projeto.
- Não alterar APIs públicas sem necessidade.
- Não remover código legado sem confirmação explícita.
- Preferir mudanças pequenas e localizadas.
- Evitar criar arquivos desnecessários.
- Em Flutter, preferir estado reativo do projeto a `setState`, quando aplicável.
- Controllers/ViewModels não devem acessar contexto da UI.
- Widgets grandes devem ser quebrados quando a tarefa exigir alteração substancial.
- Listas devem usar builder quando houver risco de crescimento.
- Rodar `flutter analyze` antes de finalizar slices de código.
- Rodar testes específicos relacionados à alteração.
- Rodar `flutter test` no fechamento quando o impacto for amplo.
- Não executar automaticamente o próximo slice.
- Não manter múltiplos slices executando simultaneamente.
- Não fazer commit.

## Ações finais deste gerador

Após gerar ou atualizar os arquivos necessários:

1. Adicione ao git apenas os arquivos de planejamento criados ou atualizados por este gerador:

```txt
git add docs/codex/[NOME_DA_PASTA]/...
```

2. Se contratos de tela forem criados, atualizados ou revisados, adicione também esses arquivos ao git.
3. Não faça commit.
4. Informe ao usuário:
   - prompt mestre criado;
   - slices criados, se houver;
   - análise criada;
   - contratos criados, atualizados ou revisados;
   - qual arquivo deve ser executado primeiro.

## Template do arquivo de análise

Use este formato para `[NOME_DO_SCRIPT]-analise.md`:

```md
# Análise da tarefa

## Pedido original
- Descreva o pedido do usuário de forma objetiva.

## Feature correspondente
- Informe a feature e o caminho provável.

## Arquivos relacionados
- Liste arquivos de produção e testes relevantes.

## Estado atual
- Explique como o fluxo funciona hoje.

## Estado esperado
- Explique como o fluxo deve funcionar após a tarefa.

## Riscos e dependências
- Liste riscos técnicos, dependências e pontos que exigem cuidado.

## Contratos de tela
- Liste contratos existentes que devem ser lidos antes da alteração.
- Liste contratos que precisam ser criados.
- Liste contratos que precisam ser atualizados.
- Quando não houver impacto em UI, justifique explicitamente por que não há contrato de tela a criar ou atualizar.

## Estratégia
- Explique a estratégia incremental.

## Decisão sobre slices
- Informe se haverá slices e por quê.

## Validações recomendadas
- Liste comandos de análise e testes.
```

## Template do prompt mestre com slices

Use este formato quando a tarefa for fatiada:

```md
# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia a análise desta tarefa antes de executar qualquer alteração.
Esta tarefa foi dividida em [TOTAL] slices.

## Análise da tarefa
- `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-analise.md`

## Objetivo geral
- Descreva o objetivo final da tarefa.

## Arquivos principais envolvidos
- Liste arquivos principais de produção e teste.

## Contratos de tela
- Liste contratos relacionados, usando o padrão `[nome-da-tela]-contrato.md`.
- Informe contratos existentes que devem ser lidos antes da alteração.
- Informe contratos que cada slice deve criar, atualizar ou revisar.
- Quando não houver impacto em UI, justifique explicitamente por que não há contrato de tela a criar ou atualizar.

## Slices da tarefa

### Slice 1/[TOTAL] - [Nome curto]
Arquivo: `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_1.md`
Resumo esperado: `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_1-resumo.md`

Atividades:
1. [Atividade objetiva]
2. [Atividade objetiva]

Validações:
- `[comando]`

### Slice 2/[TOTAL] - [Nome curto]
Arquivo: `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_2.md`
Resumo esperado: `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_2-resumo.md`

Atividades:
1. [Atividade objetiva]
2. [Atividade objetiva]

Validações:
- `[comando]`

## Regras gerais
- Executar apenas um slice por vez.
- Nunca executar slices em paralelo.
- Nunca avançar para o próximo slice sem o resumo do slice atual.
- Se um resumo de slice já existir e estiver válido, não repetir esse slice.
- Cada slice deve considerar o estado atualizado do código produzido pelo slice anterior.
- Cada slice que alterar UI deve criar ou atualizar o respectivo `[nome-da-tela]-contrato.md`.
- Preservar alterações existentes no worktree.
- Não fazer commit automaticamente.

## Resultado esperado
- Descreva o comportamento final esperado após todos os slices.
```

## Template do prompt mestre sem slices

Use este formato quando a tarefa não precisar ser fatiada:

```md
# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia a análise desta tarefa antes de executar qualquer alteração.

## Análise da tarefa
- `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-analise.md`

## Arquivos
- Liste arquivos envolvidos.

## Contratos de tela
- Liste contratos relacionados, usando o padrão `[nome-da-tela]-contrato.md`.
- Informe contratos existentes que devem ser lidos antes da alteração.
- Informe contratos que precisam ser criados, atualizados ou revisados.
- Quando não houver impacto em UI, justifique explicitamente por que não há contrato de tela a criar ou atualizar.

## Regras
- Liste regras específicas da tarefa.

## Restrições
- Não reescreva arquivos inteiros sem necessidade.
- Não faça commit.
- Liste restrições específicas da tarefa.

## Entregáveis
1. [Entregável objetivo]
2. Criar ou atualizar `[nome-da-tela]-contrato.md` quando houver alteração em Page/View/Tela.
3. Registrar no resumo final quais contratos de tela foram criados ou atualizados.
4. Rodar `flutter analyze`, quando houver alteração em Dart/Flutter.
5. Rodar testes específicos relacionados.
6. Salvar resumo em `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-resumo.md`.

# Descrição
- Descreva a tarefa.

## Objetivo
- Descreva o resultado esperado.
```

## Template de slice

Use este formato para cada `[NOME_DO_SCRIPT]-parte_N.md`:

```md
# Contexto
Você é um desenvolvedor Senior em Dart / Flutter.
Leia a análise da tarefa e o resumo do slice anterior, se houver.
Este é o slice N/[TOTAL] derivado de `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT].md`.

## Análise da tarefa
- `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-analise.md`

## Continuidade
- Slice anterior: `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_[N-1]-resumo.md`
- Se este for o primeiro slice, informe que não há resumo anterior.

## Arquivos
- Liste somente os arquivos necessários para este slice.

## Contratos de tela
- Liste contratos relacionados, usando o padrão `[nome-da-tela]-contrato.md`.
- Informe contratos existentes que devem ser lidos antes da alteração.
- Informe contratos que este slice deve criar, atualizar ou revisar.
- Quando o slice não impactar UI, justifique explicitamente por que não há contrato de tela a criar ou atualizar.

## Regras
- Liste regras específicas deste slice.

## Restrições
- Não reescreva arquivos inteiros sem necessidade.
- Não misture etapas de outros slices.
- Não execute automaticamente o próximo slice.
- Não faça commit.

## Entregáveis
1. [Entregável objetivo]
2. [Entregável objetivo]
3. Criar ou atualizar `[nome-da-tela]-contrato.md` quando houver alteração em Page/View/Tela.
4. Registrar no resumo do slice quais contratos de tela foram criados, atualizados ou revisados.
5. Justificar explicitamente no resumo do slice quando não houver impacto em UI.
6. Rodar validações específicas.
7. Salvar resumo em `docs/codex/[NOME_DA_PASTA]/[NOME_DO_SCRIPT]-parte_N-resumo.md`.

# Descrição
- Descreva a etapa deste slice.

## Objetivo
- Descreva o resultado esperado ao final deste slice.
```
