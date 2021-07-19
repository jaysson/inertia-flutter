import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:inertia_flutter/helpers.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

PersistCookieJar? _cookieJar;
Dio? _dio;

Future<PersistCookieJar> _getCookieJar() async {
  if (_cookieJar == null) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar =
        PersistCookieJar(storage: FileStorage('$appDocPath/.cookies/'));
  }
  return _cookieJar!;
}

Future<Dio> _getDio() async {
  if (_dio == null) {
    final cookieJar = await _getCookieJar();
    _dio = Dio(
      BaseOptions(responseType: ResponseType.json, headers: {
        'X-Inertia': true,
        'X-Inertia-Version': '32eaf48f2736c52de2017141e7a2e957',
      }),
    )..interceptors.addAll([
        CookieManager(cookieJar),
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

class Inertia {
  static late String baseUrl;
  static final navigator = GlobalKey<NavigatorState>();

  static Map<String, StreamController<PageState>> _controllers = {};
  static Map<String, PageState> _pageMap = {};

  static PageState getPageState(String path) {
    final url = getFullUrl(baseUrl: baseUrl, path: path);
    if (_pageMap[url] == null) {
      _pageMap[url] = PageState(isLoading: true);
    }
    return _pageMap[url]!;
  }

  static StreamController<PageState> _getPageController(String path) {
    final url = getFullUrl(baseUrl: baseUrl, path: path);
    if (_controllers[url] == null) {
      _controllers[url] = StreamController<PageState>.broadcast();
    }
    return _controllers[url]!;
  }

  static Stream<PageState> getPageStream(String path) {
    return _getPageController(path).stream;
  }

  static Future<InertiaPage?> request(
    String path, {
    required String method,
    dynamic data,
    bool? followRedirects,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    final controller = _getPageController(path);
    final currentPageState = getPageState(path);
    final url = getFullUrl(baseUrl: baseUrl, path: path);
    final isGetRequest = method.toLowerCase() == 'get';
    if (isGetRequest) {
      currentPageState.cancelToken?.cancel();
    }
    try {
      final dio = await _getDio();
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
        _pageMap[url] = pageState;
        controller.sink.add(pageState);
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
        if (isGetRequest) {
          _pageMap.remove(url);
        }
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
        _pageMap[url] = pageState;
        controller.sink.add(pageState);
      } else {
        throw e;
      }
    }
  }

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
