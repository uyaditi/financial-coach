// notifications_screen.dart (View)
import 'package:ezmoney/notification_view_model.dart' show NotificationsController, PaymentReminder, FinancialInsight, MarketNews;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import your controller file
// import 'notification_view_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final NotificationsController controller = Get.put(NotificationsController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(controller),
              const SizedBox(height: 24),

              // Payment Reminder Section
              _buildPaymentReminderSection(controller),
              const SizedBox(height: 24),

              // Financial Insights
              _buildFinancialInsights(controller),
              const SizedBox(height: 24),

              // Market News Section
              _buildMarketNewsSection(controller),
              const SizedBox(height: 84),
            ],
          ),
        ),
      )),
    );
  }

  // Balance Card Widget
  Widget _buildBalanceCard(NotificationsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50C9E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your current balance is',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.balanceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.aboveAverageText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Payment Reminder Section Widget
  Widget _buildPaymentReminderSection(NotificationsController controller) {
    final paymentReminders = controller.notifications
        .whereType<PaymentReminder>()
        .toList();
    
    if (paymentReminders.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title inside card
              const Text(
                'Payment Reminder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Payment reminder content
              ...paymentReminders.map((reminder) => _buildPaymentReminderItem(reminder)),
            ],
          ),
        ),
      ],
    );
  }

  // Payment Reminder Item Widget
  Widget _buildPaymentReminderItem(PaymentReminder reminder) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.lock,
            color: Color(0xFF4A90E2),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reminder.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Financial Insights Widgets
  Widget _buildFinancialInsights(NotificationsController controller) {
    final insights = controller.notifications
        .whereType<FinancialInsight>()
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: insights.asMap().entries.map((entry) {
        final insight = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightCard(insight),
            if (entry.key < insights.length - 1) const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  // Individual Insight Card
  Widget _buildInsightCard(FinancialInsight insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.isLightBackground ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside card
          const Text(
            'Key Financial Insight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Insight content
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: insight.isLightBackground 
                      ? Colors.white 
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  insight.icon == 'money' ? Icons.attach_money : Icons.trending_up,
                  color: const Color(0xFF4A90E2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  insight.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Market News Section Widget
  Widget _buildMarketNewsSection(NotificationsController controller) {
    if (controller.marketNewsList.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title inside card
              const Text(
                'Market News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Market news items
              ...controller.marketNewsList.asMap().entries.map((entry) {
                final news = entry.value;
                final isLast = entry.key == controller.marketNewsList.length - 1;
                
                return Column(
                  children: [
                    _buildMarketNewsItem(news),
                    if (!isLast) ...[
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[200], height: 1),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Market News Item Widget
  Widget _buildMarketNewsItem(MarketNews news) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.article_outlined,
            color: Color(0xFF4A90E2),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    news.source,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    news.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}