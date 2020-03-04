import 'package:flutter/material.dart';
import "../Colors.dart";

class IgniteHeader extends StatefulWidget {
  const IgniteHeader({
    Key key,
    @required this.scroll,
  }) : super(key: key);

  final double scroll;

  @override
  State createState() => new _IgniteHeaderState();
}

class _IgniteHeaderState extends State<IgniteHeader> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      new Positioned(
          top: widget.scroll,
          child: Padding(
              padding: EdgeInsets.only(top: 10, left: 20),
              child: Row(children: [
                Column(children: [
                  Row(children: <Widget>[
                    new Text('Arcade',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.075,
                            fontFamily: "arcadeclassic",
                            color: ARCADE_COLOR)),
                    new Text('Frame',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.1,
                            fontFamily: "arcadeclassic",
                            color: FRAME_COLOR,
                            fontWeight: FontWeight.bold))
                  ]),
                ]),
                Column(children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: IconButton(
                        iconSize: MediaQuery.of(context).size.width * 0.1,
                        icon: new Image.asset("assets/icons/gamepad.png"),
                        onPressed: (){}
                      ))
                ])
              ]))),
    ]);
  }
}
