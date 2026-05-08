import 'package:flutter/material.dart';
import 'package:simulador_ocpp/features/login/presentation/viewmodels/login_view_model.dart';
import 'package:simulador_ocpp/features/simulador/simulador_home_page.dart';
import 'package:simulador_ocpp/observable/obx.dart';
import 'package:simulador_ocpp/widget/botao_primario.dart';
import 'package:simulador_ocpp/widget/botao_secundario.dart';
import 'package:simulador_ocpp/widget/custom_text_form_field.dart';

class _LoginPaleta {
  const _LoginPaleta({
    required this.fundoPagina,
    required this.fundoFrame,
    required this.sombraFrame,
    required this.painelFundo,
    required this.painelSuperficie,
    required this.painelTrilhoProgresso,
    required this.painelDestaque,
    required this.painelTextoPrimario,
    required this.painelTextoSecundario,
    required this.painelTextoApoio,
    required this.painelBordaDestaque,
  });

  factory _LoginPaleta.of(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final escuro = tema.brightness == Brightness.dark;

    return _LoginPaleta(
      fundoPagina: cores.surfaceContainerLowest,
      fundoFrame: cores.surface,
      sombraFrame: cores.shadow.withValues(alpha: escuro ? 0.34 : 0.16),
      painelFundo: cores.primaryContainer,
      painelSuperficie: cores.surfaceContainerHighest,
      painelTrilhoProgresso: cores.surfaceContainerLowest,
      painelDestaque: cores.secondary,
      painelTextoPrimario: cores.onPrimaryContainer,
      painelTextoSecundario: cores.onPrimaryContainer.withValues(alpha: 0.82),
      painelTextoApoio: cores.onPrimaryContainer.withValues(alpha: 0.72),
      painelBordaDestaque: cores.secondary.withValues(alpha: 0.36),
    );
  }

  final Color fundoPagina;
  final Color fundoFrame;
  final Color sombraFrame;
  final Color painelFundo;
  final Color painelSuperficie;
  final Color painelTrilhoProgresso;
  final Color painelDestaque;
  final Color painelTextoPrimario;
  final Color painelTextoSecundario;
  final Color painelTextoApoio;
  final Color painelBordaDestaque;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _viewModel = LoginViewModel();
  final _usuarioController = TextEditingController(text: 'admin');
  final _senhaController = TextEditingController(text: 'admin');
  bool _manterConectado = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final autenticado = await _viewModel.entrar(
      usuario: _usuarioController.text,
      senha: _senhaController.text,
    );

