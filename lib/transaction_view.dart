import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'add_transaction_view.dart';
import 'transaction_view_model.dart';

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionViewModel controller = Get.put(TransactionViewModel());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4D7FFF)),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshTransactions,
          color: const Color(0xFF4D7FFF),
          child: CustomScrollView(
            slivers: [
              // Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4D7FFF), Color(0xFF6B9FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D7FFF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem(
                              'Income',
                              '₹${controller.todayIncome.value.toStringAsFixed(0)}',
                              Icons.arrow_downward,
                              Colors.white.withValues(alpha: 0.9),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            _buildSummaryItem(
                              'Expense',
                              '₹${controller.todaySpending.value.toStringAsFixed(0)}',
                              Icons.arrow_upward,
                              Colors.white.withValues(alpha: 0.9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Today's Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Transaction List
              controller.todayTransactions.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a transaction',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final txn = controller.todayTransactions[index];
                            return _buildTransactionCard(txn, controller);
                          },
                          childCount: controller.todayTransactions.length,
                        ),
                      ),
                    ),
            ],
          ),
        );
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Add padding to lift above bottom nav
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const AddTransactionView());
          },
          backgroundColor: const Color(0xFF4D7FFF),
          elevation: 8,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction txn, TransactionViewModel controller) {
    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        controller.deleteTransaction(txn.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: txn.isExpense 
                    ? const Color(0xFFFFE5E5) 
                    : const Color(0xFFE5F5E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  txn.icon ?? '💰',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        txn.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(txn.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${txn.isExpense ? '-' : '+'}₹${txn.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: txn.isExpense ? Colors.red[600] : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}