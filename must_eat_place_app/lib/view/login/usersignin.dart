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
  late Color textColor;
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
    checkID = '';
    textColor = Colors.black;
    textIDColor = Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 250,
                    child: Column(
                      children: [
                        TextField(
                          controller: userIdController,
                          decoration: const InputDecoration(
                            labelText: '아이디',
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
                          // checkUserID();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC06044)),
                        child: const Text(
                          '중복확인',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                onChanged: (value) {
                  checkPassworld();
                },
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
              ),
            ),
            Text(
              checkpassword,
              style: TextStyle(color: textColor),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: repasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                onChanged: (value) {
                  checkPassworld();
                },
              ),
            ),
            Text(
              passwordcheck,
              style: TextStyle(color: textColor),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '전화번호'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF748D65)),
              child: const Text(
                '회원가입',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Functions ---
  insertJSONData()async{
    var url = Uri.parse('http://127.0.0.1:8000/checkuser?id=${userIdController.text}&password=${passwordController.text}&name=${nameController.text}&phone=${phoneController.text}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if(result == 'OK'){
      // _showDialog();
    }else{
      // errorSnackBar();
    }
  }

  // checkUserID() async {
  //   int result = await customerHandler.serchID(userIdController.text.trim());
  //   if (result == 1) {
  //     checkID = '아이디가 중복됩니다';
  //     textIDColor = Colors.red;
  //   } else {
  //     checkID = '사용가능한 아이디 입니다.';
  //     textIDColor = Colors.green;
  //   }
  //   setState(() {});
  // }

  // addAccount() async {
  //   int result = await customerHandler.serchID(userIdController.text.trim());
  //   if (result == 1) {
  //     _showDialog('아이디가 중복됩니다', '새로운 아이디를 확인해 주세요');
  //   } else {
  //     Account accout = Account(
  //       id: userIdController.text.trim(),
  //       name: nameController.text.trim(),
  //       password: passwordController.text.trim(),
  //       phone: phoneController.text.trim(),
  //     );
  //     await customerHandler.insertAccount(accout);
  //     _showDialog('환영합니다', '회원가입이 완료 되었습니다.');
  //   }
  // }

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
  } else {
    checkpassword = passwordValidationMessage;
    textColor = Colors.red;
  }

  // 비밀번호 확인 유효성 검사
  String? confirmPasswordValidationMessage = passwordCheckUser.validatePasswordConfirm(
    passwordController.text.trim(), 
    repasswordController.text.trim()
  );

  // 비밀번호 확인 메시지 설정
  if (confirmPasswordValidationMessage == null) {
    passwordcheck = '비밀번호가 일치합니다';
    textColor = Colors.green;
  } else {
    passwordcheck = confirmPasswordValidationMessage;
  }

  // 상태 갱신하여 UI 업데이트
  setState(() {});
}

}// END
