import 'package:flutter/material.dart';
import 'package:inertia_flutter_example/constants.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unknown Screen'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SPACING_UNIT * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Text('This screen is not yet available.')),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '',
                  (route) => false,
                ),
                child: Text('Go home'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
