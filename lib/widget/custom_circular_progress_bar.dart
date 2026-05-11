import 'package:flutter/material.dart';

class CustomCircularProgressBar extends StatelessWidget {
  const CustomCircularProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CarregandoCarregadores();
  }
}

class _CarregandoCarregadores extends StatelessWidget {
  const _CarregandoCarregadores();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(
        color: cores.primary,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
