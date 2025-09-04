import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'welcome_page.dart';
import 'features_page.dart';
import 'crops_page.dart';
import 'firebase_options.dart';
import 'Otplogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getNextPage(User? user) async {
    if (user == null) return const LoginPage();

    final prefs = await SharedPreferences.getInstance();
    final seenWelcome = prefs.getBool("seenWelcome") ?? false;
    final seenFeatures = prefs.getBool("seenFeatures") ?? false;
    final selectedCrops = prefs.getStringList("selectedCrops");

    if (!seenWelcome) return const WelcomePage();
    if (!seenFeatures) return const FeaturesPage();
    if (selectedCrops == null || selectedCrops.isEmpty) {
      return const CropSelectionPage();
    }

    return HomePage(crops: selectedCrops);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Farm Flow",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          return FutureBuilder<Widget>(
            future: _getNextPage(snapshot.data),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              if (snap.hasError) {
                return const Scaffold(
                  body: Center(child: Text("❌ Error loading app")),
                );
              }
              return snap.data ?? const LoginPage();
            },
          );
        },
      ),
      routes: {
        "/login": (context) => const LoginPage(),
        "/welcome": (context) => const WelcomePage(),
        "/features": (context) => const FeaturesPage(),
        "/crops": (context) => const CropSelectionPage(),
        "/dashboard": (context) {
          // This route is less likely to be used directly, but we can try to get crops.
          // A better approach would be to manage this with a state management solution.
          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingScreen();
              final crops = snapshot.data!.getStringList('selectedCrops') ?? [];
              return HomePage(crops: crops);
            },
          );
        },
        "/otp": (context) => const PhoneLoginPage(),
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
