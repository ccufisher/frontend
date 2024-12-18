import 'package:fisher_front_end/widgets/worker_management/add_new_button.dart';
import 'package:fisher_front_end/widgets/worker_management/personnel_card.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkerManagementPage extends StatefulWidget {
  const WorkerManagementPage({super.key});

  @override
  State<WorkerManagementPage> createState() => _WorkerManagementPageState();
}

class _WorkerManagementPageState extends State<WorkerManagementPage> {
  // final List<Map<String, String>> personnel = [];
  List<Map<String, String>> personnel = [];
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'fisherman',
    'deckhand',
    'fish processor',
    'engineer',
    'chef',
  ];

  bool isLoading = false; // 控制加載畫面的狀態

  @override
  void initState() {
    super.initState();
    fetchProfileData(); // 初始載入所有人員資料
  }

  // 獲取所有人員資料 (getProfile API)
  Future<void> fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('http://35.229.208.250:3000/api/workerEdit/profiles'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          personnel = data.map((worker) {
            return {
              'name': worker['name']?.toString() ?? 'Unknown',       // 預設名稱
              'image': worker['profilePhoto']?.toString() ?? '',    // 預設圖片
              'number': worker['worker_id']?.toString() ?? '0',  // 預設編號
            };
          }).toList();
        });
      } else {
        personnel.clear(); // 清空原有資料
      }
    } catch (e) {
      personnel.clear(); // 清空原有資料
    }
  }

  // 根據職位獲取人員資料 (getWorkersByJobTitle API)
  Future<void> getWorkersByJob(String jobTitle) async {
    final String url =
        'http://35.229.208.250:3000/api/workerEdit/get-by-job?job_title=$jobTitle';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> workers = data['workers']; // 取出 workers 陣列

        setState(() {
            personnel.clear(); // 清空原有資料
            personnel.addAll(workers.map((worker) => {
              "name": worker["name"] ?? "",
              "number": worker["worker_id"].toString(),
              "role": worker["job_title"] ?? "",
              "image": worker["profilePhoto"] ?? "",
            }));
        });
      } else {
        personnel.clear(); // 清空原有資料
      }
    } catch (e) {
      personnel.clear(); // 清空原有資料
    }
  }



  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      // *** 新增 navigationBar ***
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
        middle: const Text('Crew Management'),
      ),
      // *** navigationBar 區域結束 ***
      child: Column(
        children: [
          // 頂部分類按鈕
          Padding(
            padding: const EdgeInsets.only(top: 80, bottom: 5),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: categories.map((category) {
                  bool isSelected = category == selectedCategory;
                  return Expanded(
                    // 使用 Expanded 讓按鈕等分螢幕寬度
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10), // 控制按鈕間距
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                          });
                          //發送 API 請求
                          if (category == 'All') {
                            personnel.clear();
                            fetchProfileData();
                          } else {
                            personnel.clear(); //必須先清乾淨 否則會重疊資料
                            getWorkersByJob(category);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.lightBackgroundGray,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            // 讓文字置中
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 卡片區域
          Expanded(
            child: isLoading
                ? const Center(
                    child: CupertinoActivityIndicator(
                      radius: 20, // 加載動畫大小
                    ),
                  )
                : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 每行顯示 5 個卡片
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4, // 調整卡片比例
                  ),
                  itemCount: personnel.length + 1, // 包含新增按鈕
                  itemBuilder: (context, index) {
                    if (index == personnel.length) {
                      return AddNewButton(
                        onTap: () async {
                          Navigator.pushNamed(context, 'addPersonnelPage', arguments: {
                            'onAdd': (newPerson) async{
                              setState(() {
                                isLoading = true; // 開始加載
                              });
                              setState(() => personnel.add(newPerson));
                              // 根據當前工種重新加載資料
                              if (selectedCategory == 'All') {
                                fetchProfileData(); // 載入所有人員
                              } else {
                                getWorkersByJob(selectedCategory); // 載入指定工種人員
                              }
                              await Future.delayed(const Duration(milliseconds:300)); // 可模擬延遲
                              setState(() {
                                isLoading = false; // 結束加載
                              });
                            },
                            'existingNumbers': personnel.map((person) => person['number']!).toList(),
                          });

                        },
                      );
                    }


                    final person = personnel[index]; // 人員卡片點擊
                    final originalIndex = personnel.indexWhere(
                            (p) => p['number'] == person['number']); // 確保正確匹配原始數據
                    return PersonnelCard(
                      name: person["name"]!,
                      number: person["number"]!,
                      image: person["image"] ?? '',

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'editPersonnelPage',
                          arguments: {
                            'person': Map<String, String>.from(personnel[originalIndex]), // 使用原始數據
                            'onDelete': () {
                              setState(() => personnel.removeAt(originalIndex)); // 刪除原始數據
                              Navigator.pop(context);

                              if (selectedCategory == 'All') {
                                fetchProfileData(); // 載入所有人員
                              } else {
                                getWorkersByJob(selectedCategory); // 載入指定工種人員
                              }
                            },
                            'onSave': (updatedPerson) async{
                              setState(() {
                                isLoading = true; // 開始加載
                              });
                              setState(() => personnel[originalIndex] = updatedPerson); // 更新原始數據
                              if (selectedCategory == 'All') {
                                fetchProfileData(); // 載入所有人員
                              } else {
                                getWorkersByJob(selectedCategory); // 載入指定工種人員
                              }
                              await Future.delayed(const Duration(milliseconds:300)); // 可模擬延遲
                              setState(() {
                                isLoading = false; // 結束加載
                              });
                            },
                            'existingNumbers': personnel
                                .map((person) => person['number']!)
                                .toList(),

                          },
                        );
                      },
                    );

                  },
                ),
          ),
        ],
      ),
    );
  }
}
