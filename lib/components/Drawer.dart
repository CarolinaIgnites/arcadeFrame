import 'package:flutter/material.dart';
import '../Constants.dart';
import 'Dialog.dart';

class IgniteDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          new IgniteDialog(title: "About Us", page: ABOUT_PAGE),
          new IgniteDialog(title: "Licenses", page: LICENSE_PAGE),
          new IgniteDialog(
              title: "Privacy Policy", page: PRIVACY_PAGE),
        ],
      ),
    );
  }
}
