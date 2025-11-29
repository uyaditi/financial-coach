import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

class Budget {
  final int id;
  final String category;
  final double maxLimit;
  final String timePeriod;

  Budget({
    required this.id,
    required this.category,
    required this.maxLimit,
    required this.timePeriod,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      maxLimit: (json['max_limit'] as num).toDouble(),
      timePeriod: json['time_period'],
    );
  }
}

class BudgetViewModel extends GetxController {
  final isLoading = false.obs;
  final budgets = <Budget>[].obs;
  final selectedMonth = DateTime.now().obs;
  final selectedMonthFormatted = ''.obs;
  final totalBudget = 0.0.obs;
  final errorMessage = ''.obs;

  // Mock spent data - Replace with actual API call
  final Map<String, double> spentAmounts = {
    'food': 6500.0,
    'commute': 4800.0,
    'health': 2200.0,
    'beauty': 2100.0,
    'household': 3800.0,
    'social life': 5200.0,
    'miscellaneous': 1800.0,
    'apparel': 2500.0,
  };

  @override
  void onInit() {
    super.onInit();
    updateMonthFormat();
    fetchBudgets();
  }

  void updateMonthFormat() {
    selectedMonthFormatted.value =
        DateFormat('MMMM yyyy').format(selectedMonth.value);
  }

  Future<void> fetchBudgets() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('https://ez-8f2y.onrender.com/budgets/'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        budgets.value = data.map((json) => Budget.fromJson(json)).toList();
        calculateTotalBudget();
      } else {
        errorMessage.value = 'Failed to load budgets: ${response.statusCode}';
        debugPrint('Error: ${errorMessage.value}');
      }
    } on SocketException catch (e) {
      errorMessage.value = 'No internet connection';
      debugPrint('Socket error: $e');
    } on TimeoutException catch (e) {
      errorMessage.value = 'Connection timeout';
      debugPrint('Timeout error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response format';
      debugPrint('Format error: $e');
    } catch (e) {
      errorMessage.value = 'Failed to fetch budgets: $e';
      debugPrint('Error fetching budgets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Budget> get currentMonthBudgets {
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
    return budgets.where((b) => b.timePeriod == monthStr).toList();
  }

  void calculateTotalBudget() {
    totalBudget.value = currentMonthBudgets.fold(
      0.0,
      (sum, budget) => sum + budget.maxLimit,
    );
  }

  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    updateMonthFormat();
    calculateTotalBudget();
  }

  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    updateMonthFormat();
    calculateTotalBudget();
  }

  double getSpentAmount(String category) {
    return spentAmounts[category.toLowerCase()] ?? 0.0;
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'commute':
      case 'travel':
        return Icons.directions_car;
      case 'health':
        return Icons.favorite;
      case 'beauty':
        return Icons.spa;
      case 'household':
        return Icons.home;
      case 'social life':
      case 'entertainment':
        return Icons.celebration;
      case 'miscellaneous':
      case 'other':
        return Icons.category;
      case 'apparel':
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'education':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF9800);
      case 'commute':
      case 'travel':
        return const Color(0xFFE91E63);
      case 'health':
        return const Color(0xFFF44336);
      case 'beauty':
        return const Color(0xFF9C27B0);
      case 'household':
        return const Color(0xFF3F51B5);
      case 'social life':
      case 'entertainment':
        return const Color(0xFF2196F3);
      case 'miscellaneous':
      case 'other':
        return const Color(0xFF607D8B);
      case 'apparel':
      case 'shopping':
        return const Color(0xFF00BCD4);
      case 'bills':
        return const Color(0xFFFFEB3B);
      case 'education':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Smart method: Add if category doesn't exist for the month, Update if it does
  Future<void> addOrUpdateBudget({
    required BuildContext context,
    required String category,
    required double maxLimit,
  }) async {
    // Check if budget already exists for this category in the selected month
    final existingBudget = currentMonthBudgets.firstWhereOrNull(
      (b) => b.category.toLowerCase() == category.toLowerCase(),
    );

    if (existingBudget != null) {
      // Budget exists, update it
      await updateBudget(
        context: context,
        category: category,
        maxLimit: maxLimit,
      );
    } else {
      // Budget doesn't exist, add new
      await addBudget(
        context: context,
        category: category,
        maxLimit: maxLimit,
      );
    }
  }

  Future<void> addBudget({
    required BuildContext context,
    required String category,
    required double maxLimit,
    int userId = 1, // Default user_id, make this dynamic based on your auth
  }) async {
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);

    try {
      debugPrint('Sending request with time_period: $monthStr');
      
      final response = await http.post(
        Uri.parse('https://ez-8f2y.onrender.com/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'category': category,
          'max_limit': maxLimit,
          'time_period': monthStr,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      debugPrint('Add Budget Response: ${response.statusCode}');
      debugPrint('Add Budget Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response to check what was actually saved
        final responseData = json.decode(response.body);
        final savedTimePeriod = responseData['time_period'];
        debugPrint('Saved time_period: $savedTimePeriod vs Expected: $monthStr');
        
        await fetchBudgets();
        calculateTotalBudget();
        
        if (context.mounted) {
          _showSuccessMessage(context, 'Budget added successfully');
        }
      } else {
        if (context.mounted) {
          _showErrorMessage(
            context,
            'Failed to add budget: ${response.statusCode}',
          );
        }
      }
    } on SocketException catch (e) {
      debugPrint('Socket error: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Please check your internet connection');
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Server is taking too long to respond');
      }
    } catch (e) {
      debugPrint('Error adding budget: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to add budget');
      }
    }
  }

  Future<void> updateBudget({
    required BuildContext context,
    required String category,
    required double maxLimit,
  }) async {
    try {
      // API uses category in URL path
      final response = await http.put(
        Uri.parse('https://ez-8f2y.onrender.com/budgets/$category'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category,
          'max_limit': maxLimit,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      debugPrint('Update Budget Response: ${response.statusCode}');
      debugPrint('Update Budget Body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchBudgets();
        calculateTotalBudget();
        
        if (context.mounted) {
          _showSuccessMessage(context, 'Budget updated successfully');
        }
      } else {
        if (context.mounted) {
          _showErrorMessage(
            context,
            'Failed to update budget: ${response.statusCode}',
          );
        }
      }
    } on SocketException catch (e) {
      debugPrint('Socket error: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Please check your internet connection');
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Server is taking too long to respond');
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
      if (context.mounted) {
        _showErrorMessage(context, 'Failed to update budget');
      }
    }
  }
}