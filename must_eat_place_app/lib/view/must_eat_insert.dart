import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MustEatInsert extends StatefulWidget {
  const MustEatInsert({super.key});

  @override
  State<MustEatInsert> createState() => _MustEatInsertState();
}

class _MustEatInsertState extends State<MustEatInsert> {
  late DatabaseHandler handler;
  late TextEditingController longControl;
  late TextEditingController latContronl;
  late TextEditingController nameControl;
  late TextEditingController phoneControl;
  late TextEditingController evaluControl;
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  late Position currentPosition;
  late bool canRun;
  late bool iconChanged;
  late int favorite;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    longControl = TextEditingController();
    latContronl = TextEditingController();
    nameControl = TextEditingController();
    phoneControl = TextEditingController();
    evaluControl = TextEditingController();
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
    latContronl.text = currentPosition.latitude.toString().substring(0, 9);
    longControl.text = currentPosition.longitude.toString().substring(0, 9);
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
                              controller: nameControl,
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
                              controller: latContronl,
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
                              controller: longControl,
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

  getImageFromGallery(ImageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
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

  Future insetAction() async {
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();

    var mustEatInsert = MustEat(
        name: nameControl.text.trim(),
        image: getImage,
        phone: phoneControl.text.trim(),
        long: double.parse(longControl.text.trim()),
        lat: double.parse(latContronl.text.trim()),
        evaluate: evaluControl.text.trim(),
        favorite: favorite);

    await handler.insertMustEat(mustEatInsert);
    Get.back();
    Get.back();
  }

  _showDialog() {
    if (imageFile == null ||
        nameControl.text.trim().isEmpty ||
        phoneControl.text.trim().isEmpty ||
        evaluControl.text.trim().isEmpty ||
        latContronl.text.trim().isEmpty ||
        longControl.text.trim().isEmpty) {
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
              onPressed: () {
                insetAction();
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