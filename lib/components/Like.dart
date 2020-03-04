import 'package:flutter/material.dart';

import "../Game.dart";
import "../GameBLoC.dart";

class Like extends StatefulWidget {
  Like(
    this.game,
    this.bloc, {
    Key key,
  }) : super(key: key);

  final Game game;
  final GameBLoC bloc;

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
        child: Text(faved ? "FAVED" : "FAV"),
        onPressed: () {
          widget.game.favourited = !widget.game.favourited;
          faved = widget.game.favourited;
          widget.bloc.saveGame(widget.game).then((game) {
            widget.bloc.favoriteChannel.request();
          });
        });
  }
}
