import 'package:flutter/material.dart';

class IgniteDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("About Us"),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: Text("Licenses"),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: Text("Privacy Policy"),
            trailing: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
