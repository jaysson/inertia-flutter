import 'package:flutter/material.dart';
import 'package:inertia_flutter_example/components/drawer.dart';
import 'package:inertia_flutter_example/constants.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(SPACING_UNIT * 4),
        child: Center(child: Text("Coming soon!")),
      ),
    );
  }
}
