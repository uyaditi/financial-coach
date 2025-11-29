import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentViewModel {
  /// Initiates UPI payment using UPI ID (with dialog for manual selection)
  Future<String?> initiateUpiPayment({
    required BuildContext context,
    required String upiId,
    required String recipientName,
    required String description,
    required String amount,
  }) async {
    try {
      // Validate amount
      final double? parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        return 'Please enter a valid amount';
      }

      // Get available UPI apps
      final availableApps = await _getAvailableUpiApps();
      
      if (availableApps.isEmpty) {
        return 'No UPI apps found. Please install Google Pay, PhonePe, or any UPI app.';
      }

      // Show only available apps
      final selectedApp = await _showUpiAppDialog(context, availableApps);
      
      if (selectedApp == null) {
        return 'Payment cancelled';
      }

      final upiUrl = _buildUpiUrl(
        app: selectedApp,
        upiId: upiId,
        recipientName: recipientName,
        amount: parsedAmount.toStringAsFixed(2),
        description: description,
      );

      final uri = Uri.parse(upiUrl);
      
      // Try to launch with better error handling
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          return 'Payment initiated. Complete payment in the UPI app.';
        } else {
          // Fallback to generic UPI
          return await _tryGenericUpi(
            upiId,
            recipientName,
            parsedAmount.toStringAsFixed(2),
            description,
          );
        }
      } catch (e) {
        debugPrint('Launch error: $e');
        // Fallback to generic UPI
        return await _tryGenericUpi(
          upiId,
          recipientName,
          parsedAmount.toStringAsFixed(2),
          description,
        );
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  /// Initiates UPI payment directly without dialog (for voice commands)
  Future<String?> initiateUpiPaymentDirect({
    required String upiId,
    required String recipientName,
    required String description,
    required String amount,
  }) async {
    try {
      // Validate amount
      final double? parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        return 'Please enter a valid amount';
      }

      // Get available UPI apps
      final availableApps = await _getAvailableUpiApps();
      
      if (availableApps.isEmpty) {
        return 'No UPI apps found. Please install Google Pay, PhonePe, or any UPI app.';
      }

      // Use the first available app automatically
      final selectedApp = availableApps.first['id'] as String;
      
      debugPrint('Auto-selecting UPI app: ${availableApps.first['name']}');

      final upiUrl = _buildUpiUrl(
        app: selectedApp,
        upiId: upiId,
        recipientName: recipientName,
        amount: parsedAmount.toStringAsFixed(2),
        description: description,
      );

      final uri = Uri.parse(upiUrl);
      
      // Try to launch with better error handling
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          return 'Payment initiated in ${availableApps.first['name']}. Complete payment in the UPI app.';
        } else {
          // Fallback to generic UPI
          return await _tryGenericUpi(
            upiId,
            recipientName,
            parsedAmount.toStringAsFixed(2),
            description,
          );
        }
      } catch (e) {
        debugPrint('Launch error: $e');
        // Fallback to generic UPI
        return await _tryGenericUpi(
          upiId,
          recipientName,
          parsedAmount.toStringAsFixed(2),
          description,
        );
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  /// Check which UPI apps are available
  Future<List<Map<String, dynamic>>> _getAvailableUpiApps() async {
    final allApps = [
      {
        'name': 'Google Pay',
        'id': 'gpay',
        'scheme': 'tez://upi/pay',
        'icon': Icons.g_mobiledata,
        'color': Colors.blue,
      },
      {
        'name': 'PhonePe',
        'id': 'phonepe',
        'scheme': 'phonepe://pay',
        'icon': Icons.phone_android,
        'color': Colors.purple,
      },
      {
        'name': 'Paytm',
        'id': 'paytm',
        'scheme': 'paytmmp://pay',
        'icon': Icons.payment,
        'color': Colors.lightBlue,
      },
      {
        'name': 'BHIM UPI',
        'id': 'upi',
        'scheme': 'upi://pay',
        'icon': Icons.account_balance,
        'color': Colors.orange,
      },
    ];

    final availableApps = <Map<String, dynamic>>[];

    for (final app in allApps) {
      try {
        final uri = Uri.parse(app['scheme'] as String);
        if (await canLaunchUrl(uri)) {
          availableApps.add(app);
        }
      } catch (e) {
        debugPrint('Cannot check ${app['name']}: $e');
      }
    }

    // Always add generic option
    availableApps.add({
      'name': 'Other UPI Apps',
      'id': 'generic',
      'scheme': 'upi://pay',
      'icon': Icons.apps,
      'color': Colors.grey,
    });

    return availableApps;
  }

  /// Try generic UPI as fallback
  Future<String?> _tryGenericUpi(
    String upiId,
    String recipientName,
    String amount,
    String description,
  ) async {
    final encodedDescription = Uri.encodeComponent(description);
    final encodedName = Uri.encodeComponent(recipientName);
    
    final genericUrl = 'upi://pay?'
        'pa=$upiId&'
        'pn=$encodedName&'
        'am=$amount&'
        'tn=$encodedDescription&'
        'cu=INR';
    
    final uri = Uri.parse(genericUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return 'Payment initiated. Complete payment in the UPI app.';
      } else {
        return 'UPI app not found. Please install a UPI app.';
      }
    } catch (e) {
      return 'Failed to open UPI app. Please try again.';
    }
  }

  /// Shows dialog with only available apps
  Future<String?> _showUpiAppDialog(
    BuildContext context,
    List<Map<String, dynamic>> availableApps,
  ) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Choose Payment App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableApps.map((app) {
              return _buildUpiAppTile(
                context: context,
                appName: app['name'] as String,
                appId: app['id'] as String,
                icon: app['icon'] as IconData,
                color: app['color'] as Color,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildUpiAppTile({
    required BuildContext context,
    required String appName,
    required String appId,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        appName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => Navigator.pop(context, appId),
    );
  }

  /// Builds UPI deep link URL
  String _buildUpiUrl({
    required String app,
    required String upiId,
    required String recipientName,
    required String amount,
    required String description,
  }) {
    final encodedDescription = Uri.encodeComponent(description);
    final encodedName = Uri.encodeComponent(recipientName);

    final baseParams = 'pa=$upiId&'
        'pn=$encodedName&'
        'am=$amount&'
        'tn=$encodedDescription&'
        'cu=INR';

    // App-specific deep links
    switch (app) {
      case 'gpay':
        return 'tez://upi/pay?$baseParams';
      case 'phonepe':
        return 'phonepe://pay?$baseParams';
      case 'paytm':
        return 'paytmmp://pay?$baseParams';
      default:
        return 'upi://pay?$baseParams';
    }
  }
}