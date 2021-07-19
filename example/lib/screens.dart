import 'package:inertia_flutter_example/definitions.dart';
import 'package:inertia_flutter_example/pages/contacts.dart';
import 'package:inertia_flutter_example/pages/dashboard.dart';
import 'package:inertia_flutter_example/pages/login.dart';
import 'package:inertia_flutter_example/pages/organisations.dart';
import 'package:inertia_flutter_example/pages/reports.dart';

final ScreensMap screens = {
  'Auth/Login': (_, __) => LoginPage(),
  'Dashboard/Index': (_, __) => DashboardPage(),
  'Organizations/Index': (_, props) => OrganizationsScreen.fromProps(props),
  'Contacts/Index': (_, props) => ContactsScreen.fromProps(props),
  'Reports/Index': (_, __) => ReportsScreen(),
};
