import 'package:flutter/cupertino.dart';
import 'package:fisher_front_end/widgets/crew_view/crew_info.dart';
import 'package:fisher_front_end/widgets/crew_view/crew_calendar.dart';

class CrewPage extends StatefulWidget {
  const CrewPage({super.key});

  @override
  State<CrewPage> createState() => _CrewPageState();
}

class _CrewPageState extends State<CrewPage> {
  // 假設這裡有 workerId
  final int workerId = 10; // 請根據實際情況替換為真實的 workerId

  void logout(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Crew Info'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            showCupertinoDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Log Out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Confirm'),
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Return to the previous page
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              // Pass in workerId
              child: CrewInfo(workerId: workerId),
            ),
            Expanded(
              flex: 3,
              // Pass in workerId
              child: CrewCalendar(workerId: workerId),
            ),
          ],
        ),
      ),
    );
  }
}
