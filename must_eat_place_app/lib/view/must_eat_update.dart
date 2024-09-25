import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';

class MustEatUpdate extends StatefulWidget {
  const MustEatUpdate({
    super.key,
  });

  @override
  State<MustEatUpdate> createState() => _MustEatUpdateState();
}

class _MustEatUpdateState extends State<MustEatUpdate> {
  late DatabaseHandler handler;
  late TextEditingController longControl;
  late TextEditingController latContronl;
  late TextEditingController nameControl;
  late TextEditingController phoneControl;
  late TextEditingController evaluControl;
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late bool canRun;
  late bool iconChanged;
  late int favorite;
  var value = Get.arguments ?? "-";
  late int firstDisp;
  late int seq;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    longControl = TextEditingController();
    latContronl = TextEditingController();
    nameControl = TextEditingController();
    phoneControl = TextEditingController();
    evaluControl = TextEditingController();
    nameControl.text = value[0];
    phoneControl.text = value[2];
    longControl.text = value[3].toString();
    latContronl.text = value[4].toString();
    evaluControl.text = value[5];
    canRun = false;
    iconChanged = false;
    favorite = value[6];
    firstDisp = 0;
    seq = value[7];
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
              firstDisp == 0
                  ? Container(
                      width: MediaQuery.of(context).size.width, // 앱
                      height: 250,
                      child: Center(
                        child: GestureDetector(
                            onTap: () {
                              getImageFromGallery(ImageSource.gallery);
                            },
                            child: Image.memory(
                              value[1],
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
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
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
                                  setState(() {});
                                  iconChanged = favorite == 0;
                                  favorite = iconChanged ? 1 : 0;
                                },
                                child: Icon(favorite == 1
                                    ? Icons.favorite
                                    : Icons.favorite_border)),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: InputBorder.none,
                            hintText: 'Phone'),
                        controller: phoneControl,
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
                              enabled: false,
                              controller: latContronl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
      firstDisp += 1;
      setState(() {});
    }
  }

  // Todo Title에 들어가는 텍스트 필드
  Widget addBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: Colors.amber[100], borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: evaluControl,
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

  Future updateActionAll() async {
    // File Type을 Byte Type으로 변환하기
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();
    var mustEatInsert = MustEat(
        name: nameControl.text.trim(),
        image: getImage,
        phone: phoneControl.text.trim(),
        long: double.parse(longControl.text.trim()),
        lat: double.parse(longControl.text.trim()),
        evaluate: evaluControl.text.trim(),
        favorite: favorite,
        seq: seq);

    await handler.updateMustEat(mustEatInsert);
  }

  Future updateAction() async {
    var mustEatInsert = MustEat(
        name: nameControl.text.trim(),
        image: value[1],
        phone: phoneControl.text.trim(),
        long: double.parse(longControl.text.trim()),
        lat: double.parse(longControl.text.trim()),
        evaluate: evaluControl.text.trim(),
        favorite: favorite,
        seq: seq);

    await handler.updateMustEat(mustEatInsert);
  }

  _showDialog() {
    if (nameControl.text.trim().isEmpty ||
        phoneControl.text.trim().isEmpty ||
        evaluControl.text.trim().isEmpty ||
        latContronl.text.trim().isEmpty ||
        longControl.text.trim().isEmpty) {
      Get.defaultDialog(
        confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')),
        title: 'Error',
        middleText: 'Please complete the form',
      );
      return;
    }
    Get.defaultDialog(
        title: 'Edit',
        middleText: 'Do you want to save?',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                if (firstDisp == 0) {
                  updateAction();
                  Get.back();
                  Get.back();
                } else
                  updateActionAll();
                Get.back();
                Get.back();
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