// lib/Observable/rx.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:simulador_ocpp/observable/i_rx_subscribe.dart';
import 'package:simulador_ocpp/observable/rx_observer.dart';

class Rx<T> implements RxSubscribable, ValueListenable<T> {
  Rx(
    T initialValue, {
    bool notifyOnSameValue = false,
    bool scheduleNotifications = true,
  }) : _value = initialValue,
       _notifyOnSameValue = notifyOnSameValue,
       _scheduleNotifications = scheduleNotifications;

  T _value;

  final bool _notifyOnSameValue;
  final bool _scheduleNotifications;

  final Set<RxObserver> _observers = <RxObserver>{};
  final Set<VoidCallback> _listeners = <VoidCallback>{};
  final Set<void Function(T value)> _valueListeners =
      <void Function(T value)>{};

  bool _disposed = false;
  bool _notifyScheduled = false;

  @override
  T get value {
    RxDependencyTracker.dependOn(this);
    return _value;
  }

  set value(T newValue) {
    if (_disposed) return;

    final changed = _notifyOnSameValue ? true : (_value != newValue);
    if (!changed) return;

    _value = newValue;
    _notifyDependents();
  }

  void update(T Function(T current) fn) {
    value = fn(_value);
  }

  void refresh() {
    if (_disposed) return;
    _notifyDependents(force: true);
  }

  @override
  void addListener(VoidCallback listener) {
    if (_disposed) return;
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  RxSubscription listen(
    void Function(T value) listener, {
    bool emitirAtual = false,
  }) {
    if (_disposed) {
      return RxSubscription(() {});
    }

    _valueListeners.add(listener);

    if (emitirAtual) {
      listener(_value);
    }

    return RxSubscription(() {
      _valueListeners.remove(listener);
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _notifyScheduled = false;
    _observers.clear();
    _listeners.clear();
    _valueListeners.clear();
  }

  @override
  void registerObserver(RxObserver o) {
    if (_disposed) return;
    _observers.add(o);
  }

  @override
  void unregisterObserver(RxObserver o) {
    _observers.remove(o);
  }

  void _notifyDependents({bool force = false}) {
    if (_observers.isEmpty && _listeners.isEmpty && _valueListeners.isEmpty) {
      return;
    }

    void doNotify() {
      if (_disposed) return;

      final observers = List<RxObserver>.of(_observers);
      final listeners = List<VoidCallback>.of(_listeners);
      final valueListeners = List<void Function(T value)>.of(_valueListeners);
      final currentValue = _value;

      for (final observer in observers) {
        observer.notify();
      }

      for (final listener in listeners) {
        listener();
      }

      for (final listener in valueListeners) {
        listener(currentValue);
      }
    }

    if (!_scheduleNotifications) {
      doNotify();
      return;
    }

    if (_notifyScheduled && !force) return;
    _notifyScheduled = true;

    scheduleMicrotask(() {
      _notifyScheduled = false;
      doNotify();
    });
  }
}
