import 'package:flutter/cupertino.dart';

class IdCard extends StatefulWidget {
  final int workerID;
  final Image workerImage;
  final String workerName;
  final String workerType;
  final bool isRecorded;
  final Function(int) onWorkerSelect;
  const IdCard(
      {super.key,
      required this.workerID,
      required this.workerImage,
      required this.workerName,
      required this.workerType,
      required this.isRecorded,
      required this.onWorkerSelect});

  @override
  State<IdCard> createState() => _IdCardState();
}

class _IdCardState extends State<IdCard> {
  bool _isHighlighted = false;
  bool _isRecorded = false;
  Image _workerHeadImage = Image.asset('default.png');
  late String _workerName;
  late String _workerType;

  @override
  void initState() {
    _workerHeadImage = widget.workerImage;
    _workerName = widget.workerName;
    _workerType = widget.workerType;
    _isRecorded = widget.isRecorded;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IdCard oldWidget) {
    if (_isRecorded != widget.isRecorded) {
      setState(() {
        _isRecorded = widget.isRecorded;
        _isHighlighted = false;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggleHighlight() {
    setState(() {
      _isHighlighted = !_isHighlighted; // Toggle highlight state
      widget.onWorkerSelect(widget.workerID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        width: 300,
        foregroundDecoration: _isRecorded
            ? const BoxDecoration(
                color: CupertinoColors.systemGrey,
                backgroundBlendMode: BlendMode.saturation,
              )
            : null,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: _isHighlighted
                ? CupertinoColors.activeBlue // Highlight color
                : CupertinoColors.systemGrey4, // Default border color
            width: 2.0,
          ),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          onPressed: _toggleHighlight,
          child: Row(
            children: [
              SizedBox(
                height: 150,
                width: 120,
                child: _workerHeadImage,
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      _workerName,
                      softWrap: false,
                      style: const TextStyle(fontSize: 30),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      _workerType,
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
