import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class QuickPrompt {
  final String text;
  final IconData icon;
  final Color color;
  bool isSelected;

  QuickPrompt({
    required this.text,
    required this.icon,
    required this.color,
    this.isSelected = false,
  });
}

class WhatIfQuestion {
  final String question;
  final IconData icon;
  final Color color;

  WhatIfQuestion({
    required this.question,
    required this.icon,
    required this.color,
  });
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}

class SimulationResults {
  final double currentScenario;
  final double newScenario;
  final String insight;
  final List<FlSpot> currentPath;
  final List<FlSpot> newPath;
  final int monthsSaved;

  SimulationResults({
    required this.currentScenario,
    required this.newScenario,
    required this.insight,
    required this.currentPath,
    required this.newPath,
    required this.monthsSaved,
  });
}

class AIAssistantViewModel {
  // Current financial state
  double currentMonthlyIncome = 75000.0;
  double currentMonthlyExpenses = 45000.0;
  double currentMonthlySavings = 30000.0;
  double currentSavingsBalance = 450000.0;

  // What-if scenario variables
  double savingsIncrease = 0.0;
  double incomeChange = 0.0;
  double expenseReduction = 0.0;

  // Quick prompts
  List<QuickPrompt> quickPrompts = [];
  
  // What-if questions
  List<WhatIfQuestion> whatIfQuestions = [];
  
  // Chat messages
  List<ChatMessage> chatMessages = [];

  // Simulation results
  SimulationResults? simulationResults;

  // Financial goal
  double financialGoal = 1000000.0; // 10 Lakhs goal
  int monthsToGoal = 18; // Current projection

  void loadInitialData() {
    _loadQuickPrompts();
    _loadWhatIfQuestions();
  }

  void _loadQuickPrompts() {
    quickPrompts = [
      QuickPrompt(
        text: 'Save ₹5,000 more/month?',
        icon: Icons.savings,
        color: const Color(0xFF22C55E),
      ),
      QuickPrompt(
        text: 'Invest in gold?',
        icon: Icons.diamond,
        color: const Color(0xFFF59E0B),
      ),
      QuickPrompt(
        text: 'Stop eating out?',
        icon: Icons.restaurant,
        color: const Color(0xFFEF4444),
      ),
      QuickPrompt(
        text: 'Start a SIP?',
        icon: Icons.calendar_today,
        color: const Color(0xFF8B5CF6),
      ),
      QuickPrompt(
        text: 'Reduce subscriptions?',
        icon: Icons.subscriptions,
        color: const Color(0xFF3B82F6),
      ),
      QuickPrompt(
        text: 'Buy or lease car?',
        icon: Icons.directions_car,
        color: const Color(0xFF06B6D4),
      ),
    ];
  }

  void _loadWhatIfQuestions() {
    whatIfQuestions = [
      WhatIfQuestion(
        question: 'What if I save ₹5,000 more per month?',
        icon: Icons.trending_up,
        color: const Color(0xFF22C55E),
      ),
      WhatIfQuestion(
        question: 'What if I invest in gold instead of stocks?',
        icon: Icons.diamond,
        color: const Color(0xFFF59E0B),
      ),
      WhatIfQuestion(
        question: 'What if I stop eating out for 3 months?',
        icon: Icons.restaurant_menu,
        color: const Color(0xFFEF4444),
      ),
      WhatIfQuestion(
        question: 'What if I increase my SIP by ₹2,000?',
        icon: Icons.calendar_month,
        color: const Color(0xFF8B5CF6),
      ),
      WhatIfQuestion(
        question: 'What if I pay off my loan early?',
        icon: Icons.credit_card,
        color: const Color(0xFF3B82F6),
      ),
      WhatIfQuestion(
        question: 'What if I retire 5 years earlier?',
        icon: Icons.beach_access,
        color: const Color(0xFF06B6D4),
      ),
      WhatIfQuestion(
        question: 'What if I buy a house now vs later?',
        icon: Icons.home,
        color: const Color(0xFFEC4899),
      ),
      WhatIfQuestion(
        question: 'What if I switch to a higher paying job?',
        icon: Icons.work,
        color: const Color(0xFF10B981),
      ),
    ];
  }

  void selectPrompt(QuickPrompt prompt) {
    for (var p in quickPrompts) {
      p.isSelected = false;
    }
    prompt.isSelected = true;

    // Auto-fill slider based on prompt
    if (prompt.text.contains('₹5,000')) {
      savingsIncrease = 5000.0;
    } else if (prompt.text.contains('eating out')) {
      expenseReduction = 3000.0;
    } else if (prompt.text.contains('subscriptions')) {
      expenseReduction = 2000.0;
    }
  }

