import 'dart:typed_data';

class MustEat {
  int? seq;
  String name;
  final Uint8List image;
  String phone;
  double long; // 경도
  double lat; // 위도
  String evaluate;
  int favorite;

  MustEat(
      {this.seq,
      required this.name,
      required this.image,
      required this.phone,
      required this.long,
      required this.lat,
      required this.evaluate,
      required this.favorite});

  MustEat.fromMap(Map<String, dynamic> res)
      : seq = res['seq'],
        name = res['name'],
        image = res['image'],
        phone = res['phone'],
        long = res['long'],
        lat = res['lat'],
        evaluate = res['evaluate'],
        favorite = res['favorite'];
}
