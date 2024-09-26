import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:must_eat_place_app/view/must_eat_insert.dart';
import 'package:must_eat_place_app/view/must_eat_location.dart';
import 'package:must_eat_place_app/view/must_eat_update.dart';
import 'package:http/http.dart' as http;

class MustEatList extends StatefulWidget {
  const MustEatList({super.key});

  @override
  State<MustEatList> createState() => _MustEatListState();
}

class _MustEatListState extends State<MustEatList> {
  late bool isChange;
  late List colorList;
  late bool switchValue;
  late String userId;
  final box = GetStorage();
  // 서버 저장 데이터
  List data = [];

    iniStorage() {
    userId = box.read('p_userID');
  }
  @override
  void initState() {
    super.initState();
    userId = "";    
    iniStorage();        
    getJSONData();
    isChange = false;
    colorList = [
      const Color(0xFFFFE0E6),
      const Color(0xFFFFE0B2),
      const Color(0xFFC8E6C9),
      const Color(0xFFB3E5FC),
    ];
    switchValue = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 7, 187, 169), // 버튼 배경 색상
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Get.to(() => const MustEatInsert())!.then((value) => getJSONData());
          },
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 254, 221, 103),
          title: const Text(
            'MustEat',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Switch(
                activeColor: const Color.fromARGB(255, 241, 241, 241),
                activeTrackColor: const Color.fromARGB(255, 11, 203, 184),
                value: switchValue,
                onChanged: (value) {              
                  switchValue = !switchValue;
                  switchValue == false ? getJSONData() : getJSONFavorite();
                  setState(() {});                  
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: data.isEmpty
                      ? const Center(child: Text('Add List!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 205, 98, 90)
                      ),
                      ))
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  Get.to(const MustEatLocation(), arguments: [
                                data[index][1], //name
                                data[index][2], //image
                                data[index][4], //long
                                data[index][5], //lat
                                data[index][10] //user_id
                              ]),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.7),
                                            blurRadius: 5.0,
                                            spreadRadius: 0.0,
                                            offset: const Offset(0, 5))
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Slidable(
                                      startActionPane: ActionPane(
                                        motion: const StretchMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              Get.to(() => const MustEatUpdate(),
                                                      arguments: [
                                                    data[index][0], //seq
                                                    data[index][1], //name
                                                    data[index][2], //image
                                                    data[index][3], //phone
                                                    data[index][4], //long
                                                    data[index][5], //lat
                                                    data[index][8], //comment
                                                    data[index][9], //evaluate
                                                    data[index][10] //user_id
                                                  ])!
                                                  .then(
                                                (value) => getJSONData(),
                                              );
                                            },
                                            icon: Icons.edit,
                                            borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft:
                                                    Radius.circular(10)),
                                            backgroundColor: Colors.green,
                                          )
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const StretchMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              _showDialog(index, data[index][2]);
                                            },
                                            icon: Icons.delete,
                                            borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            backgroundColor: Colors.red,
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            color: colorList[
                                                (index % colorList.length)],
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: 80,
                                                  width: 100,
                                                  child: Image.network('http://127.0.0.1:8000/query/view/${data[index][2]}'
                                                    ,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                          data[index][1],
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                          data[index][3],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    isChange = data[index][7] == 1;
                                                    data[index][7] =
                                                        isChange ? 0 : 1;
                                                        updateJSONFavorite(index);
                                                        setState(() {});
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: data[index][7]
                                                                == 0
                                                        ? const Icon(Icons
                                                            .favorite_border)
                                                        : const Icon(Icons.favorite),
                                                  ),
                                                ),
                                                Container(
                                                  height: 80,
                                                  width: 12,
                                                  color: Colors.black26,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ));
  }

  reloadData() {
    setState(() {});
  }

  _showDialog(index, filename) {
    Get.defaultDialog(
        title: 'DELETE',
        middleText: 'Are you SURE to delete?',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                deleteJSONData(index, filename);
                Get.back();
              },
              child: const Text('OK')),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel')),
        ]);
  }

    deleteImage(String filename) async{
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/query/deleteFile/$filename'));
    if (response.statusCode==200){
      // print('Image deleted successfully');
    }else{
      // print('Image deletion failed.');
    }
  }

  deleteJSONData(index, filename) async{
    await deleteImage(filename);
    var url=Uri.parse(
      'http://127.0.0.1:8000/query/delete?seq=${data[index][0]}');
    var response=await http.get(url);
    var dataConvertedJSON=json.decode(utf8.decode(response.bodyBytes));
    var result=dataConvertedJSON['results'];
    if(result=='OK'){
      setState(() {});
      data.removeAt(index);
      // setState를 해도 화면 이동 없으면 현재 화면에서의 data List에서는 바로 지워지지 않으므로 
      //List에서 데이터를 지우는 removeAt도 함께 추가. 
    }
  }

  getJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    data.clear();
    // print(response.body);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});
  }

  getJSONFavorite() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select_favorite?user_id=$userId');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});
  }

  updateJSONFavorite(index) async{
    var url=Uri.parse(
      'http://127.0.0.1:8000/query/update_favorite?favorite=${data[index][7]}&seq=${data[index][0]}&user_id=$userId');
    var response=await http.get(url);
    var dataConvertedJSON=json.decode(utf8.decode(response.bodyBytes));
    var result=dataConvertedJSON['results'];
    if(result=='OK'){
    }else{
    }
  }
} //End