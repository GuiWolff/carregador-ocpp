import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simulador_ocpp/main.dart';
import 'package:simulador_ocpp/utils/tema.dart';

void main() {
  testWidgets('Login local com admin/admin inicia o simulador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(temaService: TemaService()));

    expect(find.text('Acessar painel'), findsOneWidget);
    expect(find.text('Fluxo iniciado'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('login_entrar')));
    await tester.tap(find.byKey(const Key('login_entrar')));
    await tester.pumpAndSettle();

    expect(find.text('Fluxo iniciado'), findsOneWidget);
  });

  testWidgets('Login local mostra erro para credenciais inválidas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(temaService: TemaService()));

    await tester.enterText(find.byKey(const Key('login_usuario')), 'admin');
    await tester.enterText(find.byKey(const Key('login_senha')), 'errada');
    await tester.ensureVisible(find.byKey(const Key('login_entrar')));
    await tester.tap(find.byKey(const Key('login_entrar')));
    await tester.pumpAndSettle();

    expect(find.text('Credenciais inválidas.'), findsOneWidget);
  });
}
