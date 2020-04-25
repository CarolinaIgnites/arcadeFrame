import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

import "../Game.dart";
import "../GameBLoC.dart";

class Like extends StatefulWidget {
  Like(
    this.game,
    this.bloc,
    this.paused, {
    Key key,
  }) : super(key: key);

  final Game game;
  final GameBLoC bloc;
  final bool paused;

  @override
  State createState() => new _LikeState();
}

class _LikeState extends State<Like> {
  bool faved;

  @override
  void initState() {
    super.initState();
    faved = widget.game.favourited;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: Container(
            width: 32,
            height: 32,
            child: new FlareActor("assets/icons/heart.flr",
                isPaused: widget.paused,
                snapToEnd: widget.paused,
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: widget.game.favourited ^ widget.paused
                    ? "Like"
                    : "Unlike")),
        onPressed: () {
          widget.bloc.toggleLike(widget.game);
        });
  }
}
