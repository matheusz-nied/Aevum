import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android glass avoids backdrop blur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(child: SizedBox(width: 120, height: 80)),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('iOS glass keeps backdrop blur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(child: SizedBox(width: 120, height: 80)),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android forest background is idle after its first frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ForestBackground(child: SizedBox.expand())),
    );
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
