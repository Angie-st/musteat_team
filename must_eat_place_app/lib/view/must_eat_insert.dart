import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MustEatInsert extends StatefulWidget {
  const MustEatInsert({super.key});

  @override
  State<MustEatInsert> createState() => _MustEatInsertState();
}

class _MustEatInsertState extends State<MustEatInsert> {
  late DatabaseHandler handler;
  TextEditingController longController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late Position currentPosition;
  late bool canRun;
  late bool iconChanged;
  late int favorite;
// ImangePicker에서 선택된 filename, 초기값 주기위해서
  String image = "";
  var now = DateTime.now();
  double evaluate = 0;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    canRun = false;
    checkLocationPermission();
    getCurrentLocation();
    iconChanged = false;
    favorite = 0;
  }

  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    canRun = true;
    latController.text = currentPosition.latitude.toString().substring(0, 9);
    longController.text = currentPosition.longitude.toString().substring(0, 9);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MustEat',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 254, 221, 103),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Color.fromARGB(255, 176, 193, 200),
                width: MediaQuery.of(context).size.width, // 앱
                height: 250,
                child: Center(
                  child: imageFile == null
                      ? GestureDetector(
                          onTap: () {
                            getImageFromGallery(ImageSource.gallery);
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              Text(
                                'Click to add a photo',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 1, 24, 26)),
                              ),
                            ],
                          ))
                      : GestureDetector(
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
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  border: InputBorder.none,
                                  hintText: 'Restaurant Name'),
                              controller: nameController,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {});
                                  iconChanged = !iconChanged;
                                  favorite = iconChanged ? 1 : 0;
                                },
                                child: Icon(iconChanged
                                    ? Icons.favorite
                                    : Icons.favorite_border)),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: InputBorder.none,
                            hintText: 'Phone'),
                        controller: phoneController,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      addBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Location       '),
                          SizedBox(
                            width: 95,
                            child: TextField(
                              controller: latController,
                              maxLength: 9,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(counterText: ""),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 95,
                            child: TextField(
                              controller: longController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(counterText: ""),
                              maxLength: 10,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 7, 187, 169),
                          ),
                          onPressed: () {
                            _showDialog();
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // Todo Title에 들어가는 텍스트 필드
  Widget addBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: Colors.amber[100], borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: commentController,
        maxLength: 150,
        expands: true,
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Restaurant Details',
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(25),
        ),
      ),
    );
  }

  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    setState(() {});
    print(imageFile!.path); // 이미지 경로 확인
  }

  uploadImage() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/upload'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    // for getting file name
    List preFileName = imageFile!.path.split('/');
    image = preFileName[preFileName.length - 1];
    print('upload file name: $image');

    var response = await request.send();

    if (response.statusCode == 200) {
      print("image uploaded successfully");
    } else {
      print('image upload failed');
    }
  }

  insertJSONData() async {
    String nowDatetime = DateFormat('yyyy-MM-dd').format(now);
    var url = Uri.parse(
        'http://192.168.50.123:8000/insert?name=${nameController.text}&image=$image&phone=${phoneController.text}&long=${longController.text}&lat=${latController.text}&adddate=${nowDatetime}&favorite=$favorite&lat=${commentController.text}&evaluate=$evaluate');
    var response = await http.get(url);
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataCovertedJSON['result'];
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }

  _showDialog() {
    if (imageFile == null ||
        nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        commentController.text.trim().isEmpty ||
        latController.text.trim().isEmpty ||
        longController.text.trim().isEmpty) {
      Get.defaultDialog(
        confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Ok')),
        title: 'Error',
        middleText: 'Please complete the form',
      );
      return;
    }
    Get.defaultDialog(
        title: 'Add',
        middleText: 'Do you want to add to the list?',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () async {
                await uploadImage();
                insertJSONData();
              },
              child: Text('OK')),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel')),
        ]);
  }
} //End