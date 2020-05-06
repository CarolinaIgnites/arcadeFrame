// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:ArcadeFrame/ArcadeFrame.dart';

void main() {
  testWidgets('Test launch', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ArcadeFrame());
  });
}
