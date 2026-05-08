import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaApp {
  const TemaApp({this.isDark = false, this.temaEscuroMedio = true});

  final bool isDark;
  final bool temaEscuroMedio;

  TemaCores get cores =>
      TemaCores(isDark: isDark, temaEscuroMedio: temaEscuroMedio);

  TemaEstiloTexto get estiloTexto => TemaEstiloTexto(cores);

  ThemeData get themeData => _criarThemeData();

  static ThemeData temaClaro() => const TemaApp().themeData;

  static ThemeData temaEscuro({bool temaEscuroMedio = true}) =>
      TemaApp(isDark: true, temaEscuroMedio: temaEscuroMedio).themeData;

  ThemeData _criarThemeData() {
    final temaCores = cores;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: temaCores.primaria,
          brightness: brightness,
        ).copyWith(
          primary: temaCores.primaria,
          onPrimary: temaCores.contrastePrimaria,
          primaryContainer: temaCores.containerPrimario,
          onPrimaryContainer: temaCores.textoPrimarioContainer,
          secondary: temaCores.destaque,
          onSecondary: TemaCores.conteudoSobreDestaque,
          secondaryContainer: temaCores.containerDestaque,
          onSecondaryContainer: TemaCores.conteudoSobreDestaque,
          tertiary: temaCores.green,
          onTertiary: TemaCores.conteudoSobreDestaque,
          surface: temaCores.backgroundSecundario,
          onSurface: temaCores.texto,
          surfaceContainerLowest: temaCores.backgroundPrimario,
          surfaceContainerLow: temaCores.surfaceBaixa,
          surfaceContainer: temaCores.backgroundSecundario,
          surfaceContainerHigh: temaCores.surfaceAlta,
          surfaceContainerHighest: temaCores.surfaceMaisAlta,
          outline: temaCores.outline,
          outlineVariant: temaCores.borda,
          error: temaCores.red,
          onError: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: temaCores.backgroundPrimario,
      fontFamily: TemaTipografia.familiaFonte,
      fontFamilyFallback: TemaTipografia.familiasReserva,
      textTheme: estiloTexto.materialTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: temaCores.backgroundSecundario,
        foregroundColor: temaCores.texto,
        titleTextStyle: estiloTexto.titleBold.corTexto,
      ),
      cardTheme: CardThemeData(
        color: temaCores.backgroundSecundario,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TemaMedidas.raioCard),
          side: BorderSide(color: temaCores.borda),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: temaCores.borda,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: temaCores.icons, size: 20),
      inputDecorationTheme: _inputDecorationTheme(temaCores),
      filledButtonTheme: _filledButtonTheme(temaCores),
      outlinedButtonTheme: _outlinedButtonTheme(temaCores),
      textButtonTheme: _textButtonTheme(temaCores),
      checkboxTheme: _checkboxTheme(temaCores),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? TemaCores.neutro900 : TemaCores.verdeProfundo,
        contentTextStyle: estiloTexto.bodyText.corContrastePrimaria,
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: temaCores.destaque,
        linearTrackColor: temaCores.surfaceBaixa,
      ),
    );
  }

  InputDecorationTheme _inputDecorationTheme(TemaCores temaCores) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TemaMedidas.raioControle),
      borderSide: BorderSide(color: temaCores.borda),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: temaCores.campo,
      hintStyle: estiloTexto.bodyText.base.copyWith(
        color: temaCores.textoSutil,
      ),
      labelStyle: estiloTexto.labelText.corTexto,
      prefixIconColor: temaCores.icons,
      suffixIconColor: temaCores.icons,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: temaCores.primaria, width: 1.4),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: temaCores.red, width: 1.2),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: temaCores.red, width: 1.4),
      ),
    );
  }

  FilledButtonThemeData _filledButtonTheme(TemaCores temaCores) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(TemaMedidas.alturaControle),
        backgroundColor: temaCores.primaria,
        disabledBackgroundColor: temaCores.primaria.withValues(alpha: 0.42),
        foregroundColor: temaCores.contrastePrimaria,
        disabledForegroundColor: temaCores.contrastePrimaria.withValues(
          alpha: 0.72,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TemaMedidas.raioControle),
        ),
        textStyle: estiloTexto.buttonText.base,
      ),
    );
  }

  OutlinedButtonThemeData _outlinedButtonTheme(TemaCores temaCores) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(TemaMedidas.alturaControle),
        backgroundColor: temaCores.backgroundSecundario,
        foregroundColor: temaCores.texto,
        disabledForegroundColor: temaCores.textoSutil,
        side: BorderSide(color: temaCores.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TemaMedidas.raioControle),
        ),
        textStyle: estiloTexto.buttonText.base,
      ),
    );
  }

  TextButtonThemeData _textButtonTheme(TemaCores temaCores) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: temaCores.primaria,
        disabledForegroundColor: temaCores.textoSutil,
        textStyle: estiloTexto.labelText.base,
      ),
    );
  }

  CheckboxThemeData _checkboxTheme(TemaCores temaCores) {
    return CheckboxThemeData(
      checkColor: WidgetStateProperty.all(temaCores.contrastePrimaria),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return temaCores.textoSutil.withValues(alpha: 0.36);
        }

        if (states.contains(WidgetState.selected)) {
          return temaCores.primaria;
        }

        return Colors.transparent;
      }),
      side: BorderSide(color: temaCores.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TemaMedidas.raioCheckbox),
      ),
    );
  }
}

