import 'package:flutter/cupertino.dart';

class DatePicker extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onUpdateDate;
  const DatePicker({
    super.key,
    required this.date,
    required this.onUpdateDate,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          onPressed: () => setState(() {
            _date = _date.subtract(const Duration(days: 1));
            widget.onUpdateDate(_date);
          }),
          child: const SizedBox(
            child: Icon(
              CupertinoIcons.left_chevron,
              size: 30,
            ),
          ),
        ),
        CupertinoButton(
            child: Text('${_date.month}-${_date.day}-${_date.year}',
                style: const TextStyle(
                  fontSize: 30,
                )),
            onPressed: () => _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: _date,
                    mode: CupertinoDatePickerMode.date,
                    // This shows day of week alongside day of month
                    showDayOfWeek: true,
                    // This is called when the user changes the date.
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() => _date = newDate);
                      widget.onUpdateDate(_date);
                    },
                  ),
                )),
        CupertinoButton(
          onPressed: () => setState(() {
            _date = _date.add(const Duration(days: 1));
            widget.onUpdateDate(_date);
          }),
          child: const SizedBox(
            child: Icon(
              CupertinoIcons.right_chevron,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
