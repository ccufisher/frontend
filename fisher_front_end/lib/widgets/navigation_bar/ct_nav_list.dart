import 'package:flutter/cupertino.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

class CTNavList extends StatefulWidget {
  const CTNavList({super.key});

  @override
  State<CTNavList> createState() => _CTNavListState();
}

class _CTNavListState extends State<CTNavList> {
  int notificationCount = 0;

  Future<void> _getNotificationCount() async {
    try {
      String url =
          'http://35.229.208.250:3000/api/CTManagementPage/notification-count';
      // Send the GET request
      final response = await http.get(Uri.parse(url));

      // Check if the response status code indicates success
      if (response.statusCode == 200) {
        // Decode and handle the JSON response
        setState(() {
          notificationCount = jsonDecode(response.body)['notifications'];
        });
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  @override
  void initState() {
    _getNotificationCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => Navigator.pop(context),
          child: const SizedBox(child: Icon(CupertinoIcons.back)),
        ),
      ),
      child: SafeArea(
        child: CupertinoListSection.insetGrouped(
          header: const Text('Management'),
          children: [
            CupertinoListTile.notched(
              title: const Text('Working Hour Management'),
              leading: Container(
                width: double.infinity,
                height: double.infinity,
                color: CupertinoColors.activeGreen,
              ),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            CupertinoListTile.notched(
              title: const Text('Worker Management'),
              leading: Container(
                width: double.infinity,
                height: double.infinity,
                color: CupertinoColors.activeOrange,
              ),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.pushNamed(context, 'workerManagementPage');
              },
            ),
            CupertinoListTile.notched(
              title: const Text('Notifications'),
              leading: Container(
                width: double.infinity,
                height: double.infinity,
                color: CupertinoColors.systemRed,
              ),
              trailing: Row(
                children: [
                  Text('$notificationCount'),
                  const SizedBox(width: 10),
                  const Icon(CupertinoIcons.right_chevron)
                ],
              ),
              onTap: () => Navigator.pushNamed(context, 'ctNotificationPage'),
            ),
          ],
        ),
      ),
    );
  }
}
