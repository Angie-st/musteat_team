import 'package:geocoding/geocoding.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MustEatLocation extends StatefulWidget {
  const MustEatLocation({super.key});

  @override
  State<MustEatLocation> createState() => _MustEatLocationState();
}

class _MustEatLocationState extends State<MustEatLocation> {
  late Position currentPosition;
  late bool canRun;
  late String name;
  late double latData;
  late double longData;
  late MapController mapController;
  var value = Get.arguments ?? "__";
  late String image;
  late String address;
  late double evaluate;

  @override
  void initState() {
    super.initState();
    canRun = false;
    mapController = MapController();
    latData = value[3];
    longData = value[2];
    image = value[1];
    name = value[0];
    evaluate = value[5];
    address = '';
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    canRun = true;
    // Perform reverse geocoding to get the address
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latData, longData);
    Placemark place = placemarks[0];
    address =
        "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

    // You can use this address as needed
    // print(address);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE6),
        title: Text(
          name,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: canRun
          ? Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width, // 앱
                  height: 250,
                  child: Stack(
                    children: [
                      // 이미지
                      Image.network(
                        'http://127.0.0.1:8000/query/view/$image',
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: 250,
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Stack(alignment: Alignment.center,
                              children: [
                              const Text(
                                '⭐️',
                                style: TextStyle(
                                  fontSize: 50,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                evaluate.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                            Text(
                              address,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: flutterMap()),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget flutterMap() {
    return FlutterMap(
        mapController: mapController,
        options: MapOptions(
            initialCenter: latlng.LatLng(latData, longData), initialZoom: 17.0),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: [
            Marker(
              width: 80,
              height: 80,
              point: latlng.LatLng(latData, longData),
              child: Column(
                children: [
                  SizedBox(
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const Icon(
                    Icons.pin_drop,
                    size: 50,
                    color: Colors.red,
                  )
                ],
              ),
            )
          ])
        ]);
  }
}
