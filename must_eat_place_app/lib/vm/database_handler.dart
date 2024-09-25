import 'package:must_eat_place_app/model/must_eat.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'musteat.db'),
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE musteat (
            seq integer PRIMARY KEY autoincrement,
            name text,
            image blob,
            phone text,
            long real,
            lat real,
            evaluate text,
            favorite integer
          );
        """);
      },
      version: 1,
    );
  }

  Future<int> insertMustEat(MustEat mustEat) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert("""
        insert into musteat(name, image, phone, long, lat, evaluate, favorite)
        values (?,?,?,?,?,?,?)
      """, [
      mustEat.name,
      mustEat.image,
      mustEat.phone,
      mustEat.long,
      mustEat.lat,
      mustEat.evaluate,
      mustEat.favorite
    ]);
    return result;
  }

  Future<List<MustEat>> queryEatList() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      Select
        *
      from musteat
""",
    );
    return queryResult.map((e) => MustEat.fromMap(e)).toList();
  }

  Future<List<MustEat>> queryFavoriteEatList() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      Select
        *
      from musteat
      where favorite = 1
""",
    );
    return queryResult.map((e) => MustEat.fromMap(e)).toList();
  }

  Future<int> updateMustEat(MustEat mustEat) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      """
      UPDATE musteat
      SET  name = ?, image = ?, phone = ?, evaluate = ?, favorite = ?
      WHERE seq = ?
    """,
      [
        mustEat.name,
        mustEat.image,
        mustEat.phone,
        mustEat.evaluate,
        mustEat.favorite,
        mustEat.seq
      ],
    );
    return result;
  }

  Future<int> updateFavorite(favorite, seq) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      """
      UPDATE musteat
      set favorite = ?
      WHERE seq = ?
    """,
      [favorite, seq],
    );
    return result;
  }

  Future<void> deleteMustEat(int seq) async {
    final Database db = await initializeDB();
    await db.rawDelete("""
      delete from musteat where seq = ?
      """, [seq]);
  }
}
