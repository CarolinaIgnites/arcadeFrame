import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
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

  Future<void> dispatchEvent(String key, String data) {
    return _controller.evaluateJavascript(
        "(function(){"
        "let event = new CustomEvent(`${key}`, {detail: { data: `${data}` }});"
        "window.dispatchEvent(event);"
        "})();");
  }

  wv.WebViewController _controller;
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
    return new wv.WebView(
        initialUrl: "",
        javascriptMode: wv.JavascriptMode.unrestricted,
        gestureRecognizers: Set()
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()))
          ..add(Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer())),
        javascriptChannels: Set.from([
          wv.JavascriptChannel(
              name: 'SetScore',
              onMessageReceived: (wv.JavascriptMessage message) async {
                var highscore = int.parse(message.message);
                if (highscore > widget.game.highscore) {
                  widget.game.highscore = highscore;
                  debugPrint("the json ${widget.game.json}");
                  bloc.saveGame(widget.game);
                }
              }),
          wv.JavascriptChannel(
              name: 'GetScore',
              onMessageReceived: (wv.JavascriptMessage message) async {
                _controller.evaluateJavascript(
                    "window.__highscore=${widget.game.highscore};");
              }),
          wv.JavascriptChannel(
              name: 'GameOver',
              onMessageReceived: (wv.JavascriptMessage message) async {
                widget.game.plays += 1;
                debugPrint("plays ${widget.game.plays}");
                bloc.saveGame(widget.game);
              }),
          wv.JavascriptChannel(
              name: 'SetCache',
              onMessageReceived: (wv.JavascriptMessage message) async {
                const String sep = "|";
                List<String> key_value = message.message.split(sep);
                String key = key_value[0];
                String value = key_value.sublist(1).join(sep);
                String data = await bloc.setImage(widget.game, key, value);
                dispatchEvent("set|${key}", data);
              }),
          wv.JavascriptChannel(
              name: 'GetCache',
              onMessageReceived: (wv.JavascriptMessage message) async {
                String key = message.message;
                String data = await bloc.getImage(widget.game, key);
                dispatchEvent(key, data);
              })
        ]),
        navigationDelegate: (wv.NavigationRequest request) {
          return wv.NavigationDecision.prevent;
        },
        onWebViewCreated: (wv.WebViewController c) {
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
