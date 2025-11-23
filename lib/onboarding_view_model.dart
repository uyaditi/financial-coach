// ignore_for_file: use_build_context_synchronously

import 'package:ezmoney/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'porcupine_service.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final OnboardingPageType type;
  final Widget? customContent; // For custom UI pages

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    this.type = OnboardingPageType.info,
    this.customContent,
  });
}

enum OnboardingPageType {
  info,
  profileSetup,
  voiceSetup,
  accountConnection,
}

// Controller (ViewModel)
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool isLastPage = false.obs;
  final PorcupineService _porcupineService = PorcupineService();

  // Profile Setup Variables
  final RxString selectedName = ''.obs;
  final RxString selectedIncomeType = 'Salaried Employee'.obs;
  final RxDouble monthlyIncome = 50000.0.obs;
  final incomeTypes = [
    'Gig Worker / Freelancer',
    'Salaried Employee',
    'Business Owner',
    'Student / Other'
  ];

  // Financial Goals Variables
  final RxList<String> selectedGoals = <String>[].obs;
  final goals = [
    {'icon': '💰', 'title': 'Build Emergency Fund'},
    {'icon': '📊', 'title': 'Start Investing'},
    {'icon': '🏠', 'title': 'Save for Big Purchase'},
    {'icon': '💳', 'title': 'Manage Debt/Loans'},
    {'icon': '🎯', 'title': 'Budget Better'},
    {'icon': '🌴', 'title': 'Plan Retirement'},
  ];
  final RxDouble riskAppetite =
      1.0.obs; // 0: Conservative, 1: Moderate, 2: Aggressive

  // Voice Setup Variables
  final RxBool voiceEnabled = false.obs;
  final RxString wakeCommand = 'Hey Fin'.obs;
  final RxString selectedLanguage = 'English'.obs;
  final RxBool emotionAnalysisEnabled = true.obs;
  final languages = ['English', 'हिंदी', 'मराठी', 'தமிழ்', 'తెలుగు'];

  // Account Connection Variables
  final RxList<String> connectedBanks = <String>[].obs;
  final RxList<String> connectedAccounts =
      <String>[].obs; // FIXED: Changed from connectedInvestments

  final List<OnboardingPage> onboardingPages = [];

  // Update the testVoiceCommand method
