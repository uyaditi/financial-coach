import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_view_model.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            // Top Skip Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Obx(() {
                  final page =
                      controller.onboardingPages[controller.currentPage.value];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: page.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: page.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => controller.skipOnboarding(context),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: page.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Tab Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];

                  // Return different UI based on page type
                  switch (page.type) {
                    case OnboardingPageType.info:
                      return _buildInfoPage(page);
                    case OnboardingPageType.profileSetup:
                      return _buildProfileSetupPage(controller, page);
                    case OnboardingPageType.voiceSetup:
                      return _buildVoiceSetupPage(controller, page);
                    case OnboardingPageType.accountConnection:
                      return _buildAccountConnectionPage(controller, page);
                  }
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Button (Back)
                  Obx(() => SizedBox(
                        width: 60,
                        height: 60,
                        child: controller.currentPage.value > 0
                            ? IconButton(
                                onPressed: controller.previousPage,
                                icon: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      )),

                  // Center Dots Indicator
                  Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          controller.onboardingPages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width:
                                controller.currentPage.value == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == index
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )),

                  // Right Button (Next/Get Started)
                  // Right Button (Next/Get Started)
                  Obx(() {
                    final isLast = controller.isLastPage.value;
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: Builder(
                        builder: (BuildContext ctx) {
                          return IconButton(
                            onPressed: isLast
                                ? controller.completeOnboarding
                                : () => controller.nextPageWithValidation(
                                    ctx), // Pass context here
                            icon: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF6366F1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLast ? Icons.check : Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Page (Original design)
  Widget _buildInfoPage(OnboardingPage page) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Floating Elements Background
          Positioned(
            top: 50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.primaryColor.withValues(alpha: 0.1),
                    page.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.primaryColor.withValues(alpha: 0.08),
                    page.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
      
          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Container
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              page.primaryColor,
                              page.primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(90),
                          boxShadow: [
                            BoxShadow(
                              color: page.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Outer Ring
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // Icon
                            Center(
                              child: Icon(
                                page.icon,
                                size: 90,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
      
                // App Logo/Name Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: page.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: page.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: page.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EZMONEY AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: page.primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
      
                // Title with Gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      page.primaryColor,
                      page.primaryColor.withValues(alpha: 0.8),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
      
                // Description
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
      
                // Feature Pills
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFeaturePill('🎤 Voice-First', page.primaryColor),
                    _buildFeaturePill('🤖 AI-Powered', page.primaryColor),
                    _buildFeaturePill('🔒 Secure', page.primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // Profile Setup Page
  Widget _buildProfileSetupPage(
      OnboardingController controller, OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.primaryColor.withValues(alpha: 0.2),
                    page.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(page.icon, size: 60, color: page.primaryColor),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Name Input
          const Text(
            'Your Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => controller.selectedName.value = value,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Income Type
          const Text(
            'Income Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.incomeTypes.map((type) {
                  final isSelected =
                      controller.selectedIncomeType.value == type;
                  return GestureDetector(
                    onTap: () => controller.selectedIncomeType.value = type,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? page.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? page.primaryColor
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),

          // Monthly Income Range
          const Text(
            'Monthly Income Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${controller.monthlyIncome.value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: page.primaryColor,
                    ),
                  ),
                  Slider(
                    value: controller.monthlyIncome.value,
                    min: 10000,
                    max: 200000,
                    divisions: 19,
                    activeColor: page.primaryColor,
                    inactiveColor: page.primaryColor.withValues(alpha: 0.2),
                    onChanged: (value) =>
                        controller.monthlyIncome.value = value,
                  ),
                ],
              )),
          const SizedBox(height: 24),

          // Financial Goals
          const Text(
            'Select Your Financial Goals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return Obx(() => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.goals.map((goal) {
                    final isSelected =
                        controller.selectedGoals.contains(goal['title']);
                    return GestureDetector(
                      onTap: () => controller.toggleGoal(goal['title']!),
                      child: Container(
                        width: (constraints.maxWidth - 12) / 2,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? page.primaryColor.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? page.primaryColor
                                : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              goal['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? page.primaryColor
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ));
          }),
          const SizedBox(height: 24),

          // Risk Appetite
          const Text(
            'Risk Appetite',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final labels = ['Conservative', 'Moderate', 'Aggressive'];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels.map((label) {
                    final index = labels.indexOf(label);
                    final isSelected =
                        controller.riskAppetite.value.round() == index;
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? page.primaryColor
                            : const Color(0xFF6B7280),
                      ),
                    );
                  }).toList(),
                ),
                Slider(
                  value: controller.riskAppetite.value,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  activeColor: page.primaryColor,
                  inactiveColor: page.primaryColor.withValues(alpha: 0.2),
                  onChanged: (value) => controller.riskAppetite.value = value,
                ),
              ],
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Voice Setup Page
  Widget _buildVoiceSetupPage(
      OnboardingController controller, OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.primaryColor.withValues(alpha: 0.2),
                    page.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(page.icon, size: 60, color: page.primaryColor),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Enable Voice Assistant
          // Find this Container with the Switch (around line 560-590)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Voice Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Control finances with voice',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                // THIS IS THE FIX - Wrap Switch in Builder to get context
                Builder(
                  builder: (BuildContext ctx) {
                    return Obx(() => Switch(
                          value: controller.voiceEnabled.value,
                          onChanged: (value) =>
                              controller.toggleVoiceAssistant(value, ctx),
                          activeThumbColor: page.primaryColor,
                        ));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Wake Command
          const Text(
            'Wake Command',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: page.primaryColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.mic, color: page.primaryColor, size: 24),
                const SizedBox(width: 12),
                Obx(() => Text(
                      '"${controller.wakeCommand.value}"',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: page.primaryColor,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Selection
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.languages.map((language) {
                  final isSelected =
                      controller.selectedLanguage.value == language;
                  return GestureDetector(
                    onTap: () => controller.selectedLanguage.value = language,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? page.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? page.primaryColor
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),

          // Emotion Analysis
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: page.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: page.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: page.primaryColor, size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotion Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AI adapts tone based on your emotions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Switch(
                      value: controller.emotionAnalysisEnabled.value,
                      onChanged: (value) =>
                          controller.emotionAnalysisEnabled.value = value,
                      activeThumbColor: page.primaryColor,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Test Voice Button
          // Replace the existing Test Voice Button section in _buildVoiceSetupPage
          // In _buildVoiceSetupPage, replace the Test Voice Button:
          // Find the Test Voice Button (around line 720-730)
          Center(
            child: Builder(
              builder: (BuildContext ctx) {
                return ElevatedButton.icon(
                  onPressed: () {
                    controller.testVoiceCommand(ctx);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test: Say "Hey Fin"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: page.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Account Connection Page
  Widget _buildAccountConnectionPage(
      OnboardingController controller, OnboardingPage page) {
    final banks = [
      {'name': 'State Bank of India', 'icon': '🏦'},
      {'name': 'HDFC Bank', 'icon': '🏦'},
      {'name': 'ICICI Bank', 'icon': '🏦'},
      {'name': 'Axis Bank', 'icon': '🏦'},
      {'name': 'Google Pay', 'icon': '💳'},
      {'name': 'PhonePe', 'icon': '💳'},
      {'name': 'Paytm', 'icon': '💳'},
    ];

    final investments = [
      {'name': 'Zerodha', 'icon': '📊'},
      {'name': 'Groww', 'icon': '📈'},
      {'name': 'Upstox', 'icon': '📊'},
      {'name': 'CoinDCX', 'icon': '₿'},
      {'name': 'WazirX', 'icon': '₿'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.primaryColor.withValues(alpha: 0.2),
                    page.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(page.icon, size: 60, color: page.primaryColor),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Privacy Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your data stays on your device with federated AI',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Banking & Payments
          const Text(
            'Banking & Payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...banks.map((bank) {
            return Obx(() {
              final isConnected =
                  controller.connectedBanks.contains(bank['name']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? page.primaryColor
                        : const Color(0xFFE5E7EB),
                    width: isConnected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: page.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        bank['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    bank['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  trailing: isConnected
                      ? Icon(Icons.check_circle,
                          color: page.primaryColor, size: 28)
                      : TextButton(
                          onPressed: () => controller.toggleBank(bank['name']!),
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              color: page.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  onTap: () => controller.toggleBank(bank['name']!),
                ),
              );
            });
          }),
          const SizedBox(height: 32),

          // Section 2: Investments
          Row(
            children: [
              const Text(
                'Investments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...investments.map((investment) {
            return Obx(() {
              final isConnected =
                  controller.connectedAccounts.contains(investment['name']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? page.primaryColor
                        : const Color(0xFFE5E7EB),
                    width: isConnected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: page.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        investment['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    investment['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  trailing: isConnected
                      ? Icon(Icons.check_circle,
                          color: page.primaryColor, size: 28)
                      : TextButton(
                          onPressed: () =>
                              controller.toggleAccount(investment['name']!),
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              color: page.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  onTap: () => controller.toggleAccount(investment['name']!),
                ),
              );
            });
          }),
          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: page.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: page.primaryColor, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'You can add more accounts later in Settings',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
