# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 3/6 derivado de @file:carregador-26-05-08-5.md.

## Arquivos
- @file:carregador-26-05-08-5-parte_2-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `assets/carregador/conector_CCS2.png`
- `assets/carregador/conector_GBT.png`
- `assets/carregador/conector_MENNEKES_type_2.png`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente no contrato de apresentacao dos chips de conector.
- Preparar `_ConectoresConfigurados(...)` e `_ConectorConfiguradoChip(...)` para saberem:
  - quantidade total de conectores do carregador;
  - indice/posicao do conector na lista;
  - id do carregador;
  - estado visual necessario para exibir status, se ja estiver disponivel na pagina.
- Manter a aparencia visual atual dos chips, exceto por ajustes minimos necessarios para compilar.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao adicionar novos campos aos modelos de dominio apenas para rotulos de UI.
- Nao implementar ainda o visual final dos grupos `Group_34`, `Group_35` ou `Group_36`.
- Nao alterar regras de persistencia.

## Entregaveis
1. Alterar `_ConectoresConfigurados(...)` para iterar com indice e passar contexto suficiente para cada chip.
2. Alterar `_ConectorConfiguradoChip(...)` para receber o contexto necessario para os proximos slices.
3. Criar helpers privados de apresentacao, se necessario, para:
   - identificar se o carregador tem 1 ou 2 conectores;
   - gerar rotulo `Conector Central`, `Esquerdo` ou `Direito`;
   - escolher o asset do tipo de conector.
4. Manter o comportamento visual existente enquanto o novo contrato e preparado.
5. Rodar `flutter analyze`.
6. Rodar o teste de widget da pagina de carregadores.
7. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-5-parte_3-resumo.md`.

# Descricao
- Preparacao tecnica para os chips terem variantes diferentes por quantidade e posicao.

## Objetivo
- Evitar que a implementacao visual dos chips precise mexer novamente na passagem de dados e no fluxo da lista.
