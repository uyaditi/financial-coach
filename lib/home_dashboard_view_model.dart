import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeDashboardViewModel extends GetxController {
  // Observable variables
  var healthScore = 78.0.obs;
  var healthScoreStatus = 'Good'.obs;
  
  var totalSpending = 45300.0.obs;
  var foodSpending = 8500.0.obs;
  var transportSpending = 3200.0.obs;
  var shoppingSpending = 12000.0.obs;
  var entertainmentSpending = 5600.0.obs;
  var utilitiesSpending = 7000.0.obs;
  
  var totalInvestments = 150000.0.obs;
  var investmentProfit = 18000.0.obs;
  var investmentGrowth = 12.0.obs;
  
  var aiInsights = <Map<String, dynamic>>[].obs;
  
  // Chart data
  var spendingTrendData = <double>[].obs;
  var investmentPerformanceData = <double>[].obs;
  var incomeExpenseData = <Map<String, double>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize data
    _loadDashboardData();
    _loadAIInsights();
    _loadChartData();
  }

  void _loadDashboardData() {
    // Simulate loading data from API or database
    // In real app, you would fetch from backend
    
    // Calculate health score status
    if (healthScore.value >= 80) {
      healthScoreStatus.value = 'Excellent';
    } else if (healthScore.value >= 60) {
      healthScoreStatus.value = 'Good';
    } else if (healthScore.value >= 40) {
      healthScoreStatus.value = 'Fair';
    } else {
      healthScoreStatus.value = 'Needs Improvement';
    }
  }

  void _loadAIInsights() {
    aiInsights.value = [
      {
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'message': 'You overspent by ₹2,300 this week on Food 🍔',
      },
      {
        'icon': Icons.lightbulb_outline,
        'color': Colors.blue,
        'message': 'You can save ₹500 more if you limit subscriptions',
      },
      {
        'icon': Icons.notifications_active,
        'color': Colors.green,
        'message': 'Your salary is expected tomorrow. Want me to auto-allocate?',
      },
    ];
  }

  void _loadChartData() {
    // Spending trend data for last 6 months (in rupees)
    spendingTrendData.value = [
      32000.0,  // January
      28000.0,  // February
      35000.0,  // March
      42000.0,  // April
      38000.0,  // May
      45300.0,  // June (current)
    ];

    // Investment performance data for last 4 weeks
    investmentPerformanceData.value = [
      135000.0,  // Week 1
      142000.0,  // Week 2
      138000.0,  // Week 3
      150000.0,  // Week 4 (current)
    ];

    // Income vs Expense data for last 6 months
    incomeExpenseData.value = [
      {'income': 65000.0, 'expense': 32000.0},  // January
      {'income': 65000.0, 'expense': 28000.0},  // February
      {'income': 70000.0, 'expense': 35000.0},  // March
      {'income': 70000.0, 'expense': 42000.0},  // April
      {'income': 65000.0, 'expense': 38000.0},  // May
      {'income': 75000.0, 'expense': 45300.0},  // June
    ];
  }

  // Methods to update data
  void updateHealthScore(double score) {
    healthScore.value = score;
    _loadDashboardData();
  }

  void updateSpending(double total, double food, double transport) {
    totalSpending.value = total;
    foodSpending.value = food;
    transportSpending.value = transport;
  }

  void updateCategorySpending({
    double? food,
    double? transport,
    double? shopping,
    double? entertainment,
    double? utilities,
  }) {
    if (food != null) foodSpending.value = food;
    if (transport != null) transportSpending.value = transport;
    if (shopping != null) shoppingSpending.value = shopping;
    if (entertainment != null) entertainmentSpending.value = entertainment;
    if (utilities != null) utilitiesSpending.value = utilities;
    
    // Recalculate total
    totalSpending.value = foodSpending.value + 
                          transportSpending.value + 
                          shoppingSpending.value + 
                          entertainmentSpending.value + 
                          utilitiesSpending.value;
  }

  void updateInvestments(double total, double profit) {
    totalInvestments.value = total;
    investmentProfit.value = profit;
    investmentGrowth.value = (profit / (total - profit)) * 100;
  }

  void addAIInsight(Map<String, dynamic> insight) {
    aiInsights.add(insight);
  }

  void removeAIInsight(int index) {
    aiInsights.removeAt(index);
  }

  void updateSpendingTrend(List<double> newData) {
    spendingTrendData.value = newData;
  }

  void updateInvestmentPerformance(List<double> newData) {
    investmentPerformanceData.value = newData;
  }

  void updateIncomeExpense(List<Map<String, double>> newData) {
    incomeExpenseData.value = newData;
  }

  // Simulate fetching fresh data
  Future<void> refreshData() async {
    // Show loading
    await Future.delayed(const Duration(seconds: 2));
    
    // Update with new data
    healthScore.value = 82.0;
    totalSpending.value = 47000.0;
    totalInvestments.value = 155000.0;
    
    // Update chart data
    spendingTrendData.value = [
      32000.0,
      28000.0,
      35000.0,
      42000.0,
      38000.0,
      47000.0,  // Updated current month
    ];
    
    investmentPerformanceData.value = [
      135000.0,
      142000.0,
      138000.0,
      155000.0,  // Updated current week
    ];
    
    _loadDashboardData();
    _loadAIInsights();
  }

  // Calculate savings rate
  double get savingsRate {
    if (incomeExpenseData.isEmpty) return 0.0;
    final latestData = incomeExpenseData.last;
    final income = latestData['income'] ?? 0.0;
    final expense = latestData['expense'] ?? 0.0;
    if (income == 0) return 0.0;
    return ((income - expense) / income) * 100;
  }

  // Get current month income
  double get currentMonthIncome {
    if (incomeExpenseData.isEmpty) return 0.0;
    return incomeExpenseData.last['income'] ?? 0.0;
  }

  // Get spending by category percentages
  Map<String, double> get categoryPercentages {
    final total = totalSpending.value;
    if (total == 0) return {};
    
    return {
      'Food': (foodSpending.value / total) * 100,
      'Transport': (transportSpending.value / total) * 100,
      'Shopping': (shoppingSpending.value / total) * 100,
      'Entertainment': (entertainmentSpending.value / total) * 100,
      'Utilities': (utilitiesSpending.value / total) * 100,
    };
  }
}