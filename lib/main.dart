import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_bloc.dart';
import 'package:mobile_app/cubits/alerts/alerts_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/cubits/mqtt/mqtt_cubit.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/screens/alerts_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';
import 'package:mobile_app/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(ServiceLocator.auth)),
        BlocProvider(
          create: (_) => ConnectivityCubit(ServiceLocator.connectivity),
        ),
        BlocProvider(create: (_) => MqttCubit(ServiceLocator.mqtt)),
        BlocProvider(create: (_) => AlertsCubit(ServiceLocator.alerts)),
        BlocProvider(
          create: (_) => MqttConfigBloc(
            ServiceLocator.mqtt,
            ServiceLocator.defaultMqttConfig,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Hydro Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/alerts': (context) => const AlertsScreen(),
        },
      ),
    );
  }
}
