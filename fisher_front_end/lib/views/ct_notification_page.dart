import 'package:flutter/cupertino.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

class CtNotificationPage extends StatefulWidget {
  const CtNotificationPage({super.key});

  @override
  State<CtNotificationPage> createState() => _CtNotificationPageState();
}

class _CtNotificationPageState extends State<CtNotificationPage> {
  // Sample list of notifications
  List<Map<String, dynamic>> notifications = [
    // {
    //   "title": "New Message",
    //   "message": "You have received a new message.",
    // },
  ];

  Future<void> callDeleteNotification(int index) async {
    final url = Uri.parse(
        'http://35.229.208.250:3000/api/CTManagementPage/cancel-notification/$index');

    try {
      // Send the DELETE request
      final response = await http.delete(url);

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Data deleted successfully.');
      } else {
        debugPrint(
            'Failed to delete data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred while deleting data: $e');
    }
  }

  Future<void> _getNotificationList() async {
    try {
      String url =
          'http://35.229.208.250:3000/api/CTManagementPage/notifications';
      // Send the GET request
      final response = await http.get(Uri.parse(url));

      // Check if the response status code indicates success
      if (response.statusCode == 200) {
        // Decode and handle the JSON response
        final data = jsonDecode(response.body);
        setState(() {
          for (final e in data) {
            notifications.add({'index': e['index'], 'message': e['content']});
          }
        });
        debugPrint('Response Data: $data');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    setState(() {
      for (final element in notifications) {
        if (element['index'] == notification['index']) {
          notifications.remove(element);
        }
      }
    });
    callDeleteNotification(notification['index']);
    debugPrint('noti len = ${notifications.length.toString()}');
  }

  @override
  void initState() {
    _getNotificationList();
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
            child: notifications.isNotEmpty
                // case when there is notifications
                ? CupertinoListSection.insetGrouped(
                    children: [
                      for (final notification in notifications)
                        CupertinoListTile(
                          leading: const SizedBox(),
                          title: Text(notification['message']),
                          subtitle: Text(
                              'Notification index: ${notification['index'].toString()}'),
                          trailing: CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: CupertinoColors.destructiveRed,
                            ),
                            onPressed: () => _deleteNotification(notification),
                          ),
                        )
                    ],
                  )
                // case when there is no notifications
                : const Center(child: Text('There is no notifications left'))));
  }
}