  void runSimulation() {
    // Calculate new monthly savings
    final newMonthlySavings = currentMonthlySavings + 
                              savingsIncrease + 
                              (incomeChange - (-expenseReduction));

    // Calculate months to reach goal
    final currentMonthsToGoal = _calculateMonthsToGoal(
      currentSavingsBalance,
      financialGoal,
      currentMonthlySavings,
    );

    final newMonthsToGoal = _calculateMonthsToGoal(
      currentSavingsBalance,
      financialGoal,
      newMonthlySavings,
    );

    final monthsSaved = currentMonthsToGoal - newMonthsToGoal;

    // Generate insight
    String insight;
    if (monthsSaved > 0) {
      insight = '🎉 Great! You\'ll achieve your ₹${(financialGoal / 100000).toStringAsFixed(0)}L goal $monthsSaved months earlier!';
    } else if (monthsSaved < 0) {
      insight = '⚠️ These changes will delay your goal by ${monthsSaved.abs()} months. Consider adjusting.';
    } else {
      insight = 'These changes will keep you on track with your current timeline.';
    }

    // Generate projection paths
    final currentPath = _generateProjectionPath(
      currentSavingsBalance,
      currentMonthlySavings,
      12,
    );

    final newPath = _generateProjectionPath(
      currentSavingsBalance,
      newMonthlySavings,
      12,
    );

    simulationResults = SimulationResults(
      currentScenario: currentSavingsBalance + (currentMonthlySavings * 12),
      newScenario: currentSavingsBalance + (newMonthlySavings * 12),
      insight: insight,
      currentPath: currentPath,
      newPath: newPath,
      monthsSaved: monthsSaved,
    );
  }

  int _calculateMonthsToGoal(
    double currentBalance,
    double goalAmount,
    double monthlySavings,
  ) {
    if (monthlySavings <= 0) return 999; // Invalid scenario
    
    final remainingAmount = goalAmount - currentBalance;
    if (remainingAmount <= 0) return 0;
    
    return (remainingAmount / monthlySavings).ceil();
  }

  List<FlSpot> _generateProjectionPath(
    double startingBalance,
    double monthlySavings,
    int months,
  ) {
    List<FlSpot> spots = [];
    double balance = startingBalance;

    for (int i = 0; i < months; i++) {
      spots.add(FlSpot(i.toDouble(), balance));
      balance += monthlySavings;
    }

    return spots;
  }

  // Helper methods for AI insights
  String getFinancialHealthScore() {
    final savingsRate = (currentMonthlySavings / currentMonthlyIncome) * 100;
    
    if (savingsRate >= 40) {
      return 'Excellent';
    } else if (savingsRate >= 30) {
      return 'Good';
    } else if (savingsRate >= 20) {
      return 'Fair';
    } else {
      return 'Needs Improvement';
    }
  }

  double getSavingsRate() {
    return (currentMonthlySavings / currentMonthlyIncome) * 100;
  }

  String getEmergencyFundStatus() {
    final monthsOfExpenses = currentSavingsBalance / currentMonthlyExpenses;
    
    if (monthsOfExpenses >= 6) {
      return 'Well Protected';
    } else if (monthsOfExpenses >= 3) {
      return 'Moderately Protected';
    } else {
      return 'At Risk';
    }
  }

  double getMonthsOfExpensesCovered() {
    return currentSavingsBalance / currentMonthlyExpenses;
  }

  List<String> getPersonalizedRecommendations() {
    List<String> recommendations = [];

    // Savings rate check
    final savingsRate = getSavingsRate();
    if (savingsRate < 30) {
      recommendations.add(
        'Try to increase your savings rate to at least 30% of your income.'
      );
    }

    // Emergency fund check
    final monthsCovered = getMonthsOfExpensesCovered();
    if (monthsCovered < 6) {
      recommendations.add(
        'Build your emergency fund to cover at least 6 months of expenses.'
      );
    }

    // Expense analysis
    final expenseRatio = (currentMonthlyExpenses / currentMonthlyIncome) * 100;
    if (expenseRatio > 60) {
      recommendations.add(
        'Your expenses are ${expenseRatio.toStringAsFixed(0)}% of income. Look for areas to cut back.'
      );
    }

    // Investment suggestion
    if (currentSavingsBalance > 100000 && savingsRate > 20) {
      recommendations.add(
        'Consider investing a portion of your savings for better returns.'
      );
    }

    return recommendations;
  }

