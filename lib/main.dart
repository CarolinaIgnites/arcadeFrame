import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(fontFamily: 'Helvetica') //default font for entire app
    );
  }
}

/////////////////////////////////////////////////////////////////
/// HOME SCREEN /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
class HomeScreen extends StatefulWidget {
  @override
  State createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var savedGames = [];

  @override
  void initState() {
    getSavedGames().then((result) {
      setState(() {
        savedGames = result;
      });
    });
  }

////////////////////////SAVING PLAYED GAMES TO A FILE///////////
////////////////////////////////////////////////////////////////
  //find correct file path
  Future get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //create reference to file location
  Future get _localFile async {
    final path = await _localPath;
    return File('$path/gamesPlayed.txt');
  }

  //write data to file
  Future addCode(String code) async {
    final file = await _localFile;
    // Write the file
    //savedGames.a(code);
    String codeWithNewLine = code + "\n";

    if (savedGames.contains(code)) {
      return;
    }

    file.writeAsString(codeWithNewLine, mode: FileMode.append);
    return getSavedGames().then((result) {
      setState(() {
        savedGames = result;
      });
    });
  }

  //read data from file

  Future getSavedGames() async {
    try {
      final file = await _localFile;

      // Read the file
      List<String> contents = await file.readAsLines();
      //List<String> codes = contents.split(" ");
      return contents;
    } catch (e) {
      // If we encounter an error, return 0
      return "0";
    }
  }

  //clear file
  Future clearGames() async {
    final file = await _localFile;
    // Write the file
    getSavedGames().then((result) {
      setState(() {
        savedGames = result;
      });
    });
    return file.writeAsString('');
  }
/////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final gameCodeInputController = new TextEditingController();

    return Scaffold(
        body: Container(
            color: Color(0xFF73000a),
            child: Padding(
                padding: EdgeInsets.all(50),
                child: Column(children: [
                  Padding(padding: EdgeInsets.only(right: 0), child:
                  Row( children: [
                    Column(children: [
                      Row(children:<Widget>[
                  new Text('Arcade ',
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: "arcadeclassic",
                          color: Colors.white
                          )), new Text('Frame',
                      style: TextStyle(
                          fontSize: 55,
                          fontFamily: "arcadeclassic",
                          color: Colors.black,
                          fontWeight: FontWeight.bold))]),
                      
                    ]),
                     Column(children: [                   
                      Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: IconButton(
                        iconSize: 30,
                        icon: new Image.asset("assets/icons/gamepad.png"),
                      ))])
                   ])),
                  Padding(padding: EdgeInsets.symmetric(vertical: 30)), 
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: new Text("To play a game, enter the game's code below:", 
                          style: TextStyle(
                              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                          decoration: new InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide( color: Colors.white, width: 2.0)),
                              focusedBorder: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide( color: Colors.black, width: 2.0)),
                              hintText: 'Check the Editor URL',
                              labelText: 'Game Code',
                              prefixIcon: const Icon(
                                Icons.code,
                                color: Colors.white,
                              ),
                              labelStyle:
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), hintStyle: const TextStyle(color: Colors.white)),
                          controller: gameCodeInputController)),
                  RaisedButton(
                    color: Colors.white,
                    child: Text('Launch Game', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (gameCodeInputController.text.length > 0) {
                        addCode(gameCodeInputController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameScreen(
                                  gameCode: gameCodeInputController.text)),
                        );
                      }
                    },
                  ),
                  Padding(padding:EdgeInsets.symmetric(vertical: 10)),
                  new Text("Games Played:", style:TextStyle(
                              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  new ListView.builder(
                      padding: EdgeInsets.all(0.0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: savedGames.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new RaisedButton(
                            color: Colors.white,
                            child: Text(savedGames[index]),
                            onPressed: () {
                              gameCodeInputController.text = savedGames[index];
                            });
                      }),
                  new RaisedButton(
                      color: Colors.white,
                      child: Text("Clear Games", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        clearGames();
                      })
                ]))));
  }
}
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////
/// GAME SCREEN /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
class GameScreen extends StatefulWidget {
  final String gameCode;

  @override
  State createState() => new GameScreenState();

  //constructor
  GameScreen({Key key, @required this.gameCode}) : super(key: key);
}

class GameScreenState extends State<GameScreen> {
  //function to get the data field of the gameframe game
  Future<String> getWebPacket(String code) async {
    http.Response response = await http.get(
        Uri.encodeFull("https://api.carolinaignites.org/" + code),
        headers: {
          //if your api require key then pass your key here as well e.g "key": "my-long-key"
          "Accept": "application/json"
        });
    //List data = json.decode(response.body);
    var body = json.decode(response.body);
    String data = utf8.decode(base64.decode(body["data"]));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*/

    return WebviewScaffold(
      url: "https://api.carolinaignites.org/app/" +
          widget
              .gameCode, //widget."field" is how you access inherited variables...
      appBar: new AppBar(
        title: new Text("Widget WebView"),
      ),
    );
  }
}
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
