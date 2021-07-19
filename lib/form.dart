import 'dart:async';

import 'package:dio/dio.dart';

import 'models.dart';
import 'store.dart';

class InertiaForm<T> {
  final _controller = StreamController<InertiaFormState<T>>.broadcast();
  late InertiaFormState<T> _state;
  CancelToken? _cancelToken;

  CancelToken? get cancelToken => _cancelToken;

  InertiaFormState<T> get state => _state;

  T get values => state.values;

  Stream<InertiaFormState<T>> get stateStream => _controller.stream;

  InertiaForm(T values) {
    _controller.onListen = () => _controller.sink.add(state);
    _setState(InertiaFormState(values: values, isSubmitting: false));
  }

  _setState(InertiaFormState<T> state) {
    _state = state;
    _controller.sink.add(state);
  }

  void setValues(T values) {
    if (_state.isSubmitting) {
      return;
    }
    _setState(InertiaFormState(values: values, isSubmitting: false));
  }

  void setErrors(errors) {
    if (_state.isSubmitting) {
      return;
    }
    _setState(InertiaFormState(
      values: _state.values,
      isSubmitting: false,
      errors: errors,
    ));
  }

  submit({
    required String path,
    required String method,
    Function(T data)? transform,
    Map<String, String>? headers,
  }) async {
    final data = transform != null ? transform(_state.values) : _state.values;
    _cancelToken = CancelToken();
    _setState(InertiaFormState(values: _state.values, isSubmitting: true));
    try {
      final response = await Inertia.request(
        path,
        method: method,
        headers: headers,
        data: data,
        cancelToken: _cancelToken,
      );
      _setState(InertiaFormState(
        values: _state.values,
        isSubmitting: false,
        errors: response is InertiaPage ? response.props['errors'] : null,
      ));
    } catch (e) {
      _setState(InertiaFormState(values: _state.values, isSubmitting: false));
      throw e;
    }
  }

  dispose() {
    _controller.close();
  }
}

class InertiaFormState<T> {
  final T values;
  final errors;
  final bool isSubmitting;

  InertiaFormState({
    required this.values,
    this.errors,
    required this.isSubmitting,
  });
}
