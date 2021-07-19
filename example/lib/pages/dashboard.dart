import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inertia_flutter_example/components/drawer.dart';
import 'package:inertia_flutter_example/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(SPACING_UNIT * 4),
        child: RichText(
          text: TextSpan(
            style: textTheme.bodyText2,
            children: [
              TextSpan(
                text:
                    'Hey there! Welcome to Ping CRM, a demo app designed to help illustrate how ',
              ),
              TextSpan(
                text: 'Inertia.js',
                style: textTheme.bodyText2?.copyWith(
                  color: colorScheme.primaryVariant,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch(
                        'https://inertiajs.com',
                      ),
              ),
              TextSpan(
                text: ' works.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
