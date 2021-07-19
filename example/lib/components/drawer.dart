import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Ping CRM'),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacementNamed('');
            },
          ),
          ListTile(
            title: Text('Organizations'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacementNamed('organizations');
            },
          ),
          ListTile(
            title: Text('Contacts'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacementNamed('contacts');
            },
          ),
          ListTile(
            title: Text('Reports'),
            onTap: () {
              navigator.pop();
              navigator.pushReplacementNamed('reports');
            },
          ),
        ],
      ),
    );
  }
}
