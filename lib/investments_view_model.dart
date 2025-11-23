import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AssetClass {
  final String name;
  final double currentValue;
  final double investedAmount;
  final double returnPercentage;
  final double percentage;
  final IconData icon;
  final List<Color> colors;

  AssetClass({
    required this.name,
    required this.currentValue,
    required this.investedAmount,
    required this.returnPercentage,
    required this.percentage,
    required this.icon,
    required this.colors,
  });

  double get gainLoss => currentValue - investedAmount;
}

class AIInsight {
  final String type;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final String? actionText;

  AIInsight({
    required this.type,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
    this.actionText,
  });
}

class InvestmentsViewModel {
  // Portfolio overview data
  double totalPortfolioValue = 485750.50;
  double totalInvested = 450000.00;
  
  double get totalGainLoss => totalPortfolioValue - totalInvested;
  double get totalReturnPercentage => ((totalPortfolioValue - totalInvested) / totalInvested) * 100;
  
  // Gains and losses
  double totalGains = 52850.50;
  double totalLosses = 17100.00;

  // Asset classes
  List<AssetClass> assetClasses = [];

  // Portfolio performance data
  List<FlSpot> portfolioPerformanceData = [];

  // AI Insights
  List<AIInsight> aiInsights = [];

  void loadInvestments() {
    _loadAssetClasses();
    _loadPortfolioPerformance();
    _loadAIInsights();
  }

  void _loadAssetClasses() {
    assetClasses = [
      AssetClass(
        name: 'Stocks',
        currentValue: 145280.50,
        investedAmount: 130000.00,
        returnPercentage: 11.75,
        percentage: 29.9,
        icon: Icons.show_chart,
        colors: [
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
        ],
      ),
      AssetClass(
        name: 'Mutual Funds',
        currentValue: 168450.25,
        investedAmount: 160000.00,
        returnPercentage: 5.28,
        percentage: 34.7,
        icon: Icons.pie_chart,
        colors: [
          const Color(0xFF8B5CF6),
          const Color(0xFF7C3AED),
        ],
      ),
      AssetClass(
        name: 'SIPs',
        currentValue: 95820.00,
        investedAmount: 90000.00,
        returnPercentage: 6.47,
        percentage: 19.7,
        icon: Icons.calendar_today,
        colors: [
          const Color(0xFF22C55E),
          const Color(0xFF16A34A),
        ],
      ),
      AssetClass(
        name: 'Crypto',
        currentValue: 48650.75,
        investedAmount: 45000.00,
        returnPercentage: 8.11,
        percentage: 10.0,
        icon: Icons.currency_bitcoin,
        colors: [
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ],
      ),
      AssetClass(
        name: 'ETFs',
        currentValue: 27549.00,
        investedAmount: 25000.00,
        returnPercentage: 10.20,
        percentage: 5.7,
        icon: Icons.account_balance,
        colors: [
          const Color(0xFF06B6D4),
          const Color(0xFF0891B2),
        ],
      ),
    ];
  }

  void _loadPortfolioPerformance() {
    portfolioPerformanceData = [
      const FlSpot(0, 450000),  // Week 1
      const FlSpot(1, 462500),  // Week 2
      const FlSpot(2, 471200),  // Week 3
      const FlSpot(3, 485750),  // Week 4
    ];
  }

  void _loadAIInsights() {
    aiInsights = [
      AIInsight(
        type: 'RISK ALERT',
        message: 'Your crypto exposure is high for your risk profile. Consider rebalancing to maintain diversification.',
        icon: Icons.warning_amber_rounded,
        backgroundColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
        iconColor: const Color(0xFFEF4444),
        iconBackgroundColor: const Color(0xFFFEE2E2),
        textColor: const Color(0xFFDC2626),
        actionText: 'View Recommendations',
      ),
      AIInsight(
        type: 'SUGGESTION',
        message: 'Investing ₹2,000 more this month can achieve your retirement goal 3 months earlier.',
        icon: Icons.lightbulb_outline,
        backgroundColor: const Color(0xFFFEF3C7),
        borderColor: const Color(0xFFFDE68A),
        iconColor: const Color(0xFFF59E0B),
        iconBackgroundColor: const Color(0xFFFEF3C7),
        textColor: const Color(0xFFD97706),
        actionText: 'Adjust SIP',
      ),
      AIInsight(
        type: 'OPPORTUNITY',
        message: 'Your stock portfolio has outperformed the market by 4.2% this quarter. Consider increasing allocation.',
        icon: Icons.trending_up,
        backgroundColor: const Color(0xFFDCFCE7),
        borderColor: const Color(0xFFBBF7D0),
        iconColor: const Color(0xFF22C55E),
        iconBackgroundColor: const Color(0xFFDCFCE7),
        textColor: const Color(0xFF16A34A),
        actionText: 'Learn More',
      ),
      AIInsight(
        type: 'MILESTONE',
        message: '🎉 Congratulations! You\'ve reached 75% of your investment goal for this year.',
        icon: Icons.emoji_events,
        backgroundColor: const Color(0xFFF3E8FF),
        borderColor: const Color(0xFFE9D5FF),
        iconColor: const Color(0xFF8B5CF6),
        iconBackgroundColor: const Color(0xFFF3E8FF),
        textColor: const Color(0xFF7C3AED),
      ),
    ];
  }

