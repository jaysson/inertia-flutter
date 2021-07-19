import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:inertia_flutter/helpers.dart';
import 'package:inertia_flutter/inertia_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'models.dart';

PersistCookieJar? _cookieJar;
Dio? _dio;

/// Get a cookie jar where cookies persisted to application documents directory.
/// This allows us to keep user sessions between app launches.
Future<PersistCookieJar> _getCookieJar() async {
  if (_cookieJar == null) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar =
        PersistCookieJar(storage: FileStorage('$appDocPath/.cookies/'));
  }
  return _cookieJar!;
}

/// Get a dio instance which is pre-configured with cookies, logging, & csrf token handling
/// Inertia uses this client for all requests.
///
/// You can also use this to make any additional API calls.
Future<Dio> getDio() async {
  if (_dio == null) {
    final cookieJar = await _getCookieJar();
    _dio = Dio(
      BaseOptions(responseType: ResponseType.json, headers: {
        'X-Inertia': true,
        'X-Inertia-Version': '32eaf48f2736c52de2017141e7a2e957',
      }),
    )..interceptors.addAll([
        CookieManager(cookieJar),

        /// CSRF prevention
        InterceptorsWrapper(onRequest: (options, handler) async {
          final cookies = await cookieJar.loadForRequest(options.uri);
          final csrfTokenCookie = cookies.firstWhere(
              (cookie) => cookie.name == 'XSRF-TOKEN',
              orElse: () => Cookie('XSRF-TOKEN', ''));
          final csrfToken = csrfTokenCookie.value;
          if (csrfToken.isNotEmpty) {
            options.headers['X-XSRF-TOKEN'] = Uri.decodeComponent(csrfToken);
          }
          return handler.next(options);
        }),
        LogInterceptor(responseBody: true),
      ]);
  }
  return _dio!;
}

/// The Inertia class is responsible for keeping track of requests and responses.
///
/// Set the [baseUrl] in your application's `main` method before calling `runApp`.
/// Set the `navigatorKey` of your `MaterialApp` to [navigator]. Redirects will not work otherwise.
class Inertia {
  /// Allows easier navigation by omitting the host and scheme while calling `navigator.pushNamed` and the like.
  static late String baseUrl;

  /// The application navigator, used to handle redirections
  static final navigator = GlobalKey<NavigatorState>();

  /// Map of URLs and their [PageState] streams
  static Map<String, BehaviorSubject<PageState>> _controllers = {};

  /// Finds or creates a stream for the given path/url and returns it
  static BehaviorSubject<PageState> _getPageController(String path) {
    final url = getFullUrl(baseUrl: baseUrl, path: path);
    if (_controllers[url] == null) {
      _controllers[url] = BehaviorSubject<PageState>.seeded(
        PageState(
          isLoading: true,
        ),
      );
    }
    return _controllers[url]!;
  }

  /// The application can listen to the stream and update itself.
  /// For ex. [InertiaScreen] renders itself using a [StreamBuilder] which consumes the stream taken from this method.
  static Stream<PageState> getPageStream(String path) {
    return _getPageController(path).stream;
  }

  /// Interfaces with inertia API servers to get the [InertiaPage]
  /// - Makes API calls
  /// - Handles redirects by navigating to a new screen/follow in place
  /// - Parses the response into [InertiaPage] and returns it
  /// - In case of `GET` request, puts the response on the [path]'s stream
  ///
  /// You can also use these convenience methods:
  /// - [get]
  /// - [post]
  /// - [patch]
  /// - [put]
  /// - [delete]
  static Future<InertiaPage?> request(
    String path, {
    required String method,
    dynamic data,
    bool? followRedirects,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    final controller = _getPageController(path);
    final currentPageState = controller.value;
    final url = getFullUrl(baseUrl: baseUrl, path: path);
    final isGetRequest = method.toLowerCase() == 'get';
    if (isGetRequest) {
      currentPageState.cancelToken?.cancel();
    }
    try {
      final dio = await getDio();
      final response = await dio.request(
        url,
        cancelToken: cancelToken,
        data: data,
        options: Options(
          followRedirects: followRedirects ?? false,
          method: method,
        ),
      );
      final page = InertiaPage.fromJson(response.data);
      if (isGetRequest) {
        final pageState = PageState(page: page, isLoading: false);
        controller.add(pageState);
      }
      return page;
    } on DioError catch (e) {
      final location = e.response?.headers.value('location');
      if (location != null) {
        handleRedirect(
          location: location,
          navigator: navigator.currentState!,
          action: e.response?.headers.value('x-navigation-action'),
        );
      } else if (isGetRequest) {
        final pageState = PageState(
          page: currentPageState.page,
          isLoading: false,
          exception: e,
        );
        controller.add(pageState);
      } else {
        throw e;
      }
    } on Exception catch (e) {
      if (isGetRequest) {
        final pageState = PageState(
          page: currentPageState.page,
          isLoading: false,
          exception: e,
        );
        controller.add(pageState);
      } else {
        throw e;
      }
    }
  }

  /// @see [request]
  static Future<InertiaPage?> get(
    String path, {
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool? followRedirects,
  }) =>
      request(
        path,
        method: 'get',
        headers: headers,
        cancelToken: cancelToken,
        followRedirects: followRedirects,
      );

  /// @see [request]
  static Future<InertiaPage?> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool? followRedirects,
  }) =>
      request(
        path,
        method: 'post',
        data: data,
        headers: headers,
        cancelToken: cancelToken,
        followRedirects: followRedirects,
      );

  /// @see [request]
  static Future<InertiaPage?> put(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool? followRedirects,
  }) =>
      request(
        path,
        method: 'put',
        data: data,
        headers: headers,
        cancelToken: cancelToken,
        followRedirects: followRedirects,
      );

  /// @see [request]
  static Future<InertiaPage?> patch(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool? followRedirects,
  }) =>
      request(
        path,
        method: 'patch',
        data: data,
        headers: headers,
        cancelToken: cancelToken,
        followRedirects: followRedirects,
      );

  /// @see [request]
  static Future<InertiaPage?> delete(
    String path, {
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool? followRedirects,
  }) =>
      request(
        path,
        method: 'delete',
        headers: headers,
        cancelToken: cancelToken,
        followRedirects: followRedirects,
      );
}
