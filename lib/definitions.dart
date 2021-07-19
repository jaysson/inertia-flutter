import 'package:flutter/widgets.dart';

import 'models.dart';

typedef LoadingRenderer = Widget Function(RouteSettings settings);
typedef ErrorRenderer = Widget Function(
  RouteSettings settings,
  Exception error,
);
typedef RouteMaker = Route Function(RouteSettings settings, Widget child);
typedef PageMaker = Widget Function(RouteSettings settings, PageState page);
typedef FrameMaker = Widget Function(String path, PageState page);
typedef ScreensMap
    = Map<String, Widget Function(RouteSettings settings, dynamic props)>;
typedef PageMap = Map<String, PageState>;
typedef AppBuilder = Widget Function(
  GlobalKey<NavigatorState> navigatorKey,
  RouteHandler handleRoute,
);
typedef RouteHandler = Route Function(RouteSettings settings);
