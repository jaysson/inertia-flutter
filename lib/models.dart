import 'package:dio/dio.dart';

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

class PageState {
  final bool isLoading;
  final InertiaPage? page;
  final CancelToken? cancelToken;
  final Exception? exception;

  PageState({
    required this.isLoading,
    this.page,
    this.cancelToken,
    this.exception,
  });
}