class TemaService extends ChangeNotifier {
  TemaService({
    bool isDark = false,
    this.temaEscuroMedio = true,
    SharedPreferences? preferencias,
  }) : _isDark = isDark,
       _preferencias = preferencias;

  static const _chaveTemaEscuro = 'tema_escuro';

  bool _isDark;
  bool temaEscuroMedio;
  final SharedPreferences? _preferencias;

  static Future<TemaService> carregar() async {
    final preferencias = await SharedPreferences.getInstance();
    final brilhoSistema =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final temaEscuro =
        preferencias.getBool(_chaveTemaEscuro) ??
        (brilhoSistema == Brightness.dark);

    return TemaService(isDark: temaEscuro, preferencias: preferencias);
  }

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  TemaApp get tema =>
      TemaApp(isDark: _isDark, temaEscuroMedio: temaEscuroMedio);

  void alternarTema() => definirTemaEscuro(!_isDark);

  void definirTemaEscuro(bool valor) {
    if (_isDark == valor) return;

    _isDark = valor;
    notifyListeners();
    _salvarTemaEscuro(valor);
  }

  void definirEscuroMedio(bool valor) {
    if (temaEscuroMedio == valor) return;

    temaEscuroMedio = valor;
    notifyListeners();
  }

  void _salvarTemaEscuro(bool valor) {
    final preferencias = _preferencias;
    if (preferencias == null) return;

    unawaited(preferencias.setBool(_chaveTemaEscuro, valor));
  }
}

class TemaCores {
  const TemaCores({this.isDark = false, this.temaEscuroMedio = true});

  static const azulPrimario = Color(0xFF439BE2);
  static const azulAcao = Color(0xFF2F9FF2);
  static const verdeDestaque = Color(0xFFA2FF6C);
  static const verdeEnergia = Color(0xFF3EEA9B);
  static const verdeProfundo = Color(0xFF10231C);
  static const verdeSuperficie = Color(0xFF18382D);
  static const conteudoSobreDestaque = Color(0xFF10231C);
  static const neutro950 = Color(0xFF0B0F12);
  static const neutro900 = Color(0xFF141414);
  static const neutro800 = Color(0xFF202428);
  static const neutro700 = Color(0xFF343A40);
  static const neutro600 = Color(0xFF68727D);
  static const neutro500 = Color(0xFF7A828A);
  static const neutro400 = Color(0xFF8A929A);
  static const neutro300 = Color(0xFFADB5BD);
  static const neutro200 = Color(0xFFDCE1E5);
  static const neutro150 = Color(0xFFDDE3E8);
  static const neutro100 = Color(0xFFE3E6EA);
  static const neutro050 = Color(0xFFF7F8FA);
  static const erroClaro = Color(0xFFD43B3B);
  static const erroEscuro = Color(0xFFFF6B6B);

  final bool isDark;
  final bool temaEscuroMedio;

  Color get primaria => azulPrimario;

  Color get acaoPrimaria => azulAcao;

  Color get destaque => verdeDestaque;

  Color get contrastePrimaria => Colors.white;

  Color get textoComum =>
      isDark ? const Color(0xFFEAF0F6) : const Color(0xFF15171A);

  Color get texto => textoComum;

  Color get textoSecundario => isDark ? const Color(0xFFC7D8D0) : neutro500;

  Color get textoSutil => isDark ? const Color(0xFF8FB6A6) : neutro400;

  Color get backgroundPrimario =>
      isDark ? (temaEscuroMedio ? neutro900 : neutro950) : neutro050;

  Color get backgroundSecundario =>
      isDark ? const Color(0xFF1A1D20) : Colors.white;

