import 'package:flutter/widgets.dart';

void handleRedirect({
  required String location,
  required NavigatorState navigator,
  String? action,
}) {
  switch (action) {
    case 'push':
      navigator.pushNamed(location);
      break;
    case 'reset':
      navigator.popUntil((route) => route.settings.name == location);
      break;
    case 'reset-root':
      navigator.pushNamedAndRemoveUntil(location, (route) => false);
      break;
    default:
      navigator.pushReplacementNamed(location);
  }
}

String getFullUrl({String? baseUrl, required String path}) {
  if (baseUrl == null ||
      (path.startsWith('http://') || path.startsWith('https://'))) {
    return path;
  }
  return '$baseUrl$path';
}
