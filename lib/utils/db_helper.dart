import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:start_page/constants/strings.dart';
import 'package:start_page/models/saved_later_item.dart';
import 'package:start_page/models/start_app.dart';

class DbHelper {
  static final DbHelper _instance = new DbHelper.internal();

  factory DbHelper() => _instance;

  static Database _db;

  openDB() async {
    var database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE StartApp(id INTEGER PRIMARY KEY, title TEXT, url TEXT, cat TEXT, app INTEGER, color TEXT);");
        db.execute(
            "CREATE TABLE SavedLaterItem(id INTEGER PRIMARY KEY, title TEXT, url TEXT, cat TEXT);");
        db.execute(
            "CREATE TABLE appCategories(id INTEGER PRIMARY KEY, name TEXT)");
        db.execute(
            "CREATE TABLE savedLaterCategories(id INTEGER PRIMARY KEY, name TEXT); ");
        db.insert(
          'appCategories',
          {'name': "None"},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        db.insert(
          'savedLaterCategories',
          {'name': "All"},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
      version: 1,
    );
    return database;
  }

  DbHelper.internal();

  Future<Database> get getdb async {
    if (_db != null) {
      return _db;
    }
    _db = await openDB();

    return _db;
  }

  Future<void> insertCategory(String cat, String dbName) async {
    final Database db = await getdb;

    await db.insert(
      dbName,
      {'name': cat},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStartApp(StartApp startApp) async {
    final Database db = await getdb;

    await db.insert(
      STARTAPP,
      startApp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSavedLaterItem(SavedLaterItem savedLaterItem) async {
    final Database db = await getdb;

    await db.insert(
      SAVEDLATERITEM,
      savedLaterItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StartApp>> getStartApps() async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    maps = await db.query(STARTAPP);

    return maps.map((e) => StartApp.fromMap(e)).toList();
  }

  Future<List<SavedLaterItem>> getSavedLaterItems() async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    maps = await db.query(SAVEDLATERITEM);

    return maps.map((e) => SavedLaterItem.fromMap(e)).toList();
  }

  Future<List<String>> getCategories(String dbName) async {
    final Database db = await getdb;

    final List<Map<String, dynamic>> maps = await db.query(dbName);
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }

  Future<void> deleteSavedLater(int id) async {
    final db = await getdb;

    await db.delete(
      SAVEDLATERITEM,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteStartApp(int id) async {
    final db = await getdb;

    await db.delete(
      STARTAPP,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteCat(String name, String catDb, String appDb) async {
    final db = await getdb;

    Batch batch = db.batch();
    batch.delete(appDb, where: "cat == ?", whereArgs: [name]);
    batch.delete(
      catDb,
    );
    await batch.commit();
  }

  Future<void> clearTable(String dbName) async {
    final db = await getdb;
    await db.delete(dbName);
  }

  Future<void> editCategory(
      String prevCat, String newCat, String dbName) async {
    final db = await getdb;

    await db.update(
      dbName,
      {'name': newCat},
      where: "name = ?",
      whereArgs: [prevCat],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> editStartApp(StartApp startApp) async {
    final db = await getdb;

    await db.update(
      STARTAPP,
      startApp.toMap(),
      where: "id = ?",
      whereArgs: [startApp.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> editSavedLater(SavedLaterItem savedLaterItem) async {
    final db = await getdb;

    await db.update(
      SAVEDLATERITEM,
      savedLaterItem.toMap(),
      where: "id = ?",
      whereArgs: [savedLaterItem.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future close() async {
    var dbClient = await getdb;
    return dbClient.close();
  }
}
