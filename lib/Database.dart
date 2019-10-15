import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Game.dart';

// I just followed some medium article honestly:
// https://medium.com/flutter-community/using-sqlite-in-flutter-187c1a82e8b
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "games.db");
    return await openDatabase(path, version: 1, onOpen: (db) async {
      // TODO: Have a sustainable means of schema changes here.
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Games ("
          "hash TEXT PRIMARY KEY,"
          "name TEXT,"
          "description TEXT,"
          "json TEXT,"
          "highscore INTEGER,"
          "plays INTEGER,"
          "favourited BIT,"
          "saved BIT"
          ")");
    });
  }

  newGame(Game game) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT Into Games "
        "(hash, name, description, json, highscore, plays, favourited, saved)"
        " VALUES (?,?,?,?,?,?,?,?)",
        [
          game.hash,
          game.name,
          game.description,
          game.json,
          0,
          game.plays,
          game.favourited,
          1,
        ]);
    return raw;
  }

  updateGame(Game game) async {
    final db = await database;
    var res = await db.update("Games", game.toMap(),
        where: "hash = ?", whereArgs: [game.hash]);
    return res;
  }

  Future<List<Game>> backfillGames(List<Game> games) async {
    List<String> hashes = games.map<String>((g) => g.hash).toList();
    String qs = (new List.filled(hashes.length, "?").join(", "));
    return database.then((db) {
      return db.query("Games", where: "hash in (${qs})", whereArgs: hashes);
    }).then((rows) {
      var saved = rows.map<Game>((row) => Game.fromRow(row));
      var saved_hashes = Set<String>.from(saved.map<String>((g) => g.hash));
      var unsaved = games.where((g) => !saved_hashes.contains(g.hash)).toList();
      return [...saved, ...unsaved];
    });
  }

  getGame(String hash) async {
    final db = await database;
    var res = await db.query("Games", where: "hash = ?", whereArgs: [hash]);
    return res.isNotEmpty ? Game.fromRow(res.first) : null;
  }

  Future<List<Game>> getFavGames() async {
    final db = await database;
    var res = await db.query("Game", where: "favourite = ? ", whereArgs: [1]);
    List<Game> list =
        res.isNotEmpty ? res.map((c) => Game.fromRow(c)).toList() : [];
    return list;
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    var res = await db.query("Games");
    List<Game> list =
        res.isNotEmpty ? res.map((c) => Game.fromRow(c)).toList() : [];
    return list;
  }
}
