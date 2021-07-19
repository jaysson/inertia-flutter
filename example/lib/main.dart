import 'package:flutter/material.dart';
import 'package:inertia_flutter/inertia_flutter.dart';
import 'package:inertia_flutter_example/components.dart';
import 'package:inertia_flutter_example/screens.dart';

import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    configureApp();
    Inertia.baseUrl = 'https://demo.inertiajs.com/';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '',
      navigatorKey: Inertia.navigator,
      onGenerateRoute: (route) => MaterialPageRoute(
        builder: (_) => InertiaScreen(
          settings: route,
          pageMaker: _makePage,
        ),
      ),
    );
  }

  Widget _makePage(RouteSettings settings, PageState pageState) {
    final page = pageState.page;
    final exception = pageState.exception;
    if (page != null) {
      final makeComponent = screens[page.component] ?? (_, __) => Container();
      return makeComponent(settings, page.props);
    }
    if (exception != null) {
      return ErrorScreen(error: exception);
    }
    return LoadingScreen();
  }
}
