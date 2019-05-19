import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';



void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameCodeInputController = new TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Carolina Ignites'),
      ),
      body: Center(
        child: Column(
          children: [ new Text("To play a game, enter the game's code:"),
          TextField(
            decoration: 
              InputDecoration(
                border: InputBorder.none,
                hintText: 'Type Here!'
              ),
            controller: gameCodeInputController
          ),
          RaisedButton(
          child: Text('Launch Game'),
          onPressed: () {
            if(gameCodeInputController.text.length > 0)
            {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameScreen(gameCode: gameCodeInputController.text)),
            );
            }
            
          },
        )]
        )
      )
    );
  }
}

class GameScreen extends StatelessWidget {
  
  final String gameCode;

  //constructor
  GameScreen({Key key, @required this.gameCode}): super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
  ]);

    return WebviewScaffold(
      url: "https://api.carolinaignites.org/app/" + this.gameCode,
      appBar: new AppBar(
        title: new Text("Widget WebView"),
      ), 
    );
  }
}