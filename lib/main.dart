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
import "PageBuilder.dart";

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
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        body: Container(color: Color(0xFF73000a)));
    }

    return Scaffold(
        body: Container(
            color: Color(0xFF73000a),
            child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.1),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(children: [
                        Column(children: [
                          Row(children: <Widget>[
                            new Text('Arcade ',
                                style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.075,
                                    fontFamily: "arcadeclassic",
                                    color: Colors.white)),
                            new Text('Frame',
                                style: TextStyle(
                                    fontSize:MediaQuery.of(context).size.width * 0.1,
                                    fontFamily: "arcadeclassic",
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ]),
                        Column(children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: IconButton(
                                iconSize: MediaQuery.of(context).size.width * 0.1,
                                icon:
                                    new Image.asset("assets/icons/gamepad.png"),
                              ))
                        ])
                      ])),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: new Text(
                          "To play a game, enter the game's code below:",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                          decoration: new InputDecoration(
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.white, width: 2.0)),
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.black, width: 2.0)),
                              hintText: 'Check the Editor URL',
                              labelText: 'Game Code',
                              prefixIcon: const Icon(
                                Icons.code,
                                color: Colors.white,
                              ),
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              hintStyle: const TextStyle(color: Colors.white)),
                          controller: gameCodeInputController)),
                  RaisedButton(
                    color: Colors.white,
                    child: Text('Launch Game',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
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
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  new Text("Games Played:",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
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
                      child: Text("Clear Games",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        clearGames().then((e) {
                          setState(() {});
                        });
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
  final flutterWebViewPlugin = FlutterWebviewPlugin(); 

  WebViewController _controller;

  //function to get the data field of the gameframe game
  Future<String> getWebPacket(String code) async {
    http.Response response = await http.get(
        Uri.encodeFull("https://api.carolinaignites.org/" + code),
        headers: {
          //if your api require key then pass your key here as well e.g "key": "my-long-key"
          "Accept": "application/json"
        });
    var body = json.decode(response.body);
    String data = utf8.decode(base64.decode(body["data"]));
    return data;

    //code for reading webpacket, could be used later.
    /*var packet = json.decode(data);
      var hashedHTML =packet['html'];
      HTML =  utf8.decode(base64.decode(hashedHTML));
      var hashedJS = packet['code'];
      JS = utf8.decode(base64.decode(hashedJS));
      var hashedMeta = packet['meta'];
      //meta = utf8.decode(base64.decode(hashedMeta));
      print(packet); */ 
  }

  Future _launchGame(String value) async { 
    var pageBuilder = PageBuilder();
    String jsScript = await pageBuilder.getJSBoiler();
    String jsScriptWithLookup = jsScript.replaceAll("window.location.pathname.split('/')[2]", "'" + widget.gameCode + "'");
    _controller.evaluateJavascript(jsScriptWithLookup); 
    //setState(() {});
  }
  

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
      initialUrl:"https://www.carolinaignites.org/assets/html/mobileBoiler.html",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController c) {
        _controller = c;
      },
      onPageFinished: _launchGame
    );
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebViewPlugin.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitUpMode();
  }
}

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
