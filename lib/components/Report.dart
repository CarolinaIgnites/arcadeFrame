import 'package:flutter/material.dart';
import '../Game.dart';
import '../Analytics.dart';

class IgniteReport extends StatelessWidget {
  IgniteReport({Key key, @required this.game}) : super(key: key);

  final Game game;
  TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report a game'),
      content: TextField(
        controller: _textFieldController,
        decoration:
            InputDecoration(hintText: "Tell us what's wrong with the game."),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('REPORT'),
          onPressed: () {
            analytics.logEvent(
              name: 'report',
              parameters: <String, dynamic>{
                'game': game.hash,
                'title': game.name,
                'plays': game.plays,
                'message': _textFieldController.text,
              },
            );
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
