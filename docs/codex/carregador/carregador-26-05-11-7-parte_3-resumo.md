# Resumo do slice 3/5

## O que foi feito
- Separados os temporizadores de envio periódico de `MeterValues` por conector.
- Separados os temporizadores de tempo de carregamento por conector.
- O bloqueio de envio simultâneo de `MeterValues` passou a ser por conector, evitando que um envio impeça outro conector indefinidamente.
- A evolução automática de medidor, SoC, temperatura e tempo passou a usar o estado operacional do conector correspondente, sem depender do conector ativo.
- Pausar, retomar e parar carregamento agora cancelam ou reiniciam somente os temporizadores do conector selecionado.
- `_pararTimers()`, `desconectar()` e `dispose()` passam a cancelar temporizadores de todos os conectores.
- Adicionada fonte de tempo opcional no `CarregadorWidgetViewModel` para permitir testes determinísticos sem alterar o comportamento padrão em produção.
- Adicionados testes cobrindo evolução isolada por conector, pausa isolada e cancelamento dos temporizadores no descarte do ViewModel.
- Declarado `fake_async` como dependência de desenvolvimento para viabilizar testes com avanço controlado de tempo.

## Arquivos alterados
- `lib/features/carregador/presentation/viewmodels/carregador_widget_view_model.dart`
- `test/features/carregador/presentation/viewmodels/carregador_widget_view_model_test.dart`
- `pubspec.yaml`
- `pubspec.lock`
- `docs/codex/carregador/carregador-26-05-11-7-parte_3-resumo.md`

## Validações executadas
- `flutter analyze`
  - Resultado: passou sem issues.
- `flutter test test\features\carregador\presentation\viewmodels\carregador_widget_view_model_test.dart`
  - Resultado: passou. 11 testes executados.

## Bloqueios
- Nenhum bloqueio encontrado.

## Continuidade para o slice 4
- Prosseguir com `docs/codex/carregador/carregador-26-05-11-7-parte_4.md`.
- O slice 3 ficou limitado à independência dos temporizadores e evolução automática por conector, sem alterar layout, widgets, repositórios ou modelos de domínio.
