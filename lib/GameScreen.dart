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
import "PageBuilder.dart";
import "Constants.dart";
import "Database.dart";

class GameScreen extends StatefulWidget {
  final Game game;

  @override
  State createState() => new GameScreenState();

  //constructor
  GameScreen({Key key, @required this.game}) : super(key: key);
}

class GameScreenState extends State<GameScreen> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final PageBuilder builder = PageBuilder();
  final DBProvider db = DBProvider.db;

  // To prevent double execution of code.
  bool is_active = false;

  Future<void> _loadSources(String _unused) {
    if (!is_active) {
      is_active = true;
      builder.loadSources(widget.game, _controller);
    }
  }

  WebViewController _controller;
  @override
  void initState() {
    //get JS from webpacket
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    AutoOrientation.landscapeRightMode();
  }

  @override
  Widget build(BuildContext context) {
    return new WebView(
        initialUrl: "",
        javascriptMode: JavascriptMode.unrestricted,
        gestureRecognizers: Set()
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()))
          ..add(Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer())),
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'SetScore',
              onMessageReceived: (JavascriptMessage message) {
                var highscore = int.parse(message.message);
                if (highscore > widget.game.highscore){
                  widget.game.highscore = highscore;
                  db.updateGame(widget.game);
                }
              }),
          JavascriptChannel(
              name: 'GetScore',
              onMessageReceived: (JavascriptMessage message) async {
                await _controller.evaluateJavascript(
                    "window.__highscore=${widget.game.highscore};");
                return widget.game.highscore;
              })
        ]),
        onWebViewCreated: (WebViewController c) {
          _controller = c;
          builder.getPage().then((String page) {
            _controller.loadUrl(page);
          });
        },
        onPageFinished: _loadSources);
  }

  @override
  void dispose() {
    super.dispose();
    is_active = false;
    flutterWebViewPlugin.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitUpMode();
  }
}
