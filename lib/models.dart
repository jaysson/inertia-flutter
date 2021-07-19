import 'package:dio/dio.dart';

/// The Inertia JSON response.
/// @see https://inertiajs.com/the-protocol#inertia-responses
class InertiaPage {
  final String component;
  final Map<String, dynamic> props;
  final String url;
  final String? version;

  InertiaPage({
    required this.component,
    required this.props,
    required this.url,
    this.version,
  });

  factory InertiaPage.fromJson(Map<String, dynamic> json) {
    return InertiaPage(
      component: json["component"],
      props: json["props"],
      url: json["url"],
      version: json["version"],
    );
  }
}

/// Representation of an inertia request state
class PageState {
  final bool isLoading;

  /// Set if there was a successful request. Errors afterwards do not clear the old data.
  final InertiaPage? page;
  final CancelToken? cancelToken;

  /// The exception is set if a request did not successfully return [InertiaPage], it is cleared on next load
  /// There should never be a case where [isLoading] is true and [exception] is not null.
  final Exception? exception;

  PageState({
    required this.isLoading,
    this.page,
    this.cancelToken,
    this.exception,
  });
}
