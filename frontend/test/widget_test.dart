import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_idarty/core/api/api_providers.dart';
import 'package:f_idarty/core/api/mock_api_service.dart';
import 'package:f_idarty/features/quiz/quiz_screen.dart';

void main() {
  testWidgets('quiz renders an AI generated widget plan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(MockApiService()),
          ],
          child: const QuizScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('AI generated quiz'), findsOneWidget);
    expect(find.text('Genere par IA'), findsOneWidget);
    expect(find.text('Mock AI'), findsOneWidget);
    expect(find.text('Question 1/3'), findsOneWidget);
    expect(find.text('What should you verify before an office visit?'),
        findsOneWidget);
  });
}
