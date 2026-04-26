import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/providers/connectivity_provider.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ConnectivityProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Hydro Monitor'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
  });
}
