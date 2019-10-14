import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "ArcadeFrame.dart";

// TODO: Add load screen that queries api, to see if it needs new resources.
// If it needs resources, it pulls them. This allows for easy updates to
// gameframe without having to do an app update.
void main() => runApp(new ArcadeFrame());
