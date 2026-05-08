# Contexto
Você é um desenvolvedor Senior em dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolução.
Este é o slice 2/9 derivado de @file:carregador-26-05-08-3.md.

## Arquivos
- @file:carregador-26-05-08-3-parte_1-resumo.md
- `lib/features/carregador/domain/models/modelos_carregador.dart`
- `test/features/carregador/domain/models/`

## Regras
- Trabalhar apenas nos modelos de domínio necessários para representar carregadores configurados na tela.
- Manter o domínio livre de `BuildContext`, `Widget`, `Color` e qualquer código visual.
- Não alterar enums OCPP existentes, exceto se for estritamente necessário e sem quebrar compatibilidade.

## Restrições
- Não reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessárias.
- Não implementar armazenamento, diálogo, página ou view model neste slice.
- Não colocar paths de assets dentro do domínio se isso puder ficar na camada de apresentação.

## Entregáveis
1. Criar os modelos necessários para configuração de carregadores, por exemplo:
   - tipo de conector suportado;
   - conector configurado;
   - carregador configurado com id e lista de conectores.
2. Implementar serialização e desserialização JSON dos modelos.
3. Validar regras mínimas:
   - id do carregador não pode ser vazio;
   - quantidade de conectores deve ser 1 ou 2;
   - cada conector precisa ter tipo definido.
4. Criar ou ajustar testes unitários para os modelos.
5. Rodar `flutter analyze`.
6. Salvar um resumo da execução em `docs/codex/carregador/carregador-26-05-08-3-parte_2-resumo.md`.

# Descrição
- Modelagem de domínio para os carregadores criados pela tela `CarregadoresPage`.

## Objetivo
- Ter uma representação estável e testada da configuração de carregadores antes de implementar storage, diálogo e página.
- Evitar que a UI carregue regras de validação estrutural que pertencem ao domínio.
