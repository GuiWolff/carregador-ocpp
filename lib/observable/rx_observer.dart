// lib/Observable/rx_observer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'i_rx_subscribe.dart';

/// Observer base
abstract class RxObserver {
  void notify();
}

/// Observer que rastreia dependências
abstract class RxTrackingObserver implements RxObserver {
  void track(RxSubscribable rx);
  void beginBuild();
}

/// Tracker global
class RxDependencyTracker {
  static RxObserver? _current;

  static T track<T>(RxObserver observer, T Function() builder) {
    final prev = _current;
    _current = observer;

    if (observer is RxTrackingObserver) {
      observer.beginBuild();
    }

    try {
      return builder();
    } finally {
      _current = prev;
    }
  }

  static void dependOn(RxSubscribable rx) {
    final o = _current;
    if (o is RxTrackingObserver) {
      o.track(rx);
    }
  }
}

/// ObxObserver (rastreador)
class ObxObserver implements RxTrackingObserver {
  ObxObserver(this._requestRebuild);

  final VoidCallback _requestRebuild;
  final Set<RxSubscribable> _deps = <RxSubscribable>{};

  bool _scheduled = false;
  bool _disposed = false;

  @override
  void beginBuild() {
    for (final rx in _deps) {
      rx.unregisterObserver(this);
    }
    _deps.clear();
  }

  @override
  void track(RxSubscribable rx) {
    if (_disposed) return;
    if (_deps.add(rx)) {
      rx.registerObserver(this);
    }
  }

  @override
  void notify() {
    if (_disposed) return;
    if (_scheduled) return;
    _scheduled = true;

    scheduleMicrotask(() {
      _scheduled = false;
      if (_disposed) return;
      _requestRebuild();
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _scheduled = false;
    beginBuild();
  }
}
