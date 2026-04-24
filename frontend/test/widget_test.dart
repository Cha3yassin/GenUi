import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fbureaucracy/main.dart';

void main() {
  testWidgets('Fbureaucracy app renders the home branding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FbureaucracyApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Fbureaucracy'), findsAtLeastNWidgets(1));
  });
}
