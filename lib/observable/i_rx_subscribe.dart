// lib/Observable/i_rx_subscribe.dart
import 'rx_observer.dart';

class RxSubscription {
  RxSubscription(this._onDispose);

  final void Function() _onDispose;
  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _onDispose();
  }
}

abstract class RxSubscribable {
  void registerObserver(RxObserver o);
  void unregisterObserver(RxObserver o);
}
