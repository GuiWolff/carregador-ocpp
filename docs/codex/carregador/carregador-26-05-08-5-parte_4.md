# Contexto
Voce e um desenvolvedor Senior em Dart / Flutter.
Leia o resumo do prompt anterior, se houver, e continue a evolucao.
Este e o slice 4/6 derivado de @file:carregador-26-05-08-5.md.

## Arquivos
- @file:carregador-26-05-08-5-parte_3-resumo.md
- `lib/features/carregador/presentation/pages/carregador_page.dart`
- `resources/Group_36.png`
- `assets/carregador/conector_CCS2.png`
- `assets/carregador/conector_GBT.png`
- `assets/carregador/conector_MENNEKES_type_2.png`
- `test/features/carregador/presentation/pages/carregador_page_test.dart`

## Regras
- Trabalhar somente na variante de chip para carregador com 1 conector.
- Usar `resources/Group_36.png` como referencia visual.
- O chip unico deve ser mais largo que os chips de 2 conectores.
- O rotulo principal deve representar o conector central.
- Manter os assets reais dos conectores vindo de `assets/carregador/`.

## Restricoes
- Nao reescreva arquivos inteiros quando for executar a tarefa, apenas altere as linhas necessarias.
- Nao cadastrar `resources/Group_36.png` como asset de runtime, a menos que seja tomada uma decisao explicita e registrada no resumo.
- Nao alterar a variante de 2 conectores alem do necessario para manter compatibilidade.
- Nao alterar modelos de dominio.

## Entregaveis
1. Implementar o layout de `_ConectorConfiguradoChip(...)` para o caso `totalConectores == 1`, seguindo a composicao de `Group_36.png`:
   - card largo;
   - imagem do conector no topo;
   - id do carregador/conector;
   - texto `Conector Central`;
   - informacao de potencia/status quando ja existir fonte de dados na pagina.
2. Aplicar borda, raio, fundo, espacamentos e alinhamento central de forma proporcional a referencia.
3. Garantir fallback visual se o asset do conector falhar.
4. Rodar `flutter analyze`.
5. Rodar o teste de widget da pagina de carregadores.
6. Salvar um resumo da execucao em `docs/codex/carregador/carregador-26-05-08-5-parte_4-resumo.md`.

# Descricao
- Implementacao do chip em formato largo para carregadores com apenas um conector configurado.

## Objetivo
- Reproduzir a intencao visual do `Group_36.png` sem misturar esta entrega com as variantes esquerda/direita.
