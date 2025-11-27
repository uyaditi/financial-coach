import 'package:ezmoney/budget_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A7FFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'User Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              // Menu Items
              _buildMenuItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  // Navigate to Dashboard
                  Get.snackbar('Info', 'Dashboard screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildMenuItem(
                icon: Icons.account_balance_wallet,
                title: 'Wallet',
                onTap: () {
                  // Navigate to Wallet
                  Get.snackbar('Info', 'Wallet screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildMenuItem(
                icon: Icons.trending_up,
                title: 'Budget',
                onTap: () {
                  // Navigate to Budget Screen
                  Get.to(() => const BudgetScreen(),
                      transition: Transition.rightToLeft);
                },
              ),
              _buildMenuItem(
                icon: Icons.receipt_long,
                title: 'Transactions',
                onTap: () {
                  // Navigate to Transactions
                  Get.snackbar('Info', 'Transactions screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildMenuItem(
                icon: Icons.flag,
                title: 'Goals',
                onTap: () {
                  // Navigate to Goals
                  Get.snackbar('Info', 'Goals screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildMenuItem(
                icon: Icons.credit_card,
                title: 'Loans',
                onTap: () {
                  // Navigate to Loans
                  Get.snackbar('Info', 'Loans screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  // Navigate to Settings
                  Get.snackbar('Info', 'Settings screen coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              const Spacer(),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  // Show logout confirmation
                  Get.defaultDialog(
                    title: 'Logout',
                    middleText: 'Are you sure you want to logout?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back();
                      Get.snackbar(
                        'Logged Out',
                        'You have been logged out successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}