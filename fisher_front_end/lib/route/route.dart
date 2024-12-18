import 'package:fisher_front_end/views/add_people.dart';
import 'package:fisher_front_end/views/captain_page.dart';
import 'package:fisher_front_end/views/crew_page.dart';
import 'package:fisher_front_end/views/ct_notification_page.dart';
import 'package:fisher_front_end/views/edit_personnel_page.dart';
import 'package:fisher_front_end/views/login_page.dart';
import 'package:fisher_front_end/views/worker_management_page.dart';
import 'package:fisher_front_end/widgets/navigation_bar/ct_nav_list.dart';
import 'package:flutter/cupertino.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case 'captainPage':
      return CupertinoPageRoute(builder: (context) => const CaptainPage());
    case 'ctNavList':
      return CupertinoPageRoute(builder: (context) => const CTNavList());
    case 'ctNotificationPage':
      return CupertinoPageRoute(
          builder: (context) => const CtNotificationPage());
    case 'loginPage':
      return CupertinoPageRoute(builder: (context) => const LoginPage());
    case 'crewPage':
      return CupertinoPageRoute(builder: (context) => const CrewPage());
    case 'workerManagementPage':
      return CupertinoPageRoute(
          builder: (context) => const WorkerManagementPage());
    case 'addPersonnelPage':
      final args = settings.arguments as Map<String, dynamic>;
      return CupertinoPageRoute(
        builder: (context) => AddPersonnelPage(
          onAdd: args['onAdd'],
          existingNumbers: args['existingNumbers'],
        ),
      );
    case 'editPersonnelPage':
      final args = settings.arguments as Map<String, dynamic>;
      return CupertinoPageRoute(
        builder: (context) => EditPersonnelPage(
          person: args['person'],
          onDelete: args['onDelete'],
          onSave: args['onSave'],
          existingNumbers: args['existingNumbers'],
        ),
      );

    default:
      return CupertinoPageRoute(
          builder: (context) => const LoginPage()); // Default fallback
  }
}
