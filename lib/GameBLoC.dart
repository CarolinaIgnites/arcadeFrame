import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import "Game.dart";
import "GameScreen.dart";
import "Database.dart";
import "Constants.dart";

class GameChannel {
  GameChannel(this.stream, this.request, this.context);

  final Stream<List<Game>> stream;
  final Future<bool> Function() request;
  Function(bool) _listener;
  GameBLoC context;

  set visibilityListener(Function(bool) listener) {
    _listener = listener;
  }

  setVisibility(bool vis) {
    if (_listener != null) _listener(vis);
  }
}

class GameBLoC {
  final searchController = TextEditingController();
  final DBProvider db = DBProvider.db;

  final StreamController<List<Game>> _searchStreamController =
      StreamController.broadcast();
  final StreamController<List<Game>> _favoriteStreamController =
      StreamController.broadcast();
  final StreamController<List<Game>> _popularStreamController =
      StreamController.broadcast();
  final StreamController<Game> _interactStreamController =
      StreamController.broadcast();

  final Map<String, Game> games = {};

  GameChannel searchChannel;
  GameChannel favoriteChannel;
  GameChannel popularChannel;
  bool searching = false;

  GameBLoC() {
    db.initDB();
    searchController.addListener(_searchGames);
    searchChannel =
        GameChannel(_searchStreamController.stream, _getSearch, this);
    favoriteChannel =
        GameChannel(_favoriteStreamController.stream, _getFavorites, this);
    popularChannel =
        GameChannel(_popularStreamController.stream, _getPopulars, this);
  }

  StreamSubscription<Game> registerGameListener(
      Game _game, Function(Game game) fn) {
    var hash = _game.hash;
    return _interactStreamController.stream
        .where((Game game) => game.hash == hash)
        .listen(fn);
  }

  requestGameUpdate(Game game) {
    games[game.hash] = game;
    _interactStreamController.add(game);
  }

  Game getCurrentGame(Game game) {
    if (!games.containsKey(game.hash)) {
      games[game.hash] = game;
    }
    return games[game.hash];
  }

  // Check if we already have the data, otherwise load it.
  Future<Game> queryGame(String hash) async {
    debugPrint("length ${hash.length} $hash");
    String key = hash;
    if (key.length > KEY_SIZE) {
      key = hash.substring(KEY_OFFSET);
    }
    return http.get(Uri.encodeFull("$API_ENDPOINT/$key"),
        headers: {"Accept": "application/json"}).then((response) {
      var body = json.decode(response.body);
      String data = utf8.decode(base64.decode(body["data"]));
      Game game = Game.fromMap(body);
      game.json = data;
      debugPrint("$data");
      db.updateGame(game);
      return game;
    });
  }

  Future<bool> _getSearch() {
    return getSearch().then((results) {
      _searchStreamController.add(results);
      return results != null && results.length == 5;
    });
  }

  Future<bool> _getFavorites() {
    return getFavoriteGames().then((results) {
      _favoriteStreamController.add(results);
      return results != null && results.length == 5;
    });
  }

  Future<bool> _getPopulars() {
    return getPopularGames().then((results) {
      _popularStreamController.add(results);
      return results != null && results.length == 5;
    });
  }

  // Redisearch also provides something called suggestion completion. Something
  // we could do, but our 0.5GB RAM VM, is struggling as is.
  _searchGames() async {
    if (searchController.text == "") {
      searchChannel.setVisibility(false);
      favoriteChannel.setVisibility(true);
      popularChannel.setVisibility(true);
      favoriteChannel.request();
      popularChannel.request();
      searching = false;
      return;
    }

    if (!searching) {
      favoriteChannel.setVisibility(false);
      popularChannel.setVisibility(false);
    }
    searching = true;
    searchChannel.setVisibility(true);
    searchChannel.request();
  }

  // TODO: Also update api that game was played.
  // Potential race condition, becasue PageBuilder expects the game to be set.
  // but I think to get to that point is pretty slow, so we should be good.
  Future<Game> _saveGame(Game game) async {
    if (game.saved) {
      return db.updateGame(game);
    }
    return db.newGame(game);
  }

  Future<Game> saveGame(Game game) async {
    return _saveGame(game).then(requestGameUpdate);
  }

  Future<List<Game>> getGames(String url, [int offset = 0]) async {
    debugPrint('url $url');
    return http.get(Uri.encodeFull(url),
        headers: {"Accept": "application/json"}).then((response) {
      var body = json.decode(response.body);
      List<Game> games =
          body["results"].map<Game>((json) => Game.fromMap(json)).toList();
      return db.backfillGames(games);
    });
  }

  Future<List<Game>> getSearch([int offset = 0]) async {
    if (searchController.text == "") {
      return [];
    }
    return getGames("$API_SEARCH${searchController.text}", offset);
  }

  Future<List<Game>> getPopularGames([int offset = 0]) async {
    return getGames(API_SOME, offset);
  }

  Future<List<Game>> getFavoriteGames([int offset = 0]) async {
    return db.getFavoriteGames(offset);
  }

  // TODO: Add logging to FB
  viewGame(Game game, context) async {
    debugPrint("Here thugh");
    if (game != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameScreen(game: game, bloc: this)));
    }
  }

  dispose() {
    searchController.dispose();
    _searchStreamController.close();
    _favoriteStreamController.close();
    _popularStreamController.close();
    _interactStreamController.close();
  }
}
