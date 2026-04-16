import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hydro Monitor'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
  });

  testWidgets('Navigate to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Зареєструватися'));
    await tester.pumpAndSettle();

    expect(find.text('Реєстрація'), findsOneWidget);
  });
}
