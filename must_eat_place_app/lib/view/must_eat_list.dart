import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:must_eat_place_app/view/must_eat_insert.dart';
import 'package:must_eat_place_app/view/must_eat_location.dart';
import 'package:must_eat_place_app/view/must_eat_update.dart';
import 'package:must_eat_place_app/vm/database_handler.dart';

class MustEatList extends StatefulWidget {
  const MustEatList({super.key});

  @override
  State<MustEatList> createState() => _MustEatListState();
}

class _MustEatListState extends State<MustEatList> {
  late DatabaseHandler handler;
  late bool isChange;
  late List colorList;
  late bool switchValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handler = DatabaseHandler();
    isChange = false;
    colorList = [
      Color(0xFFFFE0E6),
      Color(0xFFFFE0B2),
      Color(0xFFC8E6C9),
      Color(0xFFB3E5FC),
    ];
    switchValue = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 7, 187, 169), // 버튼 배경 색상
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Get.to(() => MustEatInsert())!.then((value) => reloadData());
          },
        ),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 254, 221, 103),
          title: Text(
            'MustEat',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Switch(
                activeColor: Color.fromARGB(255, 241, 241, 241),
                activeTrackColor: Color.fromARGB(255, 11, 203, 184),
                value: switchValue,
                onChanged: (value) {
                  setState(() {});
                  switchValue = !switchValue;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: switchValue == true
                        ? handler.queryFavoriteEatList()
                        : handler.queryEatList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("에러는 ${snapshot.error}"),
                        );
                      } else if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  Get.to(MustEatLocation(), arguments: [
                                snapshot.data![index].name,
                                snapshot.data![index].lat,
                                snapshot.data![index].long,
                                snapshot.data![index].phone,
                                snapshot.data![index].image,
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
                                            offset: Offset(0, 5))
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Slidable(
                                      startActionPane: ActionPane(
                                        motion: StretchMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              Get.to(() => MustEatUpdate(),
                                                      arguments: [
                                                    snapshot.data![index].name,
                                                    snapshot.data![index].image,
                                                    snapshot.data![index].phone,
                                                    snapshot.data![index].long,
                                                    snapshot.data![index].lat,
                                                    snapshot
                                                        .data![index].evaluate,
                                                    snapshot
                                                        .data![index].favorite,
                                                    snapshot.data![index].seq
                                                  ])!
                                                  .then(
                                                (value) => reloadData(),
                                              );
                                            },
                                            icon: Icons.edit,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft:
                                                    Radius.circular(10)),
                                            backgroundColor: Colors.green,
                                          )
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: StretchMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              _showDialog(snapshot, index);
                                            },
                                            icon: Icons.delete,
                                            borderRadius: BorderRadius.only(
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
                                                Container(
                                                  height: 80,
                                                  width: 100,
                                                  child: Image.memory(
                                                    snapshot.data![index].image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      snapshot
                                                          .data![index].name,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data![index].phone,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {});
                                                    isChange = snapshot
                                                            .data![index]
                                                            .favorite ==
                                                        1;

                                                    snapshot.data![index]
                                                            .favorite =
                                                        isChange ? 0 : 1;
                                                    handler.updateFavorite(
                                                        snapshot.data![index]
                                                            .favorite,
                                                        snapshot
                                                            .data![index].seq);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: snapshot.data![index]
                                                                .favorite ==
                                                            0
                                                        ? Icon(Icons
                                                            .favorite_border)
                                                        : Icon(Icons.favorite),
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
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
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

  _showDialog(snapshot, index) {
    Get.defaultDialog(
        title: 'Delete',
        middleText: 'Do you want to delete?',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                setState(() {});
                handler.deleteMustEat(snapshot.data![index].seq!);
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