// lib/Observable/obx.dart
import 'package:flutter/widgets.dart';
import 'rx_observer.dart';

class Obx extends StatefulWidget {
  final Widget Function() builder;
  const Obx(this.builder, {super.key});

  @override
  State<Obx> createState() => _ObxState();
}

class _ObxState extends State<Obx> {
  late final ObxObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = ObxObserver(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RxDependencyTracker.track(_observer, widget.builder);
  }
}
