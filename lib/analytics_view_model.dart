import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryData {
  final String name;
  final double amount;
  final double percentage;
  final IconData icon;
  final List<Color> colors;

  CategoryData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.colors,
  });
}

class SmartNudge {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;

  SmartNudge({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
  });
}

class AnalyticsViewModel {
  // Total spending data
  double totalSpending = 28450.75;
  double monthlyBudget = 35000.0;
  double get spendingProgress => totalSpending / monthlyBudget;

  // Week comparison
  double thisWeekSpending = 8750.25;
  double lastWeekSpending = 7420.50;
  double get spendingDifference => 
      ((thisWeekSpending - lastWeekSpending) / lastWeekSpending) * 100;

  // Categories
  List<CategoryData> categories = [];

  // Weekly spending chart data
  List<FlSpot> weeklySpendingData = [];

  // Smart nudges
  List<SmartNudge> smartNudges = [];

  void loadAnalytics() {
    _loadCategories();
    _loadWeeklyData();
    _loadSmartNudges();
  }

  void _loadCategories() {
    categories = [
      CategoryData(
        name: 'Food',
        amount: 7210.50,
        percentage: 25.3,
        icon: Icons.restaurant,
        colors: [
          const Color(0xFF8B5CF6),
          const Color(0xFF7C3AED),
        ],
      ),
      CategoryData(
        name: 'Transport',
        amount: 8240.50,
        percentage: 29.0,
        icon: Icons.directions_car,
        colors: [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
        ],
      ),
      CategoryData(
        name: 'Bills',
        amount: 3800.00,
        percentage: 13.4,
        icon: Icons.receipt_long,
        colors: [
          const Color(0xFF93C5FD),
          const Color(0xFF60A5FA),
        ],
      ),
      CategoryData(
        name: 'Shopping',
        amount: 4850.25,
        percentage: 17.0,
        icon: Icons.shopping_bag,
        colors: [
          const Color(0xFFFBBF24),
          const Color(0xFFF59E0B),
        ],
      ),
      CategoryData(
        name: 'EMI',
        amount: 3500.00,
        percentage: 12.3,
        icon: Icons.account_balance,
        colors: [
          const Color(0xFF34D399),
          const Color(0xFF10B981),
        ],
      ),
      CategoryData(
        name: 'Entertainment',
        amount: 849.50,
        percentage: 3.0,
        icon: Icons.movie,
        colors: [
          const Color(0xFFF472B6),
          const Color(0xFFEC4899),
        ],
      ),
    ];
  }

  void _loadWeeklyData() {
    weeklySpendingData = [
      const FlSpot(0, 3200),  // Monday
      const FlSpot(1, 2800),  // Tuesday
      const FlSpot(2, 4500),  // Wednesday
      const FlSpot(3, 3900),  // Thursday
      const FlSpot(4, 5200),  // Friday
      const FlSpot(5, 6100),  // Saturday
      const FlSpot(6, 3750),  // Sunday
    ];
  }

  void _loadSmartNudges() {
    smartNudges = [
      SmartNudge(
        message: 'You spent 18% more on Dining this month',
        icon: Icons.trending_up,
        backgroundColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
        iconColor: const Color(0xFFEF4444),
        iconBackgroundColor: const Color(0xFFFEE2E2),
        textColor: const Color(0xFFDC2626),
      ),
      SmartNudge(
        message: 'Your electricity bill is due in 2 days',
        icon: Icons.notifications_active,
        backgroundColor: const Color(0xFFFEF3C7),
        borderColor: const Color(0xFFFDE68A),
        iconColor: const Color(0xFFF59E0B),
        iconBackgroundColor: const Color(0xFFFEF3C7),
        textColor: const Color(0xFFD97706),
      ),
      SmartNudge(
        message: 'Great! You saved ₹2,500 compared to last month',
        icon: Icons.check_circle,
        backgroundColor: const Color(0xFFDCFCE7),
        borderColor: const Color(0xFFBBF7D0),
        iconColor: const Color(0xFF22C55E),
        iconBackgroundColor: const Color(0xFFDCFCE7),
        textColor: const Color(0xFF16A34A),
      ),
    ];
  }

  // Methods to update data (for future use)
  void updateTotalSpending(double amount) {
    totalSpending = amount;
  }

  void updateWeeklyComparison(double thisWeek, double lastWeek) {
    thisWeekSpending = thisWeek;
    lastWeekSpending = lastWeek;
  }

  void addCategory(CategoryData category) {
    categories.add(category);
  }

  void updateCategoryAmount(String categoryName, double newAmount) {
    final index = categories.indexWhere((cat) => cat.name == categoryName);
    if (index != -1) {
      final category = categories[index];
      categories[index] = CategoryData(
        name: category.name,
        amount: newAmount,
        percentage: (newAmount / totalSpending) * 100,
        icon: category.icon,
        colors: category.colors,
      );
    }
  }

  void addSmartNudge(SmartNudge nudge) {
    smartNudges.insert(0, nudge);
  }

  void removeSmartNudge(int index) {
    if (index >= 0 && index < smartNudges.length) {
      smartNudges.removeAt(index);
    }
  }

  // Calculate total for a specific category over a time period
  double getCategoryTotal(String categoryName) {
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryData(
        name: '',
        amount: 0,
        percentage: 0,
        icon: Icons.error,
        colors: [],
      ),
    );
    return category.amount;
  }

  // Get spending trend (increasing/decreasing)
  String getSpendingTrend() {
    if (spendingDifference > 10) {
      return 'High Increase';
    } else if (spendingDifference > 0) {
      return 'Slight Increase';
    } else if (spendingDifference > -10) {
      return 'Slight Decrease';
    } else {
      return 'Significant Decrease';
    }
  }

  // Calculate average daily spending
  double getAverageDailySpending() {
    return totalSpending / 30; // Assuming 30 days in a month
  }

  // Get highest spending category
  CategoryData getHighestSpendingCategory() {
    if (categories.isEmpty) {
      return CategoryData(
        name: 'None',
        amount: 0,
        percentage: 0,
        icon: Icons.error,
        colors: [],
      );
    }
    return categories.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  // Check if over budget
  bool isOverBudget() {
    return totalSpending > monthlyBudget;
  }

  // Get remaining budget
  double getRemainingBudget() {
    return monthlyBudget - totalSpending;
  }

  // Predict end of month spending based on current trend
  double predictMonthEndSpending() {
    const daysInMonth = 30;
    const currentDay = 23; // You can make this dynamic
    final dailyAverage = totalSpending / currentDay;
    return dailyAverage * daysInMonth;
  }
}