  Map<String, dynamic> getScenarioComparison(String scenarioType) {
    switch (scenarioType) {
      case 'save_more':
        return {
          'title': 'Save ₹5,000 More Per Month',
          'impact': '+₹60,000 per year',
          'goalImpact': '3-4 months earlier',
          'recommendation': 'Highly recommended for faster goal achievement',
        };
      
      case 'invest_gold':
        return {
          'title': 'Invest in Gold (10% allocation)',
          'impact': 'Potential 8-12% annual returns',
          'goalImpact': 'Diversification benefit',
          'recommendation': 'Good for portfolio diversification',
        };
      
      case 'stop_eating_out':
        return {
          'title': 'Reduce Dining Out',
          'impact': 'Save ₹3,000-5,000/month',
          'goalImpact': '2-3 months earlier',
          'recommendation': 'Easy win for quick savings boost',
        };
      
      default:
        return {};
    }
  }

  double calculateSIPReturns(
    double monthlyInvestment,
    double annualReturn,
    int years,
  ) {
    final monthlyReturn = annualReturn / 12 / 100;
    final months = years * 12;
    
    // Future value of SIP formula
    double futureValue = monthlyInvestment * 
      ((pow(1 + monthlyReturn, months) - 1) / monthlyReturn) * 
      (1 + monthlyReturn);
    
    return futureValue;
  }

  double pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  // Investment vs Savings comparison
  Map<String, double> compareInvestmentVsSavings(
    double amount,
    int years,
  ) {
    final savingsAmount = amount * years * 12; // No interest
    final investmentAmount = calculateSIPReturns(amount, 12.0, years); // 12% return
    
    return {
      'savings': savingsAmount,
      'investment': investmentAmount,
      'difference': investmentAmount - savingsAmount,
    };
  }

  // Debt payoff calculator
  Map<String, dynamic> calculateDebtPayoff(
    double principal,
    double interestRate,
    double monthlyPayment,
  ) {
    int months = 0;
    double remainingBalance = principal;
    double totalInterest = 0;

    while (remainingBalance > 0 && months < 360) { // Max 30 years
      final monthlyInterest = (remainingBalance * interestRate / 12 / 100);
      totalInterest += monthlyInterest;
      remainingBalance = remainingBalance + monthlyInterest - monthlyPayment;
      months++;

      if (remainingBalance < 0) remainingBalance = 0;
    }

    return {
      'months': months,
      'years': (months / 12).toStringAsFixed(1),
      'totalInterest': totalInterest,
      'totalPaid': principal + totalInterest,
    };
  }

  // Retirement calculator
  double calculateRetirementCorpus(
    int currentAge,
    int retirementAge,
    double monthlyExpenses,
    double inflationRate,
  ) {
    final yearsToRetirement = retirementAge - currentAge;
    const retirementYears = 25; // Assume 25 years after retirement
    
    // Calculate future monthly expenses accounting for inflation
    final futureMonthlyExpenses = monthlyExpenses * 
      pow(1 + inflationRate / 100, yearsToRetirement);
    
    // Calculate corpus needed (assuming 6% withdrawal rate)
    final corpusNeeded = (futureMonthlyExpenses * 12 * retirementYears) / 0.06;
    
    return corpusNeeded;
  }

  // Tax saving calculator
  double calculateTaxSavings(double investment) {
    // Assuming 30% tax bracket
    final taxSaved = investment * 0.3;
    return taxSaved;
  }

  void resetSimulation() {
    savingsIncrease = 0.0;
    incomeChange = 0.0;
    expenseReduction = 0.0;
    simulationResults = null;
    
    for (var prompt in quickPrompts) {
      prompt.isSelected = false;
    }
  }

