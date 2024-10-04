import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:payos_demo_flutter/screen/cancel_screen.dart';
import 'package:payos_demo_flutter/screen/home_screen.dart';
import 'package:payos_demo_flutter/screen/payment_screen.dart';
import 'package:payos_demo_flutter/screen/success_screen.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
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
        routes: [
          GoRoute(
              path: 'payment',
              builder: (BuildContext context, GoRouterState state) =>
                  PaymentScreen()),
          GoRoute(
              path: 'success',
              builder: (BuildContext context, GoRouterState state) => SuccessScreen()),
          GoRoute(
              path: 'cancel',
              builder: (BuildContext context, GoRouterState state) => CancelScreen()),
        ]),
  ],
);
