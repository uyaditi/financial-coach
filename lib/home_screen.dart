import 'package:ezmoney/ai_view.dart';
import 'package:ezmoney/analytics_view.dart';
import 'package:ezmoney/investment_view.dart';
import 'package:ezmoney/notification_view.dart';
import 'package:ezmoney/transaction_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

import 'home_dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const InvestmentsView(),
    const AnalyticsView(),
    const HomeDashboardView(),
    const TransactionView(),
    const AIAssistantView(),
  ];

  final List<String> _pageTitles = [
    'Current Investments',
    'Analytics',
    'Home Dashboard',
    'Transactions',
    'Ai Assistant',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            ZoomDrawer.of(context)!.toggle();
          },
        ),
        title: Text(
          _pageTitles[_currentIndex],
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
               Get.to(() => const NotificationsScreen());
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem(Icons.savings, 0),
            _buildNavItem(Icons.analytics, 1),
            _buildNavItem(Icons.home, 2),
            _buildNavItem(Icons.swap_horiz, 3),
            _buildNavItem(Icons.smart_toy, 4),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A7FFF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF4A7FFF) : Colors.grey,
          size: 26,
        ),
      ),
    );
  }

}

// Dummy Page for Navigation
class DummyPage extends StatelessWidget {
  final String title;

  const DummyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}