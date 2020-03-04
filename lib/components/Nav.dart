import 'package:flutter/material.dart';
import '../GameBLoC.dart';
import '../Colors.dart';

class IgniteNav extends StatefulWidget with PreferredSizeWidget {
  IgniteNav({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  final GameBLoC bloc;

  @override
  State createState() => new _IgniteNavState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _IgniteNavState extends State<IgniteNav> {
  @override
  Widget build(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      backgroundColor: BAR_COLOR,
      title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: new InputDecoration(
              border: InputBorder.none,
              hintText: 'Keywords in the title',
              labelText: 'Search',
              prefixIcon: const Icon(
                Icons.code,
                color: Colors.white,
              ),
              labelStyle:
                  TextStyle(fontFamily: "arcadeclassic", color: Colors.white),
              hintStyle: const TextStyle(color: Colors.white)),
          controller: widget.bloc.searchController),
    );
  }
}
