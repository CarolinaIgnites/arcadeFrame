import 'package:flutter/material.dart';
import "../Constants.dart";
import "../Colors.dart";
import "../Game.dart";
import "../GameBLoC.dart";
import "Card.dart";

class IgniteSection extends StatefulWidget {
  const IgniteSection(
      {Key key,
      @required this.title,
      @required this.channel,
      this.hideable = false,
      this.visible = true,
      this.missing_message = ":("})
      : super(key: key);

  final String title;
  final GameChannel channel;
  final bool hideable;
  final bool visible;
  final String missing_message;

  @override
  State createState() => new _IgniteSectionState();
}

class _IgniteSectionState extends State<IgniteSection> {
  bool visible;
  bool hideable;
  bool prev = false;
  String missing_message = ":(";

  @override
  void initState() {
    super.initState();
    visible = widget.visible;
    hideable = widget.hideable;
    missing_message = widget.missing_message;
    widget.channel.request();
    widget.channel.visibilityListener = (bool result) => setState(() {
          visible = result;
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Provide Load more option, or infinite scroll.
    return StreamBuilder(
        stream: widget.channel.stream,
        builder: (context, AsyncSnapshot<List<Game>> snapshot) {
          return new SliverList(delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              bool is_empty =
                  (snapshot.data == null || snapshot.data.length == 0);
              if (!visible || (is_empty && hideable)) {
                return null;
              }

              if (index == 0) {
                double width = MediaQuery.of(context).size.width;
                double adjustment =
                    (width > VIEW_SIZE) ? (width - VIEW_SIZE) / 2 : 0;
                return Padding(
                    padding: EdgeInsets.only(left: adjustment + 20),
                    child: new Text("${widget.title}",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontFamily: "arcadeclassic",
                            color: ARCADE_COLOR)));
              }

              if ((is_empty && index >= 2) ||
                  (!is_empty && index > snapshot.data.length)) {
                return null;
              } else if (is_empty) {
                return Center(
                    heightFactor: 3,
                    child: new Text(missing_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontFamily: "arcadeclassic",
                            color: ARCADE_COLOR)));
              }
              return new IgniteCard(
                  snapshot.data[index - 1], widget.channel.context);
            },
          ));
        });
  }
}
