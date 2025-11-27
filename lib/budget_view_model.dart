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

  // Future method for POST request (commented out until API is ready)
  /*
  Future<void> addBudget({
    required String category,
    required double maxLimit,
  }) async {
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);

    try {
      final response = await http.post(
        Uri.parse('https://ez-8f2y.onrender.com/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Budget added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        await fetchBudgets();
      } else {
        Get.snackbar(
          'Error',
          'Failed to add budget: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } on SocketException catch (e) {
      debugPrint('Socket error: $e');
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      Get.snackbar(
        'Timeout',
        'Server is taking too long to respond',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error adding budget: $e');
      Get.snackbar(
        'Error',
        'Failed to add budget',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }
  */

  // Method to update an existing budget (commented out until API is ready)
  /*
  Future<void> updateBudget({
    required int id,
    required String category,
    required double maxLimit,
  }) async {
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);

    try {
      final response = await http.put(
        Uri.parse('https://ez-8f2y.onrender.com/budgets/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
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

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Budget updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        await fetchBudgets();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update budget: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } on SocketException catch (e) {
      debugPrint('Socket error: $e');
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      Get.snackbar(
        'Timeout',
        'Server is taking too long to respond',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error updating budget: $e');
      Get.snackbar(
        'Error',
        'Failed to update budget',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }
  */
}