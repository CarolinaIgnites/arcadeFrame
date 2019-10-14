import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:auto_orientation/auto_orientation.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import "Game.dart";
import "GameScreen.dart";
import "Constants.dart";
import "Database.dart";

import 'dart:developer';

class ArcadeFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: HomeScreen(),
        theme: ThemeData(fontFamily: 'Helvetica') //default font for entire app
        );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Game> savedGames = [];
  String gamesLabel = "Popular Games";
  DBProvider db = DBProvider.db;

  @override
  void initState() {
    db.initDB();
    /* TODO: Once we set up a favourite button
    getFavouriteGames().then((result) {
      setState(() {
        favedGames = result;
      });
    });
    */
    getDefaultGames().then((result) {
      setState(() {
        savedGames = result;
      });
    });
  }

  // TODO: Also update api that game was played.
  // Potential race condition, becasue PageBuilder expects the game to be set.
  // but I think to get to that point is pretty slow, so we should be good.
  Future saveGame(Game game) async {
    game.plays += 1;
    if (!game.saved) {
      return db.newGame(game);
    }
    return db.updateGame(game);
  }

  Future getDefaultGames() async {
    return http.get(Uri.encodeFull(API_SOME),
        headers: {"Accept": "application/json"}).then((response) {
      var body = json.decode(response.body);
      List<Game> games =
          body["results"].map<Game>((json) => Game.fromMap(json)).toList();
      return db.backfillGames(games);
    });
  }

  Future getFavouriteGames() async {
    // TODO: Extract favorite games for display
  }

  @override
  Widget build(BuildContext context) {
    final gameCodeInputController = new TextEditingController();
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(body: Container(color: Color(0xFF73000a)));
    }

    return Scaffold(
        body: Container(
            color: Color(0xFF73000a),
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.1),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(children: [
                        Column(children: [
                          Row(children: <Widget>[
                            new Text('Arcade ',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.075,
                                    fontFamily: "arcadeclassic",
                                    color: Colors.white)),
                            new Text('Frame',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.1,
                                    fontFamily: "arcadeclassic",
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ]),
                        Column(children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: IconButton(
                                iconSize:
                                    MediaQuery.of(context).size.width * 0.1,
                                icon:
                                    new Image.asset("assets/icons/gamepad.png"),
                              ))
                        ])
                      ])),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.white, width: 2.0)),
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.white, width: 2.0)),
                              hintText: 'Keywords in the title',
                              labelText: 'Search for a game',
                              prefixIcon: const Icon(
                                Icons.code,
                                color: Colors.white,
                              ),
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              hintStyle: const TextStyle(color: Colors.white)),
                          controller: gameCodeInputController)),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  new Text(gamesLabel,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  new ListView.builder(
                      padding: EdgeInsets.all(0.0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: savedGames.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new RaisedButton(
                          color: Colors.white,
                          child: Text(savedGames[index].name),
                          onPressed: () {
                            saveGame(savedGames[index]);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GameScreen(
                                          game: savedGames[index],
                                        )));
                          },
                        );
                      }),
                ]))));
  }
}
