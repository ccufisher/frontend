import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'signature_pad.dart';

class CrewCalendar extends StatefulWidget {
  final int workerId;
  const CrewCalendar({super.key, required this.workerId});

  @override
  State<CrewCalendar> createState() => _CrewCalendarState();
}

class _CrewCalendarState extends State<CrewCalendar> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    try {
      final data = await _getMonthlyCalendar(
          widget.workerId, selectedYear, selectedMonth);
      setState(() {
        monthlyData = data;
      });
    } catch (e) {
      setState(() {
        monthlyData = [];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getMonthlyCalendar(
      int workerId, int year, int month) async {
    final url =
        'http://35.229.208.250:3000/api/workerPage/calendar/$workerId/$year/$month';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      int daysInMonth = _getDaysInMonth(year, month);
      List<Map<String, dynamic>> convertedData = [];
      for (int i = 1; i <= daysInMonth; i++) {
        final dateStr = _formatDate(year, month, i);
        convertedData.add({'date': dateStr, 'hours': 0});
      }

      if (data is List) {
        for (var entry in data) {
          if (entry['date'] != null && entry['duration'] != null) {
            final dateStr = entry['date'];
            final hours = entry['duration'];
            final index = convertedData.indexWhere((d) => d['date'] == dateStr);
            if (index != -1) {
              convertedData[index]['hours'] = hours;
            }
          }
        }
      }

      return convertedData;
    } else {
      throw Exception('Failed to load monthly calendar');
    }
  }

  Future<void> _reportAbnormality(
      int workerId, String date, String issueDescription) async {
    final response = await http.post(
      Uri.parse('http://35.229.208.250:3000/api/workerPage/newReport'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "worker_id": workerId,
        "date": date,
        "issue_description": issueDescription
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to report abnormality');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.left_chevron),
                onPressed: () {
                  setState(() {
                    if (selectedMonth == 1) {
                      selectedMonth = 12;
                      selectedYear--;
                    } else {
                      selectedMonth--;
                    }
                  });
                  _loadMonthlyData();
                },
              ),
              CupertinoButton(
                child: Row(
                  children: [
                    Text(
                      '$selectedYear ${_getMonthName(selectedMonth)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black),
                    ),
                    const SizedBox(width: 10),
                    const Icon(CupertinoIcons.chevron_down),
                  ],
                ),
                onPressed: () => _showPicker(context),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.right_chevron),
                onPressed: () {
                  setState(() {
                    if (selectedMonth == 12) {
                      selectedMonth = 1;
                      selectedYear++;
                    } else {
                      selectedMonth++;
                    }
                  });
                  _loadMonthlyData();
                },
              ),
            ],
          ),
        ),
        // Weekday header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Sun', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
    int firstWeekday = _getFirstWeekdayOfMonth(selectedYear, selectedMonth);
    int totalCells = ((daysInMonth + firstWeekday - 1) / 7).ceil() * 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        double gridHeight = constraints.maxHeight;
        double cellMargin = 1.0;
        double cellWidth = (gridWidth - cellMargin * 2 * 7) / 7;
        int numberOfRows = (totalCells / 7).ceil();
        double cellHeight =
            (gridHeight - cellMargin * 2 * numberOfRows) / numberOfRows;

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: cellWidth / cellHeight,
            crossAxisSpacing: cellMargin * 2,
            mainAxisSpacing: cellMargin * 2,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            int dayNum = index - firstWeekday + 2;
            if (index < firstWeekday - 1 || dayNum > daysInMonth) {
              return Container(margin: EdgeInsets.all(cellMargin));
            } else {
              final dateStr = _formatDate(selectedYear, selectedMonth, dayNum);
              final dayData = monthlyData
                  .firstWhere((d) => d['date'] == dateStr, orElse: () => {});
              String info = '';
              if (dayData.isNotEmpty &&
                  dayData['hours'] != null &&
                  dayData['hours'] > 0) {
                info = '${dayData['hours']}h';
              }
              return GestureDetector(
                onTap: () {
                  _showDayDetail(context, dayNum);
                },
                child: Container(
                  margin: EdgeInsets.all(cellMargin),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$dayNum'),
                      if (info.isNotEmpty)
                        Text(info, style: const TextStyle(fontSize: 12))
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showPicker(BuildContext context) {
    int tempYear = selectedYear;
    int tempMonth = selectedMonth;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      selectedYear = tempYear;
                      selectedMonth = tempMonth;
                    });
                    Navigator.pop(context);
                    _loadMonthlyData();
                  },
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: tempYear - 2000,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        tempYear = 2000 + index;
                      },
                      children: List<Widget>.generate(50, (int index) {
                        return Center(child: Text('${2000 + index}'));
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: tempMonth - 1,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        tempMonth = index + 1;
                      },
                      children: List<Widget>.generate(12, (int index) {
                        return Center(child: Text(_getMonthName(index + 1)));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, int day) {
    final dateStr = _formatDate(selectedYear, selectedMonth, day);
    final dayData =
        monthlyData.firstWhere((d) => d['date'] == dateStr, orElse: () => {});
    final hoursInfo =
        (dayData.isNotEmpty && dayData['hours'] != null && dayData['hours'] > 0)
            ? '${dayData['hours']} hours'
            : 'No data available';

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('$selectedYear-$selectedMonth-$day'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Text('Working hours for the day: $hoursInfo'),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('Sign Now'),
              onPressed: () {
                Navigator.pop(context);
                _showSignaturePad(context, day);
              },
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('Report Hours Error'),
              onPressed: () async {
                Navigator.pop(context);
                const issueDescription = 'Incorrect hours recorded.';
                try {
                  await _reportAbnormality(
                      widget.workerId, dateStr, issueDescription);
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Report Success'),
                      content: const Text(
                          'The hours error was successfully reported.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  );
                } catch (e) {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Report Failed'),
                      content: Text('Error: $e'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  );
                }
              },
            )
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSignaturePad(BuildContext context, int day) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SignaturePad(
          date: _formatDate(selectedYear, selectedMonth, day),
          workerId: widget.workerId,
        ),
      ),
    );
  }

  int _getFirstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    } else {
      return DateTime(year, month + 1, 0).day;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDate(int year, int month, int day) {
    final m = month < 10 ? '0$month' : '$month';
    final d = day < 10 ? '0$day' : '$day';
    return '$year-$m-$d';
  }
}
