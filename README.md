# Inertia Flutter

Flutter adapter for inertia.js. Know more about inertia on [inertiajs.com](https://inertiajs.com).

## Getting Started

### Installation

Add the dependency to your flutter app:

```yaml
inertia_flutter:
```

### Usage
Set the `Inertia.baseUrl` in your `main.dart`'s `main` function.

```dart
void main() {
  Inertia.baseUrl = 'https://demo.inertiajs.com/';
  runApp(MyApp());
}
```

Update the MaterialApp:
- Set the `navigatorKey` to `Inertia.navigator`
- Return the `Route` with `InertiaScreen` in `onGenerateRoute`
- Implement a `pageMaker`, which displays the appropriate content for loading, success, and error states of a screen. Check the example app for inspiration. 

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    initialRoute: '',
    navigatorKey: Inertia.navigator,
    onGenerateRoute: (route) =>
        MaterialPageRoute(
          builder: (_) =>
              InertiaScreen(
                settings: route,
                pageMaker: _makePage,
              ),
        ),
  );
}
```

### Form helper
Validations should happen on the backend. The form helper helps you with form submissions and server side validation errors.
Please see `example/lib/pages/login.dart` for an example of form helper usage.