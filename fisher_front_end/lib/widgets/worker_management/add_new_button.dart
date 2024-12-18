import 'package:flutter/cupertino.dart';

// 新增按鈕
class AddNewButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(15),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add_circled,
              size: 120,
              color: CupertinoColors.activeBlue,
            ),
            SizedBox(height: 10),
            Text(
              "Add New",
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
