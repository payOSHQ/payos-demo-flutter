import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:payos_demo_flutter/screen/home_screen.dart';
import 'package:payos_demo_flutter/screen/payment_screen.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => HomeScreen(),
    ),
    GoRoute(
        path: '/payment',
        builder: (BuildContext context, GoRouterState state) =>
            PaymentScreen()),
  ],
);
