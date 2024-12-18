import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPersonnelPage extends StatefulWidget {
  final Function(Map<String, String>) onAdd; // 用於回調新增的資料
  final List<String> existingNumbers; // 現有編號列表

  const AddPersonnelPage({
    super.key,
    required this.onAdd,
    required this.existingNumbers,
  });

  @override
  AddPersonnelPageState createState() => AddPersonnelPageState();
}

class AddPersonnelPageState extends State<AddPersonnelPage> {
  late TextEditingController nameController;
  late TextEditingController passportController;
  late TextEditingController countryController;
  late TextEditingController ageController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String selectedWorkType = "Select Work Type";
  final List<String> workTypes = [
    "Select Work Type",
    "fisherman",
    "deckhand",
    "fish processor",
    "engineer",
    "chef"
  ];

  bool isNameEmpty = false;
  bool isWorkTypeEmpty = false;
  bool isPasswordEmpty = false;
  bool isConfirmPasswordEmpty = false;
  bool isPasswordDifferent = false;
  bool isAgeEmpty = false;
  bool isPassportEmpty = false;
  bool isCountryEmpty = false;
  bool _obscureText = true;
  bool isLoading = false; // 控制加載狀態

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    passportController = TextEditingController();
    countryController = TextEditingController();
    ageController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    passportController.dispose();
    countryController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void validateAndAdd() async {
    setState(() {
      isNameEmpty = nameController.text.trim().isEmpty;
      isAgeEmpty = ageController.text.trim().isEmpty;
      isPassportEmpty = passportController.text.trim().isEmpty;
      isCountryEmpty = countryController.text.trim().isEmpty;
      isPasswordEmpty = passwordController.text.trim().isEmpty;
      isConfirmPasswordEmpty = confirmPasswordController.text.trim().isEmpty;
      isWorkTypeEmpty = selectedWorkType == "Select Work Type";
      isPasswordDifferent = passwordController.text != confirmPasswordController.text;
    });

    if (!isNameEmpty &&
        !isAgeEmpty &&
        !isPassportEmpty &&
        !isCountryEmpty &&
        !isPasswordEmpty &&
        !isConfirmPasswordEmpty &&
        !isWorkTypeEmpty &&
        !isPasswordDifferent) {
      setState(() {
        isLoading = true; // 開始加載
      });

      var requestData = {
        "name": nameController.text,
        "passport_number": passportController.text,
        "country": countryController.text,
        "age": ageController.text,
        "job_title": selectedWorkType,
        "pattern": passwordController.text,
        "profilePhoto": _image?.path ?? "",
      };

      try {
        final response = await http.post(
          Uri.parse('http://35.229.208.250:3000/api/workerEdit/add-worker'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            widget.onAdd(requestData);
            Navigator.pop(context);
          }
        } else {
          // print('Error: ${response.statusCode}');
        }
      } catch (error) {
        // print('Request failed: $error');
      } finally {
        setState(() {
          isLoading = false; // 結束加載
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: isLoading
          ? const Center(
        child: CupertinoActivityIndicator(
          radius: 20, // 加載指示器大小
        ),
      )
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(80),
          child: Column(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.systemGrey5,
                  ),
                  child: _image == null
                      ? const Icon(CupertinoIcons.photo, size: 50)
                      : ClipOval(
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(controller: nameController, placeholder: "Name", isEmpty: isNameEmpty),
              const SizedBox(height: 10),
              // _buildTextField(controller: numberController, placeholder: "Number", isEmpty: isNumberEmpty, isDuplicate: isNumberDuplicate),
              // const SizedBox(height: 10),
              _buildTextField(controller: ageController, placeholder: "Age", isEmpty: isAgeEmpty),
              const SizedBox(height: 10),
              _buildTextField(controller: passportController, placeholder: "Passport", isEmpty: isPassportEmpty),
              const SizedBox(height: 10),
              _buildTextField(controller: countryController, placeholder: "Country", isEmpty: isCountryEmpty),
              const SizedBox(height: 10),
              _buildTextField(controller: passwordController, placeholder: "Enter password", isEmpty: isPasswordEmpty, isDifferent: isPasswordDifferent, isPassword: true),
              const SizedBox(height: 10),
              _buildTextField(controller: confirmPasswordController, placeholder: "Confirm password", isEmpty: isConfirmPasswordEmpty, isDifferent: isPasswordDifferent, isPassword: true),
              const SizedBox(height: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showWorkTypePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isWorkTypeEmpty
                          ? CupertinoColors.destructiveRed
                          : CupertinoColors.lightBackgroundGray,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
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
                      Expanded(
                        child: Text(
                          selectedWorkType,
                          style: TextStyle(
                            fontSize: 24,
                            color: selectedWorkType == "Select Work Type"
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 24,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                onPressed: validateAndAdd,
                child: const Text(
                  "Add",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool isEmpty = false,
    bool isDifferent = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          placeholder: placeholder,
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          padding: const EdgeInsets.only(top: 30, bottom: 30, left: 10),
          style: const TextStyle(
            fontSize: 24,
            color: CupertinoColors.black,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEmpty || isDifferent
                  ? CupertinoColors.destructiveRed
                  : CupertinoColors.lightBackgroundGray,
              width: 2,
            ),
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '*',
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          suffix: isPassword
              ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              color: CupertinoColors.inactiveGray,
            ),
          )
              : null,
        ),
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
                itemExtent: 50,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedWorkType = workTypes[index];
                    isWorkTypeEmpty = selectedWorkType == "Select Work Type";
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