// Replace the entire testVoiceCommand method
  Future<void> testVoiceCommand(BuildContext context) async {
    bool initialized = await _porcupineService.initialize();

    if (!initialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please grant microphone permission'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // First disable if already running
    await _porcupineService.disable();
    await Future.delayed(const Duration(milliseconds: 500));

    bool wakeWordDetected = false;
    bool commandReceived = false;

    _porcupineService.onWakeWordDetected = () {
      debugPrint('DEBUG: Wake word detected in test mode!');
      wakeWordDetected = true;

      // Clear previous snackbars
      ScaffoldMessenger.of(context).clearSnackBars();

      // Show listening for command
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('🎤 Listening for your command... (10 seconds)'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    _porcupineService.onCommandRecognized = (command) {
      debugPrint('DEBUG: Command recognized in test mode: $command');
      commandReceived = true;

      // Clear any existing snackbars
      ScaffoldMessenger.of(context).clearSnackBars();

      // Show the recognized command
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Command Received:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                command.isEmpty ? 'No command detected' : command,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          backgroundColor: command.isEmpty ? Colors.orange : Colors.blue,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Auto-stop test mode after command is recognized
      Future.delayed(const Duration(seconds: 3), () {
        _porcupineService.stopListening();
        debugPrint('DEBUG: Test mode stopped');
      });
    };

    _porcupineService.onError = (error) {
      debugPrint('DEBUG: Error in test mode: $error');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    };

    // Enable the service for testing
    await _porcupineService.enable();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('🎤 Test Mode Active - Say "Hey Fin" now...'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Auto stop after 30 seconds if no wake word detected
    Future.delayed(const Duration(seconds: 30), () {
      if (_porcupineService.isListening && !commandReceived) {
        _porcupineService.stopListening();
        ScaffoldMessenger.of(context).clearSnackBars();

        if (!wakeWordDetected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test mode timeout - No wake word detected'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
          debugPrint('DEBUG: Test mode timeout - No wake word');
        }
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    _initializePages();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
      isLastPage.value = currentPage.value == onboardingPages.length - 1;
    });
  }

  void _initializePages() {
    onboardingPages.addAll([
      // Page 1: Info/Welcome
      OnboardingPage(
        title: 'Your AI Financial\nCoaching Companion',
        description:
            'Get personalized financial advice powered by AI. Track, manage, and grow your wealth effortlessly with voice-first banking.',
        icon: Icons.psychology_alt,
        primaryColor: const Color(0xFF4F46E5),
        type: OnboardingPageType.info,
      ),

      // Page 2: Profile Setup
      OnboardingPage(
        title: 'Let\'s Set Up\nYour Profile',
        description:
            'Tell us about yourself so we can personalize your experience',
        icon: Icons.person_outline,
        primaryColor: const Color(0xFF10B981),
        type: OnboardingPageType.profileSetup,
      ),

      // Page 3: Voice Setup
      OnboardingPage(
        title: 'Enable Voice\nAssistant',
        description: 'Control your finances hands-free with voice commands',
        icon: Icons.mic_none,
        primaryColor: const Color(0xFF8B5CF6),
        type: OnboardingPageType.voiceSetup,
      ),

      // Page 4: Account Connection
      OnboardingPage(
        title: 'Connect Your\nAccounts',
        description: 'Link your financial accounts for a complete overview',
        icon: Icons.account_balance_outlined,
        primaryColor: const Color(0xFFF59E0B),
        type: OnboardingPageType.accountConnection,
      ),
    ]);
  }

  // Toggle Goal Selection
  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else {
      selectedGoals.add(goal);
    }
  }

  // Toggle Bank Connection
  void toggleBank(String bank) {
    if (connectedBanks.contains(bank)) {
      connectedBanks.remove(bank);
    } else {
      connectedBanks.add(bank);
    }
  }

  // Toggle Account Connection - FIXED: Changed from toggleInvestment
  void toggleAccount(String account) {
    if (connectedAccounts.contains(account)) {
      connectedAccounts.remove(account);
    } else {
      connectedAccounts.add(account);
    }
  }

  // Page Change Handler
  void onPageChanged(int index) {
    currentPage.value = index;
    isLastPage.value = index == onboardingPages.length - 1;
  }

  // Next Page
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Previous Page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip Onboarding
  void skipOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  // Complete Onboarding
  void completeOnboarding() {
    Get.offAllNamed('/home');
  }

  // Update the voice toggle in OnboardingController
  // Update the toggleVoiceAssistant method
  void toggleVoiceAssistant(bool value, BuildContext context) async {
    voiceEnabled.value = value;

    if (value) {
      // Enable voice assistant
      bool initialized = await _porcupineService.initialize();

      if (!initialized) {
        voiceEnabled.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please grant microphone permission to use voice commands'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      _porcupineService.onWakeWordDetected = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.mic, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child:
                      Text('🎤 Hey Fin Activated! Listening for 10 seconds...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      };

      _porcupineService.onCommandRecognized = (command) {
        debugPrint('DEBUG: Command recognized: $command');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You said:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(command),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Here you can process the command further
        _processVoiceCommand(command);
      };

      _porcupineService.onError = (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice Assistant Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      };

      _porcupineService.onStatusChanged = (isActive) {
        voiceEnabled.value = isActive;
      };

      await _porcupineService.enable();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child:
                    Text('✓ Voice Assistant Enabled - Say "Hey Fin" anytime'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Disable voice assistant
      await _porcupineService.disable();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice Assistant Disabled'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Add this method to process commands
  void _processVoiceCommand(String command) {
    // You can add command processing logic here
    debugPrint('Processing command: $command');

    // Example: Parse common commands
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('balance')) {
      debugPrint('User asked about balance');
    } else if (lowerCommand.contains('expense')) {
      debugPrint('User asked about expenses');
    } else if (lowerCommand.contains('budget')) {
      debugPrint('User asked about budget');
    }
  }

  // Validate current page before moving forward
  bool validateCurrentPage() {
    switch (currentPage.value) {
      case 1: // Profile Setup
        if (selectedName.value.isEmpty) {
          Get.snackbar(
            'Required',
            'Please enter your name',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return false;
        }
        if (selectedGoals.isEmpty) {
          Get.snackbar(
            'Required',
            'Please select at least one financial goal',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return false;
        }
        break;
      case 2: // Voice Setup
        // Optional validation for voice setup
        break;
      case 3: // Account Connection
        // Optional - can skip this step
        break;
    }
    return true;
  }

  // Override nextPage to include validation - FIXED: Method name
  void nextPageWithValidation() {
    if (validateCurrentPage()) {
      nextPage();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    _porcupineService.dispose();
    super.onClose();
  }
}
