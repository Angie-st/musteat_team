import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:must_eat_place_app/view/login/usersignin.dart';
import 'package:must_eat_place_app/view/must_eat_list.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Property

  late TextEditingController userIdController;
  late TextEditingController passwordController;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    passwordController = TextEditingController();

    //초기화
    iniStorage();
  }

  iniStorage() {
    // box.erase();
    box.write('p_userID', "");
  }

  @override
  void dispose() {
    disposeStorage();
    super.dispose();
  }

  disposeStorage() {
    box.write('p_userID', "");
    box.write('p_password', "");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/TasteTracker.png'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: TextField(
                    controller: userIdController,
                    showCursor: false,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      fillColor: const Color.fromARGB(255, 250, 238, 201),
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black54, width: 2),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      hintText: 'User ID',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 30, right: 30, top: 15, bottom: 10),
                  child: TextField(
                    controller: passwordController,
                    showCursor: false,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      fillColor: const Color.fromARGB(255, 250, 238, 201),
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black54, width: 2),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      hintText: 'Password',
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => const UserSignIn(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC06044)),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          checkUserJSONData();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF748D65)),
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkUserJSONData() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/checkuser?id=${userIdController.text}&password=${passwordController.text}');
    var response = await http.get(url);
    print(response.body);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (userIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      errorSnackBar();
    } else if (result == 1) {
      saveStorage();
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

// checkUser() async {
//     int result = await customerHandler.queryLoginCheck(
//         userIdController.text.trim(), passwordController.text.trim());
//     if (userIdController.text.trim().isEmpty ||
//         passwordController.text.trim().isEmpty) {
//       errorSnackBar();
//     } else if (result == 1) {
//       saveStorage();
//       _showDialog();
//     } else {
//       errorSnackBar();
//     }
//   }

  errorSnackBar() {
    Get.snackbar('경고', 'ID랑 Password를 확인해 주세요',
        snackPosition: SnackPosition.BOTTOM, // snackBar 나오는 위치
        duration: const Duration(seconds: 2), // 유지되는 시간
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError // 스넥바 글씨
        );
  }

  _showDialog() {
    Get.defaultDialog(
        title: '환영합니다 ${box.read('p_userID')}님!',
        middleText: '오늘도 즐거운 쇼핑이 되세요!',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // 다이알로그를 없애고
              passwordController.text = '';
              Get.to(
                () => const MustEatList(),
              );
            },
            child: const Text('확인'),
          )
        ]);
  }

  saveStorage() {
    // ID 저장
    box.write('p_userID', userIdController.text.trim());
  }
} //END