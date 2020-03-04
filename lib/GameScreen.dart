import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:auto_orientation/auto_orientation.dart';

import "Game.dart";
import "GameBLoC.dart";
import "PageBuilder.dart";

class GameScreen extends StatefulWidget {
  final Game game;
  final GameBLoC bloc;

  @override
  State createState() => new GameScreenState();

  //constructor
  GameScreen({Key key, @required this.game, this.bloc}) : super(key: key);
}

class GameScreenState extends State<GameScreen> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final PageBuilder builder = PageBuilder();
  GameBLoC bloc;

  // To prevent double execution of code.
  bool isActive = false;

  Future<void> _loadSources(String _unused) {
    if (!isActive) {
      isActive = true;
      return builder.loadSources(widget.game, _controller, bloc);
    }
    return null;
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
    bloc = widget.bloc;
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
                if (highscore > widget.game.highscore) {
                  widget.game.highscore = highscore;
                  debugPrint("the json ${widget.game.json}");
                  bloc.saveGame(widget.game);
                }
              }),
          JavascriptChannel(
              name: 'GetScore',
              // TODO: There's a bug where __highscore gets out of sync of
              // game.highscore, and produces glitchy looking results. Could
              // fix on gameframe side. 'await' does not fix race condition.
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
    isActive = false;
    flutterWebViewPlugin.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitUpMode();
  }
}
