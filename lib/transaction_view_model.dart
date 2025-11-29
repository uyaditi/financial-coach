import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Export Transaction class so other files can use it
class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String? icon;
  final bool isRecurring;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.icon,
    this.isRecurring = false,
  });

  // Factory method to create Transaction from API JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      title: json['raw_description']?.isNotEmpty == true 
          ? json['raw_description'] 
          : json['category'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['timestamp']),
      isExpense: json['type'] == 'expense',
      icon: _getCategoryIcon(json['category'], json['type']),
      isRecurring: json['is_recurring'] ?? false,
    );
  }

  // Helper method to get icon based on category
  static String _getCategoryIcon(String category, String type) {
    if (type == 'income') {
      if (category.toLowerCase().contains('salary')) return '💵';
      if (category.toLowerCase().contains('bonus')) return '🎁';
      if (category.toLowerCase().contains('investment')) return '📈';
      return '💰';
    }
    
    // Expense icons
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('restaurant')) return '🍽️';
    if (cat.contains('commute') || cat.contains('transport') || cat.contains('travel')) return '🚗';
    if (cat.contains('grocery') || cat.contains('household')) return '🛒';
    if (cat.contains('health') || cat.contains('medical')) return '⚕️';
    if (cat.contains('beauty') || cat.contains('salon')) return '💅';
    if (cat.contains('social')) return '🎉';
    if (cat.contains('entertainment') || cat.contains('movie')) return '🎬';
    if (cat.contains('subscription')) return '📺';
    if (cat.contains('shopping')) return '🛍️';
    
    return '💳';
  }
}

class TransactionViewModel extends GetxController {
  // Observable list of transactions
  final RxList<Transaction> transactions = <Transaction>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // API URL
  static const String apiUrl = 'https://ez-8f2y.onrender.com/transactions';
  static const String incomeUrl = 'https://ez-8f2y.onrender.com/transactions/income';
  static const String expenseUrl = 'https://ez-8f2y.onrender.com/transactions/expense';
  
  // Selected date for filtering
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Filter transactions by selected date
  RxList<Transaction> get todayTransactions {
    return transactions.where((txn) {
      return txn.date.year == selectedDate.value.year &&
             txn.date.month == selectedDate.value.month &&
             txn.date.day == selectedDate.value.day;
    }).toList().obs;
  }
  
  // Total spending for selected date
  RxDouble get todaySpending {
    return todayTransactions
        .where((txn) => txn.isExpense)
        .fold(0.0, (sum, txn) => sum + txn.amount)
        .obs;
  }
  
  // Total income for selected date
  RxDouble get todayIncome {
    return todayTransactions
        .where((txn) => !txn.isExpense)
        .fold(0.0, (sum, txn) => sum + txn.amount)
        .obs;
  }

  // Change selected date
  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
  }

  // Navigate to previous day
  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  // Navigate to next day
  void nextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
  }

  // Check if selected date is today
  bool get isToday {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
           selectedDate.value.month == now.month &&
           selectedDate.value.day == now.day;
  }

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // Load transactions from API
  Future<void> loadTransactions() async {
    isLoading.value = true;
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> transactionList = data['transaction'];
        
        // Convert JSON to Transaction objects and sort by date (newest first)
        transactions.value = transactionList
            .map((json) => Transaction.fromJson(json))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        Get.snackbar(
          'Error',
          'Failed to load transactions: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new transaction to API
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      // Prepare request body
      final requestBody = {
        'amount': transaction.amount,
        'category': transaction.category.toLowerCase(),
        'payee': '',
        'raw_description': transaction.title,
        'is_recurring': transaction.isRecurring,
      };

      // Choose endpoint based on transaction type
      final endpoint = transaction.isExpense ? expenseUrl : incomeUrl;

      // Send POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reload transactions to get the latest data
        await loadTransactions();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  // Delete transaction
  void deleteTransaction(String id) {
    transactions.removeWhere((txn) => txn.id == id);
    // TODO: Add API call to delete transaction from server
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }
}