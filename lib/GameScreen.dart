import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import 'package:games_services/games_services.dart';
import 'package:games_services/models/score.dart';

import "Analytics.dart";
import "Game.dart";
import "GameBLoC.dart";
import "PageBuilder.dart";
import "Constants.dart";

import "components/Report.dart";

class GameScreen extends StatefulWidget {
  final Game game;
  final GameBLoC bloc;

  @override
  State createState() => new GameScreenState();

  //constructor
  GameScreen({Key key, @required this.game, this.bloc}) : super(key: key);
}

class GameScreenState extends State<GameScreen> {
  final PageBuilder builder = PageBuilder();
  GameBLoC bloc;

  // To prevent double execution of code.
  bool isActive = false;
  bool newScore = false;

  Future<void> _loadSources(String _unused) {

    if (!isActive) {
      isActive = true;
      return builder.loadSources(widget.game, _controller, bloc);
    }
    return null;
  }

  Future<void> dispatchEvent(String key, String data) {
    return _controller.evaluateJavascript("(function(){"
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
                  newScore = true;
                  widget.game.highscore = highscore;
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
                // TODO: Move some of this logic to BLoC
                var score = int.parse(message.message);
                widget.game.plays += 1;
                bloc.saveGame(widget.game);
                analytics.logEvent(
                  name: 'play',
                  parameters: <String, dynamic>{
                    'game': widget.game.hash,
                    'title': widget.game.name,
                    'plays': widget.game.plays,
                    'highscore': widget.game.highscore,
                    'score': score,
                  },
                );
                if (newScore) {
                  analytics.logPostScore(
                    score: score,
                    level: widget.game.plays,
                    character: widget.game.hash,
                  );
                  if (LEADERBOARDS.containsKey(widget.game.hash)) {
                    await widget.bloc.login();
                    debugPrint(LEADERBOARDS[widget.game.hash]);
                    GamesServices.submitScore(
                        score: Score(
                            androidLeaderboardID:
                                LEADERBOARDS[widget.game.hash],
                            value: score));
                  }
                }
                newScore = false;
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
              }),
          wv.JavascriptChannel(
              name: 'ToggleLike',
              onMessageReceived: (wv.JavascriptMessage message) async {
                widget.bloc.toggleLike(widget.game, "in_game");
              }),
          wv.JavascriptChannel(
              name: 'Report',
              onMessageReceived: (wv.JavascriptMessage message) async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return IgniteReport(game: widget.game);
                    });
              }),
          wv.JavascriptChannel(
              name: 'Share',
              onMessageReceived: (wv.JavascriptMessage message) async {
                Share.share(
                    '${widget.game.name}: https://api.carolinaignites.org/app/${widget.game.hash}',
                    subject: 'Try out this game:');
                analytics.logEvent(
                  name: 'share',
                  parameters: <String, dynamic>{
                    'game': widget.game.hash,
                    'title': widget.game.name,
                    'plays': widget.game.plays,
                  },
                );
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
