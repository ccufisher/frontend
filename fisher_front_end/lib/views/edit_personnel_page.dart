import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditPersonnelPage extends StatefulWidget {
  final Map<String, String> person;
  final List<String> existingNumbers; // 傳入已有的編號列表
  final VoidCallback onDelete;
  final Function(Map<String, String>) onSave; // 添加保存回調

  const EditPersonnelPage({
    super.key,
    required this.person,
    required this.existingNumbers,
    required this.onDelete,
    required this.onSave,
  });

  @override
  EditPersonnelPageState createState() => EditPersonnelPageState();
}

class EditPersonnelPageState extends State<EditPersonnelPage> {
  late TextEditingController nameController;
  late TextEditingController passportController;
  late TextEditingController countryController;
  late TextEditingController roleController;
  late TextEditingController ageController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  File? _image; // 用來存儲選擇的圖片
  // 當用戶選擇圖片時觸發此方法
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 保存選擇的圖片
      });
    }
  }

  // // Work Type 選擇值
  String selectedWorkType = ""; // 初始工種設置
  final List<String> workTypes = [
    "fisherman",
    "deckhand",
    "fish processor",
    "engineer",
    "chef"
  ];

  // 用於顯示錯誤訊息的布林值
  bool isNameEmpty = false;
  // bool isPasswordEmpty = false;
  // bool isConfirmPasswordEmpty = false;
  bool isPasswordDifferent = false;
  bool _obscureText = true; // 默認隱藏密碼
  bool isAgeEmpty = false;
  bool isCountryEmpty = false;
  bool isPassportEmpty = false;
  bool _isLoading = true; // 加入加載狀態變數

  @override
  void initState() {
    super.initState();
    _fetchWorkerDetails(); // 呼叫 API 請求
  }

  Future<void> _fetchWorkerDetails() async {
    try {
      setState(() {
        _isLoading = true; //開始加載
      });
      // 從 widget.person['number'] 獲取工人 ID
      final workerId = widget.person['number'];
      if (workerId == null || workerId.isEmpty) {
        // print('錯誤: workerId 為空');
        return;
      }

      // 發送 GET 請求
      final response = await http.get(
        Uri.parse('http://35.229.208.250:3000/api/workerEdit/$workerId'),
      );

      if (response.statusCode == 200) {
        // 成功取得資料
        final data = json.decode(response.body);
        setState(() {
          // 使用 API 返回的資料初始化控制器
          nameController = TextEditingController(text: data['name'] ?? '');
          passportController = TextEditingController(text: data['passport_number'] ?? '');
          countryController = TextEditingController(text: data['country'] ?? '');
          roleController = TextEditingController(text: data['job_title'] ?? '');
          passwordController = TextEditingController();
          confirmPasswordController = TextEditingController();
          ageController = TextEditingController(text: data['age']?.toString() ?? '');
          selectedWorkType = data['job_title'] ?? "Select Work Type";

          // 初始化圖片
          _image = data['profilePhoto'] != null ? File(data['profilePhoto']) : null;
          _isLoading = false; // 結束加載
        });
      } else {
        // print('錯誤: 無法獲取工人資料 (狀態碼: ${response.statusCode})');
        setState(() {
          _isLoading = false; // 結束加載
        });
      }
    } catch (e) {
      // print('例外錯誤: $e');
      setState(() {
        _isLoading = false; // 結束加載
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // 初始化每個 TextEditingController，並設置初始值
  //   nameController = TextEditingController(text: widget.person['name']);
  //   passportController = TextEditingController(text: widget.person['passport']);
  //   countryController = TextEditingController(text: widget.person['country']);
  //   roleController = TextEditingController(text: widget.person['role']);
  //   ageController = TextEditingController(text: widget.person['age']);
  //   passwordController = TextEditingController();
  //   confirmPasswordController = TextEditingController();
  //   // 初始化 selectedWorkType 為 person 資料中的工種（假設 'workType' 是 map 的一部分）
  //   selectedWorkType = widget.person['role'] ??
  //       "Select Work Type"; // 若 person 沒有 'workType'，則設為預設值
  //   // 初始化圖片為當前資料的圖片（如果有的話）
  //   _image =
  //   widget.person['image'] != "" ? File(widget.person['image']!) : null;
  // }

  @override
  void dispose() {
    // 釋放 TextEditingController 資源
    nameController.dispose();
    passportController.dispose();
    countryController.dispose();
    roleController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // *** 新增方法：檢查必填欄位並提示錯誤 ***
  Future<void> validateAndAdd() async {
    setState(() {
      isNameEmpty = nameController.text.trim().isEmpty;
      isAgeEmpty = ageController.text.trim().isEmpty;
      isPassportEmpty = passportController.text.trim().isEmpty;
      isCountryEmpty = countryController.text.trim().isEmpty;
      // 確認密碼是否一致
      if (passwordController.text != confirmPasswordController.text) {
        isPasswordDifferent = true;
      } else {
        isPasswordDifferent = false;
      }
    });

    // 檢查必填欄位是否完整
    if (!isNameEmpty &&
        !isPasswordDifferent &&
        !isAgeEmpty &&
        !isCountryEmpty &&
        !isPassportEmpty) {
      // 構建要發送的資料
      Map<String, dynamic> updatedPerson = {
        "name": nameController.text,
        "passport_number": passportController.text,
        "country": countryController.text,
        "age": ageController.text,
        "job_title": selectedWorkType,
        // "pattern": passwordController.text.isEmpty
        //     ? widget.person['password'] ?? "" // 如果密碼未輸入，保留原密碼
        //     : passwordController.text,
        "profilePhoto": _image?.path, // 設定為 null 或路徑
      };

      if (passwordController.text.trim().isNotEmpty) {
        updatedPerson["pattern"] = passwordController.text.trim();
      }

      try {
        final workerId = widget.person['number']; // 從 person 獲取 workerId

        // 發送 PATCH 請求
        final response = await http.patch(
          Uri.parse('http://35.229.208.250:3000/api/workerEdit/$workerId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedPerson),
        );

        if (response.statusCode == 200) {
          // 調用保存回調，更新本地資料
          Map<String, String> sanitizedData = updatedPerson.map((key, value) {
            return MapEntry(key, value?.toString() ?? "");
          });
          widget.onSave(sanitizedData);

          // 返回上一頁
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // print('更新失敗: ${response.statusCode}');
        }
      } catch (e) {
        // print('發生錯誤: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // 返回鍵
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          // *** 新增左側返回按鈕 ***
          padding: EdgeInsets.zero, // 移除默認內邊距
          child: const Icon(
            CupertinoIcons.back, // 返回圖標
            size: 30, // 返回圖標大小
          ),
          onPressed: () {
            Navigator.pop(context); // 返回上一頁
          },
        ),
      ),
      child: _isLoading
          ? const Center(
        child: CupertinoActivityIndicator(
          radius: 20, // 加載指示器大小
        ),
      )
          : SingleChildScrollView(
            // 滾動視窗
            child: Padding(
              padding: const EdgeInsets.all(80),
              child: Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero, // 去掉預設的 padding
                    onPressed: _pickImage, // 點擊後選擇圖片
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CupertinoColors.systemGrey5,
                      ),
                      child: _image == null
                          ? const Icon(CupertinoIcons.photo, size: 50) // 預設顯示圖標
                          : ClipOval(
                        child: Image.file(
                          _image!, // 顯示選擇的圖片
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 之後都是輸入框
                  _buildTextField(
                    controller: nameController,
                    placeholder: "Name",
                    isEmpty: isNameEmpty,
                  ),

                  //age
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: ageController,
                    placeholder: "Age",
                    isEmpty: isAgeEmpty,
                  ),

                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: passportController,
                    placeholder: "Passport",
                    isEmpty: isPassportEmpty,
                  ),

                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: countryController,
                    placeholder: "Country",
                    isEmpty: isCountryEmpty,
                  ),

                  const SizedBox(height: 10),
                  //輸入密碼
                  _buildPasswordField(
                    controller: passwordController,
                    placeholder: "Enter password",
                    // isEmpty: isPasswordEmpty,
                    isDifferent: isPasswordDifferent,
                  ),
                  // _buildTextField(
                  //   controller: passwordController,
                  //   placeholder: "Enter password",
                  //   // isEmpty: isPasswordEmpty,
                  //   isDifferent: isPasswordDifferent,
                  //   isPassword: true,
                  // ),
                  const SizedBox(height: 10),
                  //確認密碼
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    placeholder: "Confirm password",
                    // isEmpty: isConfirmPasswordEmpty,
                    isDifferent: isPasswordDifferent,
                  ),
                  // _buildTextField(
                  //   controller: confirmPasswordController,
                  //   placeholder: "Confirm password",
                  //   // isEmpty: isConfirmPasswordEmpty,
                  //   isDifferent: isPasswordDifferent,
                  //   isPassword: true, // 標記這是密碼輸入框
                  // ),
                  const SizedBox(height: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero, // 去除內邊距
                    onPressed: () => _showWorkTypePicker(context),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: CupertinoColors.lightBackgroundGray, // 否則顯示灰色邊框
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 紅色米字號
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              '*',
                              style: TextStyle(
                                color: CupertinoColors.destructiveRed,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // 顯示選擇的工作類型或默認文本
                          Expanded(
                            child: Text(
                              selectedWorkType,
                              style: const TextStyle(
                                fontSize: 24,
                                color: CupertinoColors.black, // 選擇後顯示黑色
                              ),
                            ),
                          ),
                          // 下拉箭頭圖標
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 24,
                            color: CupertinoColors.systemGrey, // 默認灰色箭頭
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CupertinoTextField(
                  //   placeholder: "Work Type",
                  //   controller: roleController,
                  //   padding: const EdgeInsets.all(30),
                  //   style: const TextStyle(fontSize: 24), //字體大小
                  // ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton.filled(
                        //
                        onPressed: validateAndAdd,
                        child: const Text(
                          "OK",
                          style: TextStyle(fontSize: 24), // OK 按鈕文字大小
                        ),
                      ),

                      // 刪除後確認是否要刪除
                      CupertinoButton(
                        color: CupertinoColors.destructiveRed,
                        child: const Text(
                          "Delete",
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Are you sure?', style: TextStyle(fontSize: 30)),
                              content: const Text(
                                'Do you really want to delete this person?',
                                style: TextStyle(fontSize: 20),
                              ),
                              actions: [
                                // 取消按鈕
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No', style: TextStyle(fontSize: 20)),
                                ),
                                // 確定刪除按鈕
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    Navigator.pop(context); // 關閉彈窗
                                    final workerId = widget.person['number']; // 獲取 worker_id
                                    if (workerId != null && workerId.isNotEmpty) {
                                      try {
                                        final response = await http.delete(
                                          Uri.parse('http://35.229.208.250:3000/api/workerEdit/$workerId'),
                                        );

                                        if (response.statusCode == 200) {
                                          // print('工人資料已成功刪除');
                                          widget.onDelete(); // 執行刪除回調
                                          if (mounted) {
                                            // Navigator.pop(context); // 返回上一頁
                                          }
                                        } else {
                                          // print('刪除失敗: ${response.statusCode}');
                                        }
                                      } catch (e) {
                                        // print('刪除時發生錯誤: $e');
                                      }
                                    } else {
                                      // print('錯誤: 無效的 workerId');
                                    }
                                  },
                                  child: const Text('Yes', style: TextStyle(fontSize: 20)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // 通用有米字號的輸入格
  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool isEmpty = false,
    bool isDuplicate = false,
    // bool isDifferent = false,
    // bool isPassword = false, //確認是否為密碼輸入格
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          placeholder: placeholder,
          controller: controller,
          // obscureText: isPassword ? _obscureText : false, // 只有密碼框隱藏文本
          padding: const EdgeInsets.only(top: 30, bottom: 30, left: 10),
          style: const TextStyle(
            fontSize: 24,
            color: CupertinoColors.black,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEmpty || isDuplicate
                  ? CupertinoColors.destructiveRed // 如果為空或重複，顯示紅色邊框
                  : CupertinoColors.lightBackgroundGray, // 否則顯示灰色邊框
              width: 2,
            ),
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '*', // 紅色米字號
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String placeholder,
    // bool isEmpty = false,
    bool isDifferent = false, // 密碼不一致
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          placeholder: placeholder,
          controller: controller,
          obscureText: _obscureText, // 密碼隱藏
          padding: const EdgeInsets.only(top: 30, bottom: 30, left: 10),
          style: const TextStyle(
            fontSize: 24,
            color: CupertinoColors.black,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDifferent
                  ? CupertinoColors.destructiveRed // 密碼錯誤顯示紅色邊框
                  : CupertinoColors.lightBackgroundGray, // 否則顯示灰色邊框
              width: 2,
            ),
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // 切換顯示/隱藏密碼
              });
            },
            child: Icon(
              _obscureText
                  ? CupertinoIcons.eye_slash // 密碼隱藏
                  : CupertinoIcons.eye, // 密碼顯示
              color: CupertinoColors.inactiveGray,
            ),
          ),
        ),
        // 如果密碼不一致，顯示錯誤訊息
        if (isDifferent)
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 5),
            child: Text(
              'Passwords do not match',
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  // 顯示 Work Type 選單
  void _showWorkTypePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50, // 每個選項的高度
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedWorkType = workTypes[index];
                  });
                },
                children: workTypes
                    .map((type) => Center(
                  child: Text(
                    type,
                    style: const TextStyle(fontSize: 24),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}