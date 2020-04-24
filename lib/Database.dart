import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Constants.dart';
import 'Game.dart';
import 'Migration.dart';
import 'package:flutter/foundation.dart';

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
    return await openDatabase(path, version: 2, onOpen: (db) async {
      // Perform a bit of cleanup on open.
      db.execute("DELETE from Images"
          "  where key in ("
          "    select distinct i.key"
          "    from Images i"
          "      left outer join"
          "    Games g on i.game = g.hash"
          "    where"
          "      i.game IS NULL or g.favourited = 0);");
      db.execute("DELETE from Games"
          "  where favourited = 0"
          "    and substr(hash, 1, 10) != '${PUBLISHED}';");
      // TODO: Potentially load things here.
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // Schema changes should be reflected in this function.  Version 1 -> 2
      // change happened prior to release, however is documented here as a go-to
      // for future cases. Allow for incremental updates. Ineffiecent, but lower
      // dev cost, and only a 1 time fix anyway.
      if (oldVersion < 2 && newVersion >= 2) {
        await db.execute(imageTableV2());
        Future.wait(gameTableV2Delta().map<Future>((q) => db.execute(q)));
      }
    }, onCreate: (Database db, int version) async {
      // These should always be the most up to data table versions.
      await Future.wait(
          <Future>[db.execute(gameTableV2()), db.execute(imageTableV2())]);
    });
  }

  Future<Game> newGame(Game game) async {
    final db = await database;
    game.saved = true;
    try {
      await db.rawInsert(
          "INSERT Into Games "
          "(hash, name, description, subtitle, images, json, highscore, plays, favourited, saved)"
          " VALUES (?,?,?,?,?,?,?,?,?,?)",
          [
            game.hash,
            game.name,
            game.description,
            game.subtitle,
            game.images.join("|"),
            game.json,
            game.highscore,
            game.plays,
            game.favourited,
            game.saved,
          ]);
    } on DatabaseException {
      return updateGame(game);
    }
    return game;
  }

  Future<Game> updateGame(Game game) async {
    final db = await database;
    debugPrint("${game.toMap()}");
    await db.update("Games", game.toMap(),
        where: "hash = ?", whereArgs: [game.hash]);
    return game;
  }

  Future<List<Game>> backfillGames(List<Game> games) async {
    List<String> hashes = games.map<String>((g) => g.hash).toList();
    String qs = (new List.filled(hashes.length, "?").join(", "));
    return database.then((db) {
      return db.query("Games", where: "hash in ($qs)", whereArgs: hashes);
    }).then((rows) {
      var saved = rows.map<Game>((row) => Game.fromRow(row));
      var savedHashes = Set<String>.from(saved.map<String>((g) => g.hash));
      var unsaved = games.where((g) => !savedHashes.contains(g.hash)).toList();
      return [...saved, ...unsaved];
    });
  }

  getGame(String hash) async {
    final db = await database;
    var res = await db.query("Games", where: "hash = ?", whereArgs: [hash]);
    return res.isNotEmpty ? Game.fromRow(res.first) : null;
  }

  Future<List<Game>> getFavoriteGames([int offset = 0]) async {
    final db = await database;
    // TODO: Offset requires pagination and a limit.
    var res = await db.query("Games", where: "favourited = ? ", whereArgs: [1]);
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

  Future<String> setImage(Game game, String key, String data) async {
    final db = await database;
    try {
      await db.rawInsert(
          "INSERT Into Images"
          "(key, game, data)"
          " VALUES (?,?,?)",
          [
            "${game.hash}|${key}",
            game.hash,
            data,
          ]);
    } on DatabaseException {
      return null;
    }
    return data;
  }

  Future<String> getImage(Game game, String key) async {
    final db = await database;
    var res = await db
        .query("Images", where: "key = ?", whereArgs: ["${game.hash}|${key}"]);
    return res.isNotEmpty ? res.first["data"] : null;
  }
}
