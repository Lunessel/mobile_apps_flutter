import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hydro Monitor'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
  });
}
