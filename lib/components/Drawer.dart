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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.");
                      },
                      fullscreenDialog: true,
                    ));
              }),
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
