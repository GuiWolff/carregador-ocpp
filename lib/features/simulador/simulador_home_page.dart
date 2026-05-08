import 'package:flutter/material.dart';
import 'package:simulador_ocpp/features/carregador/carregador.dart';

class SimuladorHomePage extends StatelessWidget {
  const SimuladorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador OCPP')),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Fluxo iniciado',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Simulador de ponto de recarga com comandos OCPP 1.6J.',
                    ),
                    SizedBox(height: 20),
                    CarregadorWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