  // Chat management methods
  void addUserMessage(String message) {
    chatMessages.add(ChatMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
  }

  void generateAIResponse(String userMessage) {
    String response;
    List<String>? suggestions;

    final lowerMessage = userMessage.toLowerCase();

    // Pattern matching for different types of questions
    if (lowerMessage.contains('save') && lowerMessage.contains('5000')) {
      response = 'Great question! Saving an additional ₹5,000 per month would give you:\n\n'
          '💰 Extra ₹60,000 per year\n'
          '📈 Your ₹10L goal achieved 3-4 months earlier\n'
          '🎯 Total savings of ₹8.1L in 18 months\n\n'
          'Would you like me to run a detailed simulation?';
      suggestions = ['Run simulation', 'Compare with other options', 'Show me a plan'];
    } else if (lowerMessage.contains('gold')) {
      response = 'Investing in gold is a good diversification strategy! Here\'s what you should know:\n\n'
          '✨ Gold typically returns 8-12% annually\n'
          '🛡️ Acts as a hedge against inflation\n'
          '⚖️ Recommended allocation: 10-15% of portfolio\n\n'
          'Current gold price is around ₹6,200/gram. Want to explore gold investment options?';
      suggestions = ['Gold ETFs', 'Digital gold', 'Sovereign Gold Bonds'];
    } else if (lowerMessage.contains('eating out') || lowerMessage.contains('restaurant')) {
      response = 'Cutting down on dining out is one of the easiest ways to save! Average Indian households spend ₹3,000-8,000/month eating out.\n\n'
          '💡 If you reduce by 50%: Save ₹2,500/month\n'
          '💡 If you stop completely: Save ₹5,000/month\n'
          '📊 Annual savings: ₹30,000-60,000\n\n'
          'This could achieve your goal 2-3 months earlier!';
      suggestions = ['Calculate my savings', 'Meal planning tips', 'Set a budget'];
    } else if (lowerMessage.contains('sip') || lowerMessage.contains('mutual fund')) {
      response = 'Starting a SIP is excellent for long-term wealth creation!\n\n'
          '📈 Average mutual fund returns: 12-15% p.a.\n'
          '🎯 Best for goals 3+ years away\n'
          '💪 Rupee cost averaging benefit\n\n'
          'A ₹5,000 monthly SIP for 10 years at 12% return = ₹11.6 lakhs!\n'
          'Would you like me to suggest some funds?';
      suggestions = ['Top rated funds', 'Calculate SIP returns', 'Start SIP guide'];
    } else if (lowerMessage.contains('loan') || lowerMessage.contains('debt')) {
      response = 'Paying off loans early can save significant interest! Let me help you analyze:\n\n'
          '🏦 What type of loan? (Home/Personal/Car)\n'
          '💰 Outstanding amount?\n'
          '📊 Current interest rate?\n\n'
          'I\'ll calculate how much you can save by prepaying!';
      suggestions = ['Personal loan', 'Home loan', 'Car loan'];
    } else if (lowerMessage.contains('retire') || lowerMessage.contains('retirement')) {
      response = 'Planning early retirement? Smart thinking! Here\'s what matters:\n\n'
          '🎯 Retirement corpus needed = 25-30x annual expenses\n'
          '📈 Start investing more aggressively now\n'
          '💡 Consider NPS for tax benefits\n\n'
          'Tell me your target retirement age and monthly expenses, and I\'ll create a plan!';
      suggestions = ['Calculate corpus', 'Investment strategy', 'Tax saving tips'];
    } else if (lowerMessage.contains('house') || lowerMessage.contains('property')) {
      response = 'Buying vs waiting is a big decision! Key factors to consider:\n\n'
          '🏠 NOW: Lock current prices, start building equity\n'
          '⏳ LATER: More savings, potentially better rates\n'
          '💰 Down payment ready? Aim for 20-30%\n'
          '📊 EMI should be <40% of income\n\n'
          'What\'s your current savings and target property price?';
      suggestions = ['Calculate EMI', 'Down payment needed', 'Compare rent vs buy'];
    } else if (lowerMessage.contains('job') || lowerMessage.contains('salary')) {
      response = 'A higher salary can accelerate all your financial goals!\n\n'
          '💼 Even a 20% increase = Major impact\n'
          '🎯 Use raise wisely: 50% to savings/investments\n'
          '📈 Update financial goals with new income\n\n'
          'What salary increase are you expecting? Let me show the impact!';
      suggestions = ['Show impact of 20% raise', '30% raise', '50% raise'];
    } else {
      response = 'I\'m here to help with your financial planning! I can help you with:\n\n'
          '💰 Savings strategies\n'
          '📊 Investment advice\n'
          '🎯 Goal planning\n'
          '💳 Debt management\n'
          '🏠 Major purchases\n\n'
          'Try asking me a "What if" question or choose from the suggestions below!';
      suggestions = [
        'Save ₹5,000 more',
        'Start investing',
        'Plan retirement',
        'Buy a house'
      ];
    }

    chatMessages.add(ChatMessage(
      message: response,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    ));
  }

  void clearChat() {
    chatMessages.clear();
  }

  void updateFinancialData({
    double? income,
    double? expenses,
    double? savings,
    double? savingsBalance,
  }) {
    if (income != null) currentMonthlyIncome = income;
    if (expenses != null) currentMonthlyExpenses = expenses;
    if (savings != null) currentMonthlySavings = savings;
    if (savingsBalance != null) currentSavingsBalance = savingsBalance;
  }
}