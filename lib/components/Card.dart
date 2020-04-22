import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'dart:async';
import 'dart:math';

import "../Colors.dart";
import "../Game.dart";
import "../GameBLoC.dart";
import "Like.dart";

List<String> powers = ["K", "M", "B", "T", "P"];

String textify(int value) {
  if (value == 0) return "0";
  int power = min(log(value + 1) ~/ ln10, powers.length * 3);
  if (power < 3) return "$value";
  int index = (power ~/ 3) - 1;
  double short = (value ~/ pow(10, power - (power % 3 + 1))) / 10;
  return "$short${powers[index]}";
}

class IgniteCard extends StatefulWidget {
  const IgniteCard(
    this.game,
    this.bloc, {
    Key key,
  })  : assert(game != null),
        super(key: key);

  final Game game;
  final GameBLoC bloc;

  @override
  State createState() => new _IgniteCardState();
}

class _IgniteCardState extends State<IgniteCard> {
  Game _game;
  StreamSubscription<Game> subscription;
  bool paused;

  @override
  void initState() {
    super.initState();
    _refresh(widget.game);
    paused = true;
  }

  _refresh(game) {
    _game = widget.bloc.getCurrentGame(game);
    widget.game.favourited = _game.favourited;
    if (subscription != null) subscription.cancel();
    subscription = widget.bloc.registerGameListener(_game, update);
  }

  update(Game game) {
    setState(() {
      if (widget.game.hash == game.hash) {
        _refresh(game);
        paused = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _refresh(widget.game);
    return new Card(
        color: BACKGROUND_COLOR,
        margin: const EdgeInsets.only(
          right: 30,
          left: 50,
          top: 5,
          bottom: 5,
        ),
        clipBehavior: Clip.none,
        child: Ink.image(
            image: ExactAssetImage('assets/card.png'),
            fit: BoxFit.fill,
            child: InkWell(
                onTap: () {
                  widget.bloc.saveGame(_game);
                  widget.bloc.viewGame(_game, context);
                },
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                    title: Text(_game.name),
                    subtitle: Text(_game.subtitle ?? ""),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text("HIGHSCORE: ${textify(_game.highscore)}",
                            style: TextStyle(fontFamily: "arcadeclassic")),
                        onPressed: () {/* TODO: Maybe show highset score. */},
                      ),
                      FlatButton(
                        child: Text("PLAYS: ${textify(_game.plays)}",
                            style: TextStyle(fontFamily: "arcadeclassic")),
                        onPressed: () {/* // TODO: Maybe show total plays */},
                      ),
                      // TODO: Break out into own component.
                      // new Like(_game, widget.bloc),
                      FlatButton(
                          child: Container(
                              width: 32,
                              height: 32,
                              child: new FlareActor("assets/icons/heart.flr",
                                  isPaused: paused,
                                  snapToEnd: paused,
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                  animation: _game.favourited ^ paused
                                      ? "Like"
                                      : "Unlike")),
                          onPressed: () {
                            _game.favourited = !_game.favourited;
                            widget.bloc.saveGame(_game).then((game) {
                              widget.bloc.favoriteChannel.request();
                            });
                          })
                    ],
                  ),
                ]))));
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }
}
