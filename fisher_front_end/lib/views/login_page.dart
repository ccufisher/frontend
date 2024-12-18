import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 使用者角色與輸入框變數
  String selectedRole = 'Captain'; // 預設選擇 Captain
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 登錄按鈕邏輯
  Future<void> _login() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    // 根據選擇的角色切換 API URL
    final String endpoint = selectedRole == 'Captain'
        ? 'http://35.229.208.250:3000/api/loginPage/captainLogin'
        : 'http://35.229.208.250:3000/api/loginPage/workerLogin';

    final body = jsonEncode({
      'username': username,
      'pattern': password,
    });

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return; // 確保 Widget 仍然存在

      if (response.statusCode == 200) {
        // 登錄成功邏輯
        Navigator.pushNamed(
          context,
          selectedRole == 'Captain' ? 'captainPage' : 'crewPage',
        );
      } else {
        _showErrorDialog('Invalid username or password.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  // 顯示錯誤訊息的彈窗
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Captain 和 Worker 選擇按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleButton('Captain'),
                  _roleButton('Worker'),
                ],
              ),
              const SizedBox(height: 35),
              // 用戶名輸入框
              _inputField('Username', usernameController, false),
              const SizedBox(height: 15),
              // 密碼輸入框
              _inputField('Password', passwordController, true),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(50)), // 設定圓角
                  child: CupertinoButton.filled(
                    onPressed: _login,
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 建立 Captain 和 Worker 選擇按鈕
  Widget _roleButton(String role) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        decoration: BoxDecoration(
          color: selectedRole == role
              ? CupertinoColors.activeBlue
              : CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.only(
            topLeft: role == 'Captain'
                ? const Radius.circular(100)
                : Radius.zero,
            bottomLeft: role == 'Captain'
                ? const Radius.circular(100)
                : Radius.zero,
            topRight: role == 'Worker'
                ? const Radius.circular(100)
                : Radius.zero,
            bottomRight: role == 'Worker'
                ? const Radius.circular(100)
                : Radius.zero,
          ),
        ),
        child: Text(
          role,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: selectedRole == role
                ? CupertinoColors.white
                : CupertinoColors.black,
          ),
        ),
      ),
    );
  }

  // 建立輸入框
  Widget _inputField(
      String placeholder, TextEditingController controller, bool obscureText) {
    return SizedBox(
      height: 70,
      width: 500,
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        obscureText: obscureText,
        decoration: BoxDecoration(
          color: CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.circular(80),
        ),
        style: const TextStyle(fontSize: 30),
      ),
    );
  }
}
