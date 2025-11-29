// ignore_for_file: use_build_context_synchronously
import 'package:shared_preferences/shared_preferences.dart';
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
  static PorcupineService? porcupineService;

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
  Future<void> testVoiceCommand(BuildContext context) async {
    bool initialized = await _porcupineService.initialize();

    if (!initialized) {
      return;
    }

    // Temporarily enable for testing
    await _porcupineService.enable();

    // Auto stop after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (_porcupineService.isListening) {
        _porcupineService.disable();
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
    loadToggleState();
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

  // Add this constant at the top of the class
  static const String _voiceEnabledKey = 'voice_assistant_enabled';

// Check and auto-enable voice on app start
  static Future<void> initializeVoiceOnAppStart() async {
  final prefs = await SharedPreferences.getInstance();
  final isVoiceEnabled = prefs.getBool(_voiceEnabledKey) ?? false;

  // Create and initialize the global service
  porcupineService = PorcupineService();
  bool initialized = await porcupineService!.initialize();

  if (initialized && isVoiceEnabled) {
    await porcupineService!.enable();
  }
}

// Save voice state
  Future<void> _saveVoiceState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceEnabledKey, value);
  }

// Load saved state to update toggle UI
  Future<void> loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    voiceEnabled.value = prefs.getBool(_voiceEnabledKey) ?? false;
  }

  // Update the voice toggle in OnboardingController
  void toggleVoiceAssistant(bool value, BuildContext context) async {
    voiceEnabled.value = value;

    // Use the global service if available
    final service = porcupineService ?? _porcupineService;

    if (value) {
      bool initialized = await service.initialize();

      if (!initialized) {
        voiceEnabled.value = false;
        await _saveVoiceState(false);
        return;
      }

      await service.enable();
      await _saveVoiceState(true);
    } else {
      await service.disable();
      await _saveVoiceState(false);
    }
  }

  // Validate current page before moving forward
  bool validateCurrentPage(BuildContext context) {
    // Add BuildContext parameter
    switch (currentPage.value) {
      case 1: // Profile Setup
        if (selectedName.value.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your name'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        if (selectedGoals.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one financial goal'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
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

// Override nextPage to include validation
  void nextPageWithValidation(BuildContext context) {
    // Add BuildContext parameter
    if (validateCurrentPage(context)) {
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
