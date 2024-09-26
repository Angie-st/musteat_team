import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MustEatUpdate extends StatefulWidget {
  const MustEatUpdate({
    super.key,
  });

  @override
  State<MustEatUpdate> createState() => _MustEatUpdateState();
}

class _MustEatUpdateState extends State<MustEatUpdate> {
  var value = Get.arguments ?? "-";
  late TextEditingController longControl;
  late TextEditingController latControl;
  TextEditingController nameControl = TextEditingController();
  TextEditingController phoneControl = TextEditingController();
  TextEditingController commentControl = TextEditingController();
  String nowDatetime = '';
  late double evaluate;
  // Gallery 선택 여부
  int firstDisp = 0;
  String filename = '';
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late bool canRun;
  late bool iconChanged;
  late int favorite;

  late int seq;
// 1.seq, 2.name, 3.image, 4.phone, 5.long, 6.lat, 7.adddate, 8.favorite, 9.comment, 10.evaluate, 11.user_id
  @override
  void initState() {
    super.initState();
    longControl = TextEditingController(text: value[4].toString());
    latControl = TextEditingController(text: value[5].toString());
    print(value);
    print(longControl.text);
    nameControl.text = value[1];
    phoneControl.text = value[3];
    commentControl.text = value[8];
    canRun = false;
    iconChanged = false;
    favorite = value[7];
    seq = value[0];
    evaluate = value[9];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MustEat',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 254, 221, 103),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              firstDisp == 0
                  ? Container(
                      width: MediaQuery.of(context).size.width, // 앱
                      height: 250,
                      child: Center(
                        child: GestureDetector(
                            onTap: () {
                              getImageFromGallery(ImageSource.gallery);
                            },
                            child: Image.network(
                              "http://127.0.0.1:8000/update/view/${value[2]}",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            )),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width, // 앱
                      height: 250,
                      child: Center(
                        child: GestureDetector(
                            onTap: () {
                              getImageFromGallery(ImageSource.gallery);
                            },
                            child: Image.file(
                              File(
                                imageFile!.path,
                              ),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            )),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 300,
                            child: TextField(
                              maxLength: 18,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                  counterText: "",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  border: InputBorder.none,
                                  hintText: 'Restaurant Name'),
                              controller: nameControl,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: GestureDetector(
                                onTap: () {
                                  favorite == 0 ? favorite = 1 : favorite = 0;
                                  iconChanged = favorite == 0;
                                  favorite = iconChanged ? 1 : 0;
                                  setState(() {});
                                },
                                child: Icon(favorite == 1
                                    ? Icons.favorite
                                    : Icons.favorite_border)),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: InputBorder.none,
                            hintText: 'Phone'),
                        controller: phoneControl,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      addBox(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RatingBar.builder(
                          initialRating: evaluate,
                          itemCount: 5,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            evaluate = rating;
                            setState(() {});
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Location       '),
                          SizedBox(
                            width: 95,
                            child: TextField(
                              enabled: false,
                              controller: latControl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 95,
                            child: TextField(
                              enabled: false,
                              controller: longControl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 7, 187, 169),
                          ),
                          onPressed: () {
                            if (firstDisp == 0) {
                              // AddDate 추가
                              var now = DateTime.now();
                              nowDatetime =
                                  DateFormat("yyyy-MM-dd").format(now);
                              updateAction(nowDatetime);
                              setState(() {});
                            } else {
                              updateActionAll(nowDatetime);
                            }
                            // _showDialog();
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //===== widget=====

  // 텍스트 위젯
  Widget text(text) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ---function---

  // 갤러리에 있는 이미지 넣기
  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickerFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickerFile!.path);
    firstDisp = 1;
    setState(() {});
    // print(imageFile!.path); // 경로 가져올때는 split을 사용해서 경로를 가져오면 된다.
  }

  // Todo Title에 들어가는 텍스트 필드
  Widget addBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: Colors.amber[100], borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: commentControl,
        maxLength: 150,
        expands: true,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Restaurant Details',
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(25),
        ),
      ),
    );
  }

  updateAction(date) {
    updateJSONData(date);
  }

  updateJSONData(date) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update/update?seq=${value[0]}&name=${nameControl.text}&phone=${phoneControl.text}&favorite=$favorite&comment=${commentControl.text}&evaluate=$evaluate&user_id=${value[10]}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

  updateActionAll(date) async {
    await deleteImage(value[2]);
    await uploadImage();
    updateJSONDataAll(date);
  }

  // uploads에 있는 Image 삭제
  deleteImage(String filename) async {
    final response = await http
        .delete(Uri.parse('http://127.0.0.1:8000/update/deleteFile/$filename'));
    if (response.statusCode == 200) {
      print("Image deleted successfully");
    } else {
      print("image deletion failed.");
    }
  }

  uploadImage() async {
    // POST 방식
    var request = http.MultipartRequest(
        "POST", Uri.parse('http://127.0.0.1:8000/update/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    // for getting file name
    List preFileName = imageFile!.path.split('/');
    filename = preFileName[preFileName.length - 1];
    print("upload file name : $filename");

    var response = await request.send();

    // 200이면 정상적으로 들어간 것
    if (response.statusCode == 200) {
      print("Image upload successfully");
    } else {
      print("Image upload failed");
    }
  }

  // Image를 선택후 업데이트
  updateJSONDataAll(date) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update/updateAll?seq=${value[0]}&name=${nameControl.text}&image=$filename&phone=${phoneControl.text}&favorite=$favorite&comment=${commentControl.text}&evaluate=$evaluate&user_id=${value[10]}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

  _showDialog() {
    print("Successfully!");
    Get.back();
  }

  errorSnackBar() {
    print("Error");
  }
} //End