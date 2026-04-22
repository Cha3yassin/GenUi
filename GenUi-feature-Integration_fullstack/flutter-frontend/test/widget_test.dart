import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahil/main.dart';

void main() {
  testWidgets('Sahil app renders the home branding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SahilApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sahil'), findsAtLeastNWidgets(1));
    expect(find.text('ساهل'), findsAtLeastNWidgets(1));
  });
}
