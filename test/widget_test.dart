import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/main.dart';
import 'package:meals/screens/auth.dart';

void main() {
  testWidgets('App loads and shows categories title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(startScreen: AuthScreen()),
      ),
    );

    expect(find.text('Categories'), findsOneWidget);
  });
}
