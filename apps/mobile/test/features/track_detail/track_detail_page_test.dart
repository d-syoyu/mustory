import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/track_detail/presentation/track_detail_page.dart';

void main() {
  testWidgets('shows track detail tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TrackDetailPage(trackId: 'demo-track'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('物語'), findsOneWidget);
    expect(find.text('コメント'), findsOneWidget);
  });
}
