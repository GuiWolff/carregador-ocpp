import 'package:flutter/material.dart';
import 'package:simulador_ocpp/features/login/login_page.dart';
import 'package:simulador_ocpp/utils/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final temaService = await TemaService.carregar();

  runApp(MyApp(temaService: temaService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.temaService});

  final TemaService temaService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: temaService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Simulador OCPP',
          debugShowCheckedModeBanner: false,
          theme: TemaApp.temaClaro(),
          darkTheme: TemaApp.temaEscuro(),
          themeMode: temaService.themeMode,
          builder: (context, child) {
            return _TemaAppShell(
              temaService: temaService,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const LoginPage(),
        );
      },
    );
  }
}

class _TemaAppShell extends StatelessWidget {
  const _TemaAppShell({required this.temaService, required this.child});

  final TemaService temaService;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return Stack(
      children: [
        child,
        Positioned(
          top: padding.top + 68,
          right: 16,
          child: _BotaoAlternarTema(temaService: temaService),
        ),
      ],
    );
  }
}

class _BotaoAlternarTema extends StatelessWidget {
  const _BotaoAlternarTema({required this.temaService});

  final TemaService temaService;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final temaEscuro = temaService.isDark;
    final rotulo = temaEscuro ? 'Ativar tema claro' : 'Ativar tema escuro';

    return Material(
      color: tema.colorScheme.surface.withValues(alpha: 0.96),
      elevation: 4,
      shadowColor: tema.colorScheme.shadow.withValues(alpha: 0.16),
      shape: CircleBorder(
        side: BorderSide(color: tema.colorScheme.outlineVariant),
      ),
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        onPressed: temaService.alternarTema,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            temaEscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            key: ValueKey(temaEscuro),
            semanticLabel: rotulo,
            color: temaEscuro
                ? tema.colorScheme.secondary
                : tema.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
