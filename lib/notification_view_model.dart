// notification_view_model.dart (ViewModel)
import 'package:get/get.dart';

// Models
abstract class NotificationItem {
  final String title;
  final String icon;
  
  NotificationItem({required this.title, required this.icon});
}

class BalanceInfo {
  final double currentBalance;
  final double weeklyAverage;
  
  BalanceInfo({
    required this.currentBalance,
    required this.weeklyAverage,
  });
  
  double get aboveAverage => currentBalance - weeklyAverage;
}

class PaymentReminder extends NotificationItem {
  final String subtitle;
  
  PaymentReminder({
    required super.title,
    required this.subtitle,
    required super.icon,
  });
}

class FinancialInsight extends NotificationItem {
  final String message;
  final bool isLightBackground;
  
  FinancialInsight({
    required this.message,
    required super.icon,
    this.isLightBackground = false,
  }) : super(title: message);
}

class MarketNews extends NotificationItem {
  final String source;
  final String timeAgo;
  
  MarketNews({
    required super.title,
    required this.source,
    required this.timeAgo,
    required super.icon,
  });
}

// ViewModel/Controller
class NotificationsController extends GetxController {
  // Observable data
  final Rx<BalanceInfo> balanceInfo = BalanceInfo(
    currentBalance: 28900,
    weeklyAverage: 24700,
  ).obs;
  
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxList<MarketNews> marketNewsList = <MarketNews>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadMarketNews();
  }
  
  // Load notifications data
  void loadNotifications() {
    notifications.value = [
      PaymentReminder(
        title: 'Electricity bill of ₹1,850 due tomorrow',
        subtitle: 'Will be Saved deducted on 8/10/2025.',
        icon: 'lock',
      ),
      FinancialInsight(
        message: 'Sensex up 0.5% today. Tech stocks performing well',
        icon: 'trending',
        isLightBackground: false,
      ),
    ];
  }
  
  // Load market news
  void loadMarketNews() {
    marketNewsList.value = [
      MarketNews(
        title: 'Tech Giants Report Strong Q4 Earnings',
        source: 'Economic Times',
        timeAgo: '2 hours ago',
        icon: 'news',
      ),
      MarketNews(
        title: 'RBI Keeps Repo Rate Unchanged at 6.5%',
        source: 'Business Standard',
        timeAgo: '5 hours ago',
        icon: 'news',
      ),
      MarketNews(
        title: 'Gold Prices Surge to New Record High',
        source: 'Moneycontrol',
        timeAgo: '1 day ago',
        icon: 'news',
      ),
    ];
  }
  
  // Update balance
  void updateBalance(double newBalance) {
    balanceInfo.value = BalanceInfo(
      currentBalance: newBalance,
      weeklyAverage: balanceInfo.value.weeklyAverage,
    );
  }
  
  // Add new notification
  void addNotification(NotificationItem item) {
    notifications.add(item);
  }
  
  // Remove notification
  void removeNotification(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
    }
  }
  
  // Refresh data
  Future<void> refreshData() async {
    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    loadNotifications();
    loadMarketNews();
    isLoading.value = false;
  }
  
  // Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  
  // Get balance text
  String get balanceText => formatCurrency(balanceInfo.value.currentBalance);
  
  // Get above average text
  String get aboveAverageText {
    final amount = balanceInfo.value.aboveAverage;
    return 'You\'re ${formatCurrency(amount)} above your weekly average.';
  }
}