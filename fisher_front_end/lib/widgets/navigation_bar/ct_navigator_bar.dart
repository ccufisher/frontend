import 'package:flutter/cupertino.dart';

class CTNavigatorBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final bool hasNotification;
  // State to control the red dot visibility
  const CTNavigatorBar({super.key, required this.hasNotification});

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
      useRootNavigator: false,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // navigate to ct page
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44.0);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => _showDialog(context),
          child: const SizedBox(child: Icon(CupertinoIcons.back)),
        ),
        middle: const Text('Wokring Hour Management'),
        trailing: Stack(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pushNamed(context, 'ctNavList');
                // _toggleNotification();
              },
              child: const SizedBox(
                child: Icon(CupertinoIcons.settings),
              ),
            ),
            if (hasNotification) // Show red dot if notification exists
              Positioned(
                right: 4, // Adjust position relative to the icon
                top: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ));
  }
}
