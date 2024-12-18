import 'package:fisher_front_end/widgets/ct_view/date_picker.dart';
import 'package:fisher_front_end/widgets/ct_view/id_card.dart';
import 'package:fisher_front_end/widgets/ct_view/working_hour_picker.dart';
import 'package:fisher_front_end/widgets/navigation_bar/ct_navigator_bar.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

class CaptainPage extends StatefulWidget {
  const CaptainPage({super.key});

  @override
  State<CaptainPage> createState() => _CaptainPageState();
}

class _CaptainPageState extends State<CaptainPage> {
  bool _hasNotification = false;
  DateTime date = DateTime.now();
  List<int> workingHour = List.generate(48, (index) => 0);
  // List of items
  List<Map<String, dynamic>> workerList = [];
  // {
  //   "workerID": 1,
  //   "workerName": "Name 1",
  //   "workerType": "Type 1",
  //   "isRecorded": false
  // },

  List<Map<String, dynamic>> workerStatus = [];
  // {
  //   "workerID": 123,
  //   "workingHour": [],
  //   "isSelected": false,
  //   "isRecorded": false
  // }

  Future<void> _getWorkerInfo() async {
    try {
      String url = 'http://35.229.208.250:3000/api/CTManagementPage/employees';
      // Send the GET request
      final response = await http.get(Uri.parse(url));

      // Check if the response status code indicates success
      if (response.statusCode == 200) {
        // Decode and handle the JSON response
        final data = jsonDecode(response.body);
        setState(() {
          for (final e in data) {
            workerList.add({
              'workerID': e['worker_id'],
              'workerName': e['name'],
              'workerType': e['job_title'],
              'isRecorded': false
            });
          }
          for (final e in data) {
            workerStatus.add({
              'workerID': e['worker_id'],
              'workingHour': List.generate(48, (index) => 0),
              'isSelected': false
            });
          }
        });
        debugPrint('Response Data: $data');
      } else {
        debugPrint(
            'Worker data request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  Future<void> _getWorkingHourInfo() async {
    try {
      String url =
          'http://35.229.208.250:3000/api/CTManagementPage/work-hours/${date.year}-${date.month}-${date.day}';
      // Send the GET request
      final response = await http.get(Uri.parse(url));
      debugPrint('work-hours/${date.year}-${date.month}-${date.day}');

      // Check if the response status code indicates success
      if (response.statusCode == 200) {
        // Decode and handle the JSON response
        final data = jsonDecode(response.body);
        for (final e in data) {
          for (int i = 0; i < workerStatus.length; i++) {
            if (e['worker_id'] == workerStatus[i]['workerID']) {
              setState(() {
                workerStatus[i]['workingHour'] = e['working_hour'];
                workerList[i]['isRecorded'] = true;
              });
            }
          }
        }
        debugPrint('Response Data: $data');
      } else {
        debugPrint(
            'Worker data request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  Future<void> _sendData(Map<String, dynamic> data) async {
    final url = Uri.parse(
        'http://35.229.208.250:3000/api/CTManagementPage/register-work-hours');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Save working hour success: ${response.body}');
      } else {
        debugPrint(
            'Save working hour failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // call api to get notification status
  // should be call when first login to working hour management page
  // should be call after every save
  Future<void> _checkNotificationState() async {
    try {
      String url =
          'http://35.229.208.250:3000/api/CTManagementPage/notification-count';
      // Send the GET request
      final response = await http.get(Uri.parse(url));

      // Check if the response status code indicates success
      if (response.statusCode == 200) {
        // Decode and handle the JSON response
        setState(() {
          int notificationCount = jsonDecode(response.body)['notifications'];
          if (notificationCount > 0) {
            _hasNotification = true;
          } else {
            _hasNotification = false;
          }
        });
      } else {
        debugPrint(
            'NotificationCount request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  void _onUpdateDate(DateTime newDate) {
    setState(() {
      date = newDate;
      workingHour = List.generate(48, (index) => 0);
    });
    setState(() {
      workerList = [];
      workerStatus = [];
    });
    _getWorkerInfo();
    _getWorkingHourInfo();
  }

  void _onWorkerSelect(int workerID) {
    // i cant think about any better implementation at the moment :(
    for (Map<String, dynamic> worker in workerStatus) {
      if (worker['workerID'] == workerID) {
        setState(() {
          worker['isSelected'] = !worker['isSelected'];

          // Show selected worker's registered working hour
          // Or else clear the workingHourPicker
          if (worker['isSelected']) {
            workingHour = List<int>.from(worker['workingHour']);
          } else {
            workingHour = List.generate(48, (index) => 0);
          }
        });
        worker['isSelected']
            ? debugPrint('Worker $workerID is selected')
            : debugPrint('Worker $workerID is deselected');
        break;
      }
    }
  }

  void _onSetWorkingHour(List<int> newWorkingHour) {
    setState(() {
      for (int i = 0; i < 48; i++) {
        workingHour[i] = newWorkingHour[i];
      }
    });
  }

  void _onSaveInfo() {
    // template of data
    Map<String, dynamic> data = {
      "workerIDs": [],
      "updateWorkHours": workingHour,
      "date": "${date.year}-${date.month}-${date.day}"
    };

    // setting data
    for (Map<String, dynamic> worker in workerStatus) {
      if (worker['isSelected']) {
        for (Map<String, dynamic> e in workerList) {
          if (e['workerID'] == worker['workerID']) {
            data['workerIDs'].add(e['workerID']);
            setState(() {
              e['isRecorded'] = true;
            });
            break;
          }
        }
        setState(() {
          worker['isSelected'] = false;
        });
      }
    }
    debugPrint('onSaveInfo:');
    debugPrint('${data['workerIDs']}');
    debugPrint('$workingHour');

    // send save through api, get updated state, and clear workingHour
    _sendData(data);
    _getWorkingHourInfo();
    _checkNotificationState();
    workingHour = List.generate(48, (index) => 0);
  }

  @override
  void initState() {
    _getWorkerInfo();
    _getWorkingHourInfo();
    _checkNotificationState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CTNavigatorBar(hasNotification: _hasNotification),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            DatePicker(date: date, onUpdateDate: _onUpdateDate),
            // show workers
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              width: 1200,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5, // Space between rows
                      crossAxisSpacing: 5, // Space between columns
                      childAspectRatio: 2, // Width / Height ratio
                    ),
                    itemCount: workerList.length,
                    itemBuilder: (context, index) => IdCard(
                      workerID: workerList[index]['workerID'],
                      workerImage: Image.asset('default.png'),
                      workerName: workerList[index]['workerName'],
                      workerType: workerList[index]['workerType'],
                      isRecorded: workerList[index]['isRecorded'],
                      onWorkerSelect: _onWorkerSelect,
                    ),
                  )),
            ),
            const SizedBox(height: 10),
            WorkingHourPicker(
              timeSelected: workingHour,
              onSetWorkingHour: _onSetWorkingHour,
            ),
            const SizedBox(height: 30),
            CupertinoButton(
              color: CupertinoColors.systemGrey6,
              onPressed: _onSaveInfo,
              child: const SizedBox(
                height: 40,
                width: 100,
                child: Center(
                  child: Text(
                    'Save data',
                    style: TextStyle(
                        fontSize: 20, color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