    if (!mounted || !autenticado) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SimuladorHomePage()),
    );
  }

  void _continuarComGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Google será integrado ao backend.'),
      ),
    );
  }

  void _alterarManterConectado(bool? value) {
    setState(() => _manterConectado = value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final paleta = _LoginPaleta.of(context);

    return Scaffold(
      backgroundColor: paleta.fundoPagina,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layoutAmplo = constraints.maxWidth >= 900;
            final formulario = _FormularioLogin(
              viewModel: _viewModel,
              usuarioController: _usuarioController,
              senhaController: _senhaController,
              manterConectado: _manterConectado,
              onManterConectado: _alterarManterConectado,
              onEntrar: _entrar,
              onGoogle: _continuarComGoogle,
            );

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: layoutAmplo ? 32 : 0,
                  vertical: layoutAmplo ? 32 : 0,
                ),
                child: layoutAmplo
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 980,
                          minHeight: 760,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: paleta.fundoFrame,
                              boxShadow: [
                                BoxShadow(
                                  color: paleta.sombraFrame,
                                  blurRadius: 28,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 760,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Expanded(child: _EnergiaPainel()),
                                  SizedBox(
                                    width: 392,
                                    child: _LoginFrame(
                                      arredondado: false,
                                      child: formulario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: constraints.maxWidth,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _LoginFrame(
                            arredondado: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _EnergiaPainel(compacto: true),
                                formulario,
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EnergiaPainel extends StatelessWidget {
  const _EnergiaPainel({this.compacto = false});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = _LoginPaleta.of(context);

    return Container(
      constraints: BoxConstraints(minHeight: compacto ? 204 : 760),
      padding: EdgeInsets.all(compacto ? 24 : 40),
      decoration: BoxDecoration(
        color: paleta.painelFundo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(compacto ? 0 : 22),
          bottomRight: Radius.circular(compacto ? 16 : 0),
          topLeft: Radius.circular(compacto ? 16 : 22),
          topRight: Radius.circular(compacto ? 16 : 0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: compacto ? 38 : 46,
                height: compacto ? 38 : 46,
                decoration: BoxDecoration(
                  color: paleta.painelDestaque,
                  borderRadius: BorderRadius.circular(compacto ? 12 : 14),
                ),
                child: Icon(
                  Icons.ev_station_rounded,
                  color: tema.colorScheme.onSecondary,
                  size: compacto ? 21 : 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Simulador OCPP',
                  style: tema.textTheme.titleLarge?.copyWith(
                    color: paleta.painelTextoPrimario,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compacto ? 18 : 34),
          if (!compacto) const _CargaResumo(),
          SizedBox(height: compacto ? 18 : 40),
          Text(
            'Controle inteligente para testes de recarga veicular.',
            style: tema.textTheme.headlineMedium?.copyWith(
              color: paleta.painelTextoPrimario,
              fontSize: compacto ? 24 : 32,
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Entre para iniciar a simulação e acompanhar o estado do carregador em tempo real.',
            style: tema.textTheme.bodyLarge?.copyWith(
              color: paleta.painelTextoSecundario,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CargaResumo extends StatelessWidget {
  const _CargaResumo();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = _LoginPaleta.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paleta.painelSuperficie,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: paleta.painelBordaDestaque),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: paleta.painelDestaque),
                const SizedBox(width: 10),
                Text(
                  'Carga pronta',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: paleta.painelTextoPrimario,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '82%',
              style: tema.textTheme.displayLarge?.copyWith(
                color: paleta.painelTextoPrimario,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.82,
              minHeight: 8,
              backgroundColor: paleta.painelTrilhoProgresso,
              color: paleta.painelDestaque,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricaCarga(rotulo: 'Potência', valor: '7.4 kW'),
                _MetricaCarga(rotulo: 'Tempo', valor: '34 min'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricaCarga extends StatelessWidget {
  const _MetricaCarga({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = _LoginPaleta.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: tema.textTheme.labelMedium?.copyWith(
            color: paleta.painelTextoApoio,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: paleta.painelTextoPrimario,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LoginFrame extends StatelessWidget {
  const _LoginFrame({required this.arredondado, required this.child});

  final bool arredondado;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(arredondado ? 22 : 0);
    final paleta = _LoginPaleta.of(context);

    return ClipRRect(
      borderRadius: raio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: paleta.fundoFrame,
          borderRadius: raio,
          boxShadow: arredondado
              ? [
                  BoxShadow(
                    color: paleta.sombraFrame,
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [const _LoginTopo(), child],
        ),
      ),
    );
  }
}

class _LoginTopo extends StatelessWidget {
  const _LoginTopo();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: cores.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              Icons.electric_car_outlined,
              color: cores.onPrimary,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'EVOLTBR',
              style: tema.textTheme.labelMedium?.copyWith(
                color: cores.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Menu',
            onPressed: () {},
            icon: Icon(
              Icons.menu_rounded,
              color: cores.onSurfaceVariant,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoRotulo extends StatelessWidget {
  const _CampoRotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        texto,
        style: tema.textTheme.labelMedium?.copyWith(
          color: tema.colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DivisorSocial extends StatelessWidget {
  const _DivisorSocial();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: cores.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou continue com',
            style: tema.textTheme.labelMedium?.copyWith(
              color: cores.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: cores.outlineVariant)),
      ],
    );
  }
}

class _FormularioLogin extends StatelessWidget {
  const _FormularioLogin({
    required this.viewModel,
    required this.usuarioController,
    required this.senhaController,
    required this.manterConectado,
    required this.onManterConectado,
    required this.onEntrar,
    required this.onGoogle,
  });

  final LoginViewModel viewModel;
  final TextEditingController usuarioController;
  final TextEditingController senhaController;
  final bool manterConectado;
  final ValueChanged<bool?> onManterConectado;
  final VoidCallback onEntrar;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Acessar painel',
            style: tema.textTheme.labelMedium?.copyWith(
              color: cores.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entre e comece\na sua recarga',
            style: tema.textTheme.headlineSmall?.copyWith(
              color: cores.onSurface,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Use admin/admin para testar o fluxo local.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: cores.onSurfaceVariant,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 30),
          const _CampoRotulo('Usuário'),
          CustomTextFormField(
            campoKey: const Key('login_usuario'),
            controller: usuarioController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            hintText: 'admin',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 15),
          const _CampoRotulo('Senha'),
          Obx(
            () => CustomTextFormField(
              campoKey: const Key('login_senha'),
              controller: senhaController,
              obscureText: !viewModel.senhaVisivel.value,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => onEntrar(),
              hintText: 'admin',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: viewModel.senhaVisivel.value
                    ? 'Ocultar senha'
                    : 'Mostrar senha',
                onPressed: viewModel.alternarVisibilidadeSenha,
                icon: Icon(
                  viewModel.senhaVisivel.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: manterConectado,
                  activeColor: cores.primary,
                  side: BorderSide(color: cores.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: onManterConectado,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Manter conectado',
                  style: tema.textTheme.labelMedium?.copyWith(
                    color: cores.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: viewModel.erro.value == null
                  ? const SizedBox(height: 24)
                  : Align(
                      key: const Key('login_erro'),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        viewModel.erro.value!,
                        style: tema.textTheme.labelMedium?.copyWith(
                          color: cores.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => BotaoPrimario(
              key: const Key('login_entrar'),
              onPressed: onEntrar,
              carregando: viewModel.carregando.value,
            ),
          ),
          const SizedBox(height: 18),
          const _DivisorSocial(),
          const SizedBox(height: 18),
          BotaoSecundario.google(
            key: const Key('login_google'),
            onPressed: onGoogle,
          ),
        ],
      ),
    );
  }
}
