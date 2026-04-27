import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/screens/login_screen.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(ServiceLocator.auth)),
          BlocProvider(
            create: (_) => ConnectivityCubit(ServiceLocator.connectivity),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Hydro Monitor'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
    expect(find.text('Зареєструватися'), findsOneWidget);
  });
}
