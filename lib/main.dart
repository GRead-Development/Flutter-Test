import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/providers/activity_provider.dart';
import 'package:gread_app/providers/library_provider.dart';
import 'package:gread_app/screens/splash_screen.dart';

void main() {
  runApp(const GReadApp());
}

class GReadApp extends StatelessWidget {
  const GReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (_) => ActivityProvider(null),
          update: (_, auth, previous) => ActivityProvider(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LibraryProvider>(
          create: (_) => LibraryProvider(null),
          update: (_, auth, previous) => LibraryProvider(auth.token),
        ),
      ],
      child: MaterialApp(
        title: 'GRead',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
