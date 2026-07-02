import 'package:flutter/material.dart';

import 'app_state.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/chat_page.dart';
import 'pages/swipe_page.dart';
import 'pages/profile_page.dart';
import 'pages/logout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'PeerPair',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          ),
          home: appState.currentUser == null
              ? LoginPage(appState: appState)
              : const HomePage(),
          routes: {
            '/login': (context) => LoginPage(appState: appState),
            '/register': (context) => RegisterPage(appState: appState),
            '/home': (context) => const HomePage(),
            '/swipe': (context) => SwipePage(appState: appState),
            '/chat': (context) => ChatPage(appState: appState),
            '/profile': (context) => ProfilePage(appState: appState),
            '/logout': (context) => LogoutPage(appState: appState),
          },
        );
      },
    );
  }
}