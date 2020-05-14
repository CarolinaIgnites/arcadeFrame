import 'package:flutter/material.dart';
import '../GameBLoC.dart';
import '../Constants.dart';
import 'Dialog.dart';

class IgniteDrawer extends StatelessWidget {
  IgniteDrawer({Key key, @required this.bloc}) : super(key: key);

  final GameBLoC bloc;

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          new ListTile(
            title: Text('Games'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          new IgniteDialog(title: "About Us", page: ABOUT_PAGE),
          new IgniteDialog(title: "FAQ", page: FAQ_PAGE),
          new IgniteDialog(title: "Legal", page: LEGAL_PAGE),
          new IgniteDialog(title: "Privacy Policy", page: PRIVACY_PAGE),
          new IgniteDialog(title: "Licenses", page: LICENSE_PAGE),
          if (bloc.isSignedIn)
            new ListTile(
                title: Text('Show Achievements'),
                onTap: bloc.launchAchievements),
        ],
      ),
    );
  }
}