  Color get surfaceBaixa =>
      isDark ? _camadaPrimariaEscura(0.08) : const Color(0xFFF1F5F8);

  Color get surfaceAlta =>
      isDark ? _camadaPrimariaEscura(0.14) : const Color(0xFFFBFCFD);

  Color get surfaceMaisAlta =>
      isDark ? _camadaPrimariaEscura(0.20) : const Color(0xFFEFF4F8);

  Color get campo => backgroundSecundario;

  Color get borda => isDark ? const Color(0xFF2B4038) : neutro150;

  Color get outline => isDark ? const Color(0xFF3C5A4E) : neutro200;

  Color get icons => isDark ? const Color(0xFFC7D8D0) : neutro600;

  Color get green => isDark ? verdeEnergia : const Color(0xFF00A676);

  Color get red => isDark ? erroEscuro : erroClaro;

  Color get containerPrimario =>
      isDark ? const Color(0xFF12385A) : const Color(0xFFE8F4FF);

  Color get textoPrimarioContainer =>
      isDark ? const Color(0xFFD7ECFF) : const Color(0xFF10395B);

  Color get containerDestaque =>
      isDark ? const Color(0xFF2D4B24) : const Color(0xFFE9FFD9);

  Color _camadaPrimariaEscura(double alpha) {
    return Color.alphaBlend(
      primaria.withValues(alpha: alpha),
      backgroundSecundario,
    );
  }
}

class TemaEstiloTexto {
  const TemaEstiloTexto(this.cores);

  final TemaCores cores;

  TextTheme get materialTextTheme => TextTheme(
    displayLarge: _text(40, FontWeight.w900, 1),
    displayMedium: _text(34, FontWeight.w900, 1.05),
    displaySmall: _text(30, FontWeight.w800, 1.08),
    headlineLarge: _text(28, FontWeight.w800, 1.1),
    headlineMedium: _text(24, FontWeight.w800, 1.12),
    headlineSmall: _text(20, FontWeight.w800, 1.16),
    titleLarge: _text(20, FontWeight.w800, 1.2),
    titleMedium: _text(16, FontWeight.w800, 1.25),
    titleSmall: _text(14, FontWeight.w700, 1.3),
    bodyLarge: _text(15, FontWeight.w500, 1.5),
    bodyMedium: _text(13, FontWeight.w500, 1.45),
    bodySmall: _text(12, FontWeight.w500, 1.4),
    labelLarge: _text(13, FontWeight.w800, 1.2),
    labelMedium: _text(12, FontWeight.w700, 1.2),
    labelSmall: _text(11, FontWeight.w700, 1.15),
  );

  TemaTexto get headlineBold =>
      TemaTexto(_text(28, FontWeight.w800, 1.1), cores);

  TemaTexto get bodyText => TemaTexto(_text(13, FontWeight.w500, 1.45), cores);

  TemaTexto get buttonText => TemaTexto(_text(13, FontWeight.w800, 1.2), cores);

  TemaTexto get labelText => TemaTexto(_text(12, FontWeight.w700, 1.2), cores);

  TemaTexto get cardTitle => TemaTexto(_text(16, FontWeight.w800, 1.25), cores);

  TemaTexto get titleBold => TemaTexto(_text(20, FontWeight.w800, 1.2), cores);

  TextStyle _text(double size, FontWeight weight, double height) {
    return TextStyle(
      color: cores.texto,
      fontFamily: TemaTipografia.familiaFonte,
      fontFamilyFallback: TemaTipografia.familiasReserva,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }
}

class TemaTexto {
  const TemaTexto(this.base, this._cores);

  final TextStyle base;
  final TemaCores _cores;

  TextStyle get corTexto => base.copyWith(color: _cores.textoComum);

  TextStyle get corContrastePrimaria =>
      base.copyWith(color: _cores.contrastePrimaria);

  TextStyle get primaria => base.copyWith(color: _cores.primaria);

  TextStyle get corDestaque => base.copyWith(color: _cores.destaque);

  TextStyle get secundaria => base.copyWith(color: _cores.textoSecundario);

  TextStyle get sutil => base.copyWith(color: _cores.textoSutil);
}

abstract final class TemaTipografia {
  static const familiaFonte = 'Inter';
  static const familiasReserva = ['Roboto', 'Arial', 'sans-serif'];
}

abstract final class TemaMedidas {
  static const alturaControle = 46.0;
  static const raioControle = 4.0;
  static const raioCheckbox = 4.0;
  static const raioCard = 8.0;
}
