import 'package:ezmoney/chat_view.dart';
import 'package:ezmoney/onboarding_view_model.dart';
import 'package:ezmoney/porcupine_service.dart';
import 'package:ezmoney/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Global instances
PorcupineService? globalPorcupineService;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OnboardingController.initializeVoiceOnAppStart();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupVoiceNavigation();
  }

  void _setupVoiceNavigation() {
    Future.delayed(const Duration(seconds: 1), () {
      try {
        globalPorcupineService = OnboardingController.porcupineService;
      } catch (e) {
        print('Could not get service from OnboardingController: $e');
      }

      if (globalPorcupineService != null) {
        globalPorcupineService!.onNavigateToChat = (command) {
          final context = navigatorKey.currentContext;
          
          if (context != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  initialMessage: command,
                  isFromVoice: true,
                ),
              ),
            );
            print('✅ Navigating to chat with command: $command');
          } else {
            print('❌ Navigator context not available');
          }
        };
        print('✅ Voice navigation callback set up successfully');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey, // Add this
      title: 'ezMoney',
      scaffoldMessengerKey: PorcupineService.scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}