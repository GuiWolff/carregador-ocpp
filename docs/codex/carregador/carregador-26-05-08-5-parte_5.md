# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 5/6 derivado de @file:carregador-26-05-08-5.md.

## Arquivos
- @file:carregador-26-05-08-5-parte_4-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `resources/Group_34.png`
- `resources/Group_35.png`
- `assets/carregador/conector_CCS2.png`
- `assets/carregador/conector_GBT.png`
- `assets/carregador/conector_MENNEKES_type_2.png`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na variante de chips para carregador com 2 conectores.
- Usar `resources/Group_34.png` e `resources/Group_35.png` como referencias visuais.
- O conector de indice 0 deve ser apresentado como `Esquerdo`.
- O conector de indice 1 deve ser apresentado como `Direito`.
- Manter os dois chips alinhados abaixo da imagem do carregador, com quebra responsiva se faltar largura.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao cadastrar `resources/Group_34.png` ou `resources/Group_35.png` como assets de runtime, a menos que seja tomada uma decisao explicita e registrada no resumo.
- Nao alterar a variante de 1 conector alem do necessario para compatibilidade.
- Nao alterar modelos de dominio.

## Entregaveis
1. Implementar o layout de `_ConectorConfiguradoChip(...)` para o caso `totalConectores == 2`, seguindo a composicao de `Group_34.png` e `Group_35.png`:
   - card estreito;
   - imagem do conector no topo;
   - id do carregador/conector;
   - texto `Esquerdo` ou `Direito`;
   - informacao de potencia/status quando ja existir fonte de dados na pagina.
2. Ajustar `_ConectoresConfigurados(...)` para manter os dois chips centralizados abaixo da imagem do carregador.
3. Garantir dimensoes estaveis para que os chips nao mudem de tamanho entre estados.
4. Garantir fallback visual se o asset do conector falhar.
5. Rodar `flutter analyze`.
6. Rodar o teste de widget da pagina de carregadores.
7. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-5-parte_5-resumo.md`.

# Descricao
- Implementacao dos chips estreitos para carregadores com dois conectores configurados.

## Objetivo
- Reproduzir a intencao visual de conectores esquerdo e direito, mantendo a composicao centralizada abaixo do carregador.
