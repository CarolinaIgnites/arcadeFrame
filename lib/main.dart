import 'package:flutter/material.dart';
import "ArcadeFrame.dart";

// TODO: Add load screen that queries api, to see if it needs new resources.
// If it needs resources, it pulls them. This allows for easy updates to
// gameframe without having to do an app update. Load screen should also init db,
// and manage schema changes. Could also set up PageBuilder in this time.
void main() => runApp(new ArcadeFrame());