  // Helper methods for investment management
  double getAssetAllocation(String assetName) {
    final asset = assetClasses.firstWhere(
      (a) => a.name == assetName,
      orElse: () => AssetClass(
        name: '',
        currentValue: 0,
        investedAmount: 0,
        returnPercentage: 0,
        percentage: 0,
        icon: Icons.error,
        colors: [],
      ),
    );
    return asset.percentage;
  }

  double getTotalReturns() {
    return totalGains - totalLosses;
  }

  String getRiskProfile() {
    final cryptoPercentage = getAssetAllocation('Crypto');
    if (cryptoPercentage > 15) {
      return 'Aggressive';
    } else if (cryptoPercentage > 8) {
      return 'Moderate-Aggressive';
    } else if (cryptoPercentage > 5) {
      return 'Moderate';
    } else {
      return 'Conservative';
    }
  }

  bool isPortfolioDiversified() {
    // Check if any single asset class exceeds 40% of portfolio
    return !assetClasses.any((asset) => asset.percentage > 40);
  }

  AssetClass getBestPerformingAsset() {
    if (assetClasses.isEmpty) {
      return AssetClass(
        name: 'None',
        currentValue: 0,
        investedAmount: 0,
        returnPercentage: 0,
        percentage: 0,
        icon: Icons.error,
        colors: [],
      );
    }
    return assetClasses.reduce((a, b) => 
      a.returnPercentage > b.returnPercentage ? a : b
    );
  }

  AssetClass getWorstPerformingAsset() {
    if (assetClasses.isEmpty) {
      return AssetClass(
        name: 'None',
        currentValue: 0,
        investedAmount: 0,
        returnPercentage: 0,
        percentage: 0,
        icon: Icons.error,
        colors: [],
      );
    }
    return assetClasses.reduce((a, b) => 
      a.returnPercentage < b.returnPercentage ? a : b
    );
  }

  double getProjectedValue(int months) {
    // Simple projection based on current average monthly return
    final currentMonthlyReturn = totalReturnPercentage / 12; // Assuming data is for 1 year
    final projectedReturn = currentMonthlyReturn * months;
    return totalPortfolioValue * (1 + projectedReturn / 100);
  }

  Map<String, double> getAssetDistribution() {
    Map<String, double> distribution = {};
    for (var asset in assetClasses) {
      distribution[asset.name] = asset.percentage;
    }
    return distribution;
  }

  void addNewInvestment(String assetName, double amount) {
    final index = assetClasses.indexWhere((a) => a.name == assetName);
    if (index != -1) {
      final asset = assetClasses[index];
      final newInvestedAmount = asset.investedAmount + amount;
      final newCurrentValue = asset.currentValue + amount;
      
      assetClasses[index] = AssetClass(
        name: asset.name,
        currentValue: newCurrentValue,
        investedAmount: newInvestedAmount,
        returnPercentage: ((newCurrentValue - newInvestedAmount) / newInvestedAmount) * 100,
        percentage: (newCurrentValue / totalPortfolioValue) * 100,
        icon: asset.icon,
        colors: asset.colors,
      );
      
      totalInvested += amount;
      totalPortfolioValue += amount;
    }
  }

  void updateAssetValue(String assetName, double newValue) {
    final index = assetClasses.indexWhere((a) => a.name == assetName);
    if (index != -1) {
      final asset = assetClasses[index];
      final oldValue = asset.currentValue;
      
      assetClasses[index] = AssetClass(
        name: asset.name,
        currentValue: newValue,
        investedAmount: asset.investedAmount,
        returnPercentage: ((newValue - asset.investedAmount) / asset.investedAmount) * 100,
        percentage: (newValue / totalPortfolioValue) * 100,
        icon: asset.icon,
        colors: asset.colors,
      );
      
      totalPortfolioValue = totalPortfolioValue - oldValue + newValue;
    }
  }

  void addAIInsight(AIInsight insight) {
    aiInsights.insert(0, insight);
  }

  void removeAIInsight(int index) {
    if (index >= 0 && index < aiInsights.length) {
      aiInsights.removeAt(index);
    }
  }

  double calculateSIPReturns(double monthlyInvestment, double annualReturn, int years) {
    final monthlyReturn = annualReturn / 12 / 100;
    final months = years * 12;
    
    // Future value of SIP formula
    final futureValue = monthlyInvestment * 
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

  String getInvestmentAdvice() {
    final riskProfile = getRiskProfile();
    final isDiversified = isPortfolioDiversified();
    
    if (riskProfile == 'Aggressive' && !isDiversified) {
      return 'Your portfolio is aggressive and not well diversified. Consider spreading investments across more asset classes.';
    } else if (riskProfile == 'Conservative') {
      return 'Your portfolio is conservative. You might want to consider adding some growth-oriented assets for better returns.';
    } else if (isDiversified) {
      return 'Your portfolio is well diversified. Keep monitoring and rebalancing periodically.';
    } else {
      return 'Consider diversifying your portfolio across different asset classes to manage risk better.';
    }
  }
}