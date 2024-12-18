import 'package:flutter/cupertino.dart';

class WorkingHourPicker extends StatefulWidget {
  final List<int> timeSelected;
  final Function(List<int>) onSetWorkingHour;
  const WorkingHourPicker({
    super.key,
    required this.timeSelected,
    required this.onSetWorkingHour,
  });

  @override
  State<WorkingHourPicker> createState() => _WorkingHourPickerState();
}

class _WorkingHourPickerState extends State<WorkingHourPicker> {
  List<int> state = List.generate(48, (index) => 0);

  void _toggleTime12(int index) {
    index = index;
    setState(() {
      state[index] += 1;
      if (state[index] > 2) state[index] = 0;
    });
  }

  void _toggleTime24(int index) {
    index = index + 24;
    setState(() {
      state[index] += 1;
      if (state[index] > 2) state[index] = 0;
    });
  }

  Color _getColor(int stateValue) {
    switch (stateValue) {
      case 0:
        return CupertinoColors.systemGrey4;
      case 1:
        return CupertinoColors.activeBlue;
      case 2:
        return CupertinoColors.activeGreen;
      default:
        throw UnimplementedError("State value $stateValue not handled");
    }
  }

  @override
  void initState() {
    state = widget.timeSelected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WorkingHourPicker oldWidget) {
    // debugPrint('${widget.timeSelected}');
    if (state != widget.timeSelected) {
      state = widget.timeSelected;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('move');
    return Column(
      children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              12,
              (index) {
                return Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '$index',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      width: 40,
                    ),
                  ],
                );
              },
            )),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              24,
              (index) {
                return Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _getColor(state[index]),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () => _toggleTime12(index),
                    child: const SizedBox(),
                  ),
                );
              },
            )),
        const SizedBox(height: 10),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              12,
              (index) {
                return Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '${index + 12}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      width: 40,
                    ),
                  ],
                );
              },
            )),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              24,
              (index) {
                return Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _getColor(state[index + 24]),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () => _toggleTime24(index),
                    child: const SizedBox(),
                  ),
                );
              },
            )),
      ],
    );
  }
}
