import 'package:get/get.dart';

// Export Transaction class so other files can use it
class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String? icon;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.icon,
  });
}

class TransactionViewModel extends GetxController {
  // Observable list of transactions
  final RxList<Transaction> transactions = <Transaction>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Filter for today's transactions
  RxList<Transaction> get todayTransactions {
    final now = DateTime.now();
    return transactions.where((txn) {
      return txn.date.year == now.year &&
             txn.date.month == now.month &&
             txn.date.day == now.day;
    }).toList().obs;
  }
  
  // Total spending today
  RxDouble get todaySpending {
    return todayTransactions
        .where((txn) => txn.isExpense)
        .fold(0.0, (sum, txn) => sum + txn.amount)
        .obs;
  }
  
  // Total income today
  RxDouble get todayIncome {
    return todayTransactions
        .where((txn) => !txn.isExpense)
        .fold(0.0, (sum, txn) => sum + txn.amount)
        .obs;
  }

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // Load transactions (simulate API call)
  Future<void> loadTransactions() async {
    isLoading.value = true;
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Sample data for today
    final now = DateTime.now();
    transactions.value = [
      Transaction(
        id: '1',
        title: 'Coffee at Starbucks',
        category: 'Food',
        amount: 250.0,
        date: now,
        isExpense: true,
        icon: '☕',
      ),
      Transaction(
        id: '2',
        title: 'Uber Ride',
        category: 'Travel',
        amount: 180.0,
        date: now,
        isExpense: true,
        icon: '🚗',
      ),
      Transaction(
        id: '3',
        title: 'Freelance Payment',
        category: 'Income',
        amount: 5000.0,
        date: now,
        isExpense: false,
        icon: '💰',
      ),
      Transaction(
        id: '4',
        title: 'Grocery Shopping',
        category: 'Shopping',
        amount: 1500.0,
        date: now.subtract(const Duration(hours: 2)),
        isExpense: true,
        icon: '🛒',
      ),
    ];
    
    isLoading.value = false;
  }

  // Add new transaction
  void addTransaction(Transaction transaction) {
    transactions.insert(0, transaction);
    Get.back(); // Navigate back to transaction page
    Get.snackbar(
      'Success',
      'Transaction added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Delete transaction
  void deleteTransaction(String id) {
    transactions.removeWhere((txn) => txn.id == id);
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }
}