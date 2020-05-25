import 'package:flutter/material.dart';

import "Game.dart";
import "GameBLoC.dart";
import "Colors.dart";

import "components/Section.dart";
import "components/Nav.dart";
import "components/Header.dart";
import "components/Drawer.dart";

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

class ArcadeFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _HomeScreen(),
        theme: ThemeData(fontFamily: 'Helvetica') //default font for entire app
        );
  }
}

class _HomeScreen extends StatefulWidget {
  @override
  State createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  GameBLoC bloc;
  double scroll = 0.0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    bloc = GameBLoC();
    initUniLinks();
  }

  @override
  void dispose() {
    // Clean up the bloc when the widget is removed from the
    // widget tree.
    bloc.dispose();
    super.dispose();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    bloc.searchChannel.request();
    bloc.favoriteChannel.request();
    bloc.popularChannel.request();
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  Future<Null> initUniLinks() async {
    print("initUniLinks");
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Uri uri = await getInitialUri();
      await loadFromUri(uri);
    } on PlatformException {
      debugPrint("uri failed...");
    }
    getUriLinksStream().listen(loadFromUri);
  }

  loadFromUri(Uri uri) async {
    print("loadFromUri");
    if (uri == null) return;
    var segs = uri.pathSegments;
    if (segs.length != 2 && segs[0] != "app") return;
    print(segs[1]);
    Game game = await bloc.queryGame(segs[1]);
    if (game == null) {
      return;
    }
    bloc.viewGame(game, context, "QR");
  }


  @override
  Widget build(BuildContext context) {
    var devicePhysicalPixelWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
    var headerPadding = (devicePhysicalPixelWidth > 1000) ? MediaQuery.of(context).size.width * 0.1 : 64; //2048 == iPad Pro width
    print(devicePhysicalPixelWidth);

    // TODO: Use media queries to make more responsive.
    // final Orientation orientation = MediaQuery.of(context).orientation;
    // final bool isLandscape = orientation == Orientation.landscape;
    return new Scaffold(
        appBar: new IgniteNav(bloc: bloc),
        drawer: new IgniteDrawer(bloc: bloc),
        backgroundColor: BACKGROUND_COLOR,
        body: RefreshIndicator(
          key: refreshKey,
          child: new NotificationListener(
              onNotification: (event) {
                if (event is ScrollUpdateNotification)
                  setState(() => scroll -= event.scrollDelta / 2);
                return false;
              },
              child: new Stack(children: <Widget>[
                new IgniteHeader(scroll: scroll),
                CustomScrollView(slivers: <Widget>[
                  new SliverPadding(
                      padding: EdgeInsets.only(top: headerPadding.toDouble()),
                      sliver: new IgniteSection(
                          title: "Favorites",
                          channel: bloc.favoriteChannel,
                          hideable: true)),
                  new IgniteSection(
                      title: "Popular Games",
                      channel: bloc.popularChannel,
                      missing_message: ":( \n offline..."),
                  new IgniteSection(
                      title: "Search Results",
                      channel: bloc.searchChannel,
                      visible: false,
                      missing_message: ":( \n no \n results"),
                ])
              ])),
          onRefresh: refreshList,
        ));
  }
}
