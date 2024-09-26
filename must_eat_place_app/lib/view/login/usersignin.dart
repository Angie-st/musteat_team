import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../model/password_checkuser.dart';

class UserSignIn extends StatefulWidget {
  const UserSignIn({super.key});

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  // Property
  late TextEditingController userIdController;
  late TextEditingController passwordController;
  late TextEditingController repasswordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late String checkpassword;
  late String passwordcheck;
  late String passwordcheck2;
  late Color textColor;
  late Color textColor2;
  late String checkID;
  late Color textIDColor;
  PasswordCheckUser passwordCheckUser = PasswordCheckUser();

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    passwordController = TextEditingController();
    repasswordController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    checkpassword = '';
    passwordcheck = '';
    passwordcheck2 = '';
    checkID = '';
    textColor = Colors.black;
    textColor2 = Colors.black;
    textIDColor = Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 245, 192, 4)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        children: [
                          TextField(
                            controller: userIdController,
                            decoration: const InputDecoration(
                              labelText: 'User ID',
                            ),
                          ),
                          Text(
                            checkID,
                            style: TextStyle(color: textIDColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            checkUserID();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC06044)),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  onChanged: (value) {
                    checkPassworld();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  checkpassword,
                  style: TextStyle(color: textColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: TextField(
                  controller: repasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  onChanged: (value) {
                    checkPassworld();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  passwordcheck2,
                  style: TextStyle(color: textColor2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  insertJSONData();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF748D65)),
                child: const Text(
                  'Sign up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions ---
  insertJSONData() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/insertuserid?id=${userIdController.text}&password=${passwordController.text}&name=${nameController.text}&phone=${phoneController.text}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      _showDialog('환영합니다', '회원가입이 완료 되었습니다.');
    } else {
      // errorSnackBar();
    }
  }

  checkUserJSONData() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/checkuserid?id=${userIdController.text}');
    var response = await http.get(url);
    print(response.body);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 1) {
      checkID = '아이디가 중복됩니다';
      textIDColor = Colors.red;
    } else {
      checkID = '사용가능한 아이디 입니다.';
      textIDColor = Colors.green;
    }
    setState(() {});
  }

  checkUserID() async {
    if (userIdController.text.trim().isEmpty) {
      checkID = '사용할 아이디를 입력해 주세요';
      textIDColor = Colors.red;
    } else {
      checkUserJSONData();
    }
    setState(() {});
  }

  _showDialog(String check_user_id, String welcome_user) {
    Get.defaultDialog(
        title: check_user_id,
        middleText: welcome_user,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              if (check_user_id == '환영합니다') {
                Get.back();
                Get.back();
              }
              if (check_user_id == '아이디가 중복됩니다') {
                Get.back();
              }
            },
            child: const Text('확인'),
          )
        ]);
  }

  checkPassworld() {
    // 비밀번호 유효성 검사
    String? passwordValidationMessage =
        passwordCheckUser.validatePassword(passwordController.text.trim());

    // 비밀번호가 유효한 경우
    if (passwordValidationMessage == null) {
      checkpassword = '확인되었습니다';
      textColor = Colors.green;
    } else {
      checkpassword = passwordValidationMessage;
      textColor = Colors.red;
    }

    // 비밀번호 확인 유효성 검사
    String? confirmPasswordValidationMessage =
        passwordCheckUser.validatePasswordConfirm(
            passwordController.text.trim(), repasswordController.text.trim());

    // 비밀번호 확인 메시지 설정
    if (confirmPasswordValidationMessage == null) {
      passwordcheck2 = '비밀번호가 일치합니다';
      textColor2 = Colors.green;
    } else {
      passwordcheck2 = confirmPasswordValidationMessage;
      textColor2 = Colors.red;
    }

    // 상태 갱신하여 UI 업데이트
    setState(() {});
  }
}// END
