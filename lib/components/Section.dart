import 'package:flutter/material.dart';
import "../Colors.dart";
import "../Game.dart";
import "../GameBLoC.dart";
import "Card.dart";

class IgniteSection extends StatefulWidget {
  const IgniteSection(
      {Key key,
      @required this.title,
      @required this.channel,
      this.visible = true})
      : super(key: key);

  final String title;
  final GameChannel channel;
  final bool visible;

  @override
  State createState() => new _IgniteSectionState();
}

class _IgniteSectionState extends State<IgniteSection> {
  bool visible;
  bool prev = false;

  @override
  void initState() {
    super.initState();
    visible = widget.visible;
    widget.channel.request();
    widget.channel.visibilityListener = (bool result) => setState(() {
          visible = result;
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Provide header and load more option.
    return StreamBuilder(
        stream: widget.channel.stream,
        builder: (context, AsyncSnapshot<List<Game>> snapshot) {
          return new SliverList(delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (snapshot.data == null || !visible) {
                return null;
              }

              if (index == 0) {
                return Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: new Text("${widget.title}",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontFamily: "arcadeclassic",
                            color: ARCADE_COLOR)));
              }
              index -= 1;

              if (index >= snapshot.data.length) return null;
              return new IgniteCard(
                  snapshot.data[index], widget.channel.context);
            },
          ));
        });
  }
}
