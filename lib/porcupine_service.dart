// ignore_for_file: constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ezmoney/payments_view_model.dart';

class PorcupineService {
  PorcupineManager? _porcupineManager;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final PaymentViewModel _paymentViewModel = PaymentViewModel();
  
  bool _isListening = false;
  bool _isEnabled = false;
  bool _isProcessingCommand = false;
  String _recognizedText = '';

  // Map of contact names to their details (same as in PaymentScreen)
  final Map<String, Map<String, String>> _contactsMap = {
    '9769215236': {
      'name': 'Aryan Surve',
      'upiId': 'aryan2509surve@oksbi',
    },
    '7977296899': {
      'name': 'Shivam Musterya',
      'upiId': 'musteryasm@okhdfcbank',
    },
    '8657689680': {
      'name': 'Aryan Kyatham',
      'upiId': 'kyathamaryan-2@oksbi',
    },
    '8422900510': {
      'name': 'Aditi Gaikwad',
      'upiId': 'aditigaikwad003-2@okhdfcbank',
    },
  };

  // Global key for showing snackbars from anywhere
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Function()? onWakeWordDetected;
  Function(String)? onError;
  Function(bool)? onStatusChanged;
  Function(String)? onCommandRecognized;
  Function(String)? onNavigateToChat; // NEW: Callback to navigate to chat with command

  static const String ACCESS_KEY =
      'pfBQ2zFX1lipi+davtRVPoUcoUg67OUTp+/tfphbhY9yiZ88SEgXcQ==';
  static const String WAKE_WORD_PATH = 'assets/fin.ppn';

  // Show snackbar using global key
  void _showSnackBar(String message, Color backgroundColor, {IconData? icon}) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> initialize() async {
    try {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showSnackBar(
          'Please grant microphone permission to use voice commands',
          Colors.red,
          icon: Icons.mic_off,
        );
        onError?.call('Microphone permission denied');
        return false;
      }

      // Initialize speech recognition
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      if (!available) {
        _showSnackBar(
          'Speech recognition not available on this device',
          Colors.red,
          icon: Icons.error,
        );
        onError?.call('Speech recognition not available');
        return false;
      }

      return true;
    } catch (e) {
      _showSnackBar(
        'Initialization error: $e',
        Colors.red,
        icon: Icons.error,
      );
      onError?.call('Initialization error: $e');
      return false;
    }
  }

  Future<void> enable() async {
    _isEnabled = true;
    await startListening();
    onStatusChanged?.call(true);

    _showSnackBar(
      '✓ Voice Assistant Enabled - Say "Hey Fin" anytime',
      Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<void> disable() async {
    _isEnabled = false;
    await stopListening();
    onStatusChanged?.call(false);

    _showSnackBar(
      'Voice Assistant Disabled',
      Colors.grey,
      icon: Icons.mic_off,
    );
  }

  Future<void> startListening() async {
    if (_isListening || !_isEnabled) return;

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        ACCESS_KEY,
        [WAKE_WORD_PATH],
        (keywordIndex) async {
          debugPrint('🎤 Hey Fin detected!');

          // Show wake word detected snackbar
          _showSnackBar(
            '🎤 Hey Fin Activated! Listening for your command...',
            Colors.green,
            icon: Icons.mic,
          );

          onWakeWordDetected?.call();

          // Start listening for command after wake word
          await _listenForCommand();
        },
        errorCallback: (error) {
          debugPrint('Porcupine error: ${error.message}');
          _showSnackBar(
            'Voice Assistant Error: ${error.message}',
            Colors.red,
            icon: Icons.error,
          );
          onError?.call(error.message ?? 'Unknown error');

          // Auto-restart on error if still enabled
          if (_isEnabled && !_isProcessingCommand) {
            Future.delayed(const Duration(seconds: 2), () {
              if (_isEnabled) startListening();
            });
          }
        },
      );

      await _porcupineManager!.start();
      _isListening = true;
      debugPrint('✓ Porcupine started listening for "Hey Fin"...');
    } on PorcupineActivationException {
      _showSnackBar(
        'Invalid ACCESS_KEY',
        Colors.red,
        icon: Icons.error,
      );
      onError?.call('Invalid ACCESS_KEY');
    } on PorcupineActivationLimitException {
      _showSnackBar(
        'ACCESS_KEY reached activation limit',
        Colors.red,
        icon: Icons.error,
      );
      onError?.call('ACCESS_KEY reached activation limit');
    } on PorcupineException catch (ex) {
      _showSnackBar(
        'Porcupine error: ${ex.message}',
        Colors.red,
        icon: Icons.error,
      );
      onError?.call('Porcupine error: ${ex.message}');
    }
  }

  Future<void> _listenForCommand() async {
    if (_isProcessingCommand) return;

    _isProcessingCommand = true;
    _recognizedText = '';
    bool isDone = false;

    await _porcupineManager?.stop();

    try {
      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          debugPrint('Heard: $_recognizedText');
        },
        onSoundLevelChange: (level) {
          // Optional: provide visual feedback based on sound level
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
      );

      // Wait until speech recognition stops (either by pause or timeout)
      while (_speech.isListening && !isDone) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Ensure it's stopped
      if (_speech.isListening) {
        await _speech.stop();
      }

      // Show result immediately
      debugPrint('✓ Final recognized command: $_recognizedText');

      if (_recognizedText.isNotEmpty) {
        _showSnackBar(
          'You said: "$_recognizedText"',
          Colors.blue,
          icon: Icons.message,
        );
        onCommandRecognized?.call(_recognizedText);
        
        // Check if it's a payment command or general command
        final lowerCommand = _recognizedText.toLowerCase();
        if (lowerCommand.contains('payment') || 
            lowerCommand.contains('pay') ||
            lowerCommand.contains('send money') ||
            lowerCommand.contains('transfer')) {
          // Process payment command
          await _processPaymentCommand(_recognizedText);
        } else {
          // Navigate to chat with the command
          _showSnackBar(
            'Opening chat assistant...',
            Colors.blue,
            icon: Icons.chat,
          );
          onNavigateToChat?.call(_recognizedText);
        }
      } else {
        _showSnackBar(
          'No command detected. Please try again.',
          Colors.orange,
          icon: Icons.warning,
        );
        onCommandRecognized?.call('No command detected');
      }
    } catch (e) {
      debugPrint('Error listening for command: $e');
      _showSnackBar(
        'Error listening for command',
        Colors.red,
        icon: Icons.error,
      );
      onError?.call('Error listening for command');
    } finally {
      _isProcessingCommand = false;

      if (_isEnabled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _porcupineManager?.start();
        debugPrint('🔄 Restarted listening for "Hey Fin"...');
      }
    }
  }

  Future<void> _processPaymentCommand(String command) async {
    try {
      final lowerCommand = command.toLowerCase();
      
      debugPrint('🔍 Processing payment command: $command');

      // Extract contact name
      String? contactKey;
      String? contactName;
      String? upiId;
      
      for (var entry in _contactsMap.entries) {
        if (lowerCommand.contains(entry.key.toLowerCase()) ||
            lowerCommand.contains(entry.value['name']!.toLowerCase())) {
          contactKey = entry.key;
          contactName = entry.value['name'];
          upiId = entry.value['upiId'];
          break;
        }
      }

      if (contactKey == null || contactName == null || upiId == null) {
        _showSnackBar(
          'Contact not found. Please mention: ${_contactsMap.keys.join(", ")}',
          Colors.orange,
          icon: Icons.person_off,
        );
        return;
      }

      // Extract amount using multiple patterns
      String? amount;
      
      // Pattern 1: "rupees 100" or "rs 100" or "₹100"
      final rupeePattern = RegExp(r'(?:rupees?|rs\.?|₹)\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
      var match = rupeePattern.firstMatch(lowerCommand);
      if (match != null) {
        amount = match.group(1);
      }
      
      // Pattern 2: "100 rupees" or "100 rs"
      if (amount == null) {
        final amountFirstPattern = RegExp(r'(\d+(?:\.\d{1,2})?)\s*(?:rupees?|rs\.?)', caseSensitive: false);
        match = amountFirstPattern.firstMatch(lowerCommand);
        if (match != null) {
          amount = match.group(1);
        }
      }
      
      // Pattern 3: Just numbers with "for" before it
      if (amount == null) {
        final forPattern = RegExp(r'for\s+(\d+(?:\.\d{1,2})?)', caseSensitive: false);
        match = forPattern.firstMatch(lowerCommand);
        if (match != null) {
          amount = match.group(1);
        }
      }

      if (amount == null) {
        _showSnackBar(
          'Amount not found. Please say the amount clearly.',
          Colors.orange,
          icon: Icons.currency_rupee,
        );
        return;
      }

      // Extract description/reason
      String description = 'Voice payment';
      
      // Look for "for" keyword to extract reason
      final forPattern = RegExp(r'for\s+(.+?)(?:\s+(?:of|amount|rupees?|rs\.?|₹|\d+)|$)', caseSensitive: false);
      match = forPattern.firstMatch(lowerCommand);
      if (match != null) {
        String? reason = match.group(1)?.trim();
        // Clean up amount from reason if present
        if (reason != null) {
          reason = reason.replaceAll(RegExp(r'\d+(?:\.\d{1,2})?'), '').trim();
          if (reason.isNotEmpty && reason.length > 3) {
            description = reason;
          }
        }
      }

      // Show processing message
      _showSnackBar(
        '💳 Processing payment to $contactName for ₹$amount',
        Colors.blue,
        icon: Icons.payment,
      );

      debugPrint('📤 Initiating payment:');
      debugPrint('  Contact: $contactName');
      debugPrint('  UPI ID: $upiId');
      debugPrint('  Amount: ₹$amount');
      debugPrint('  Description: $description');

      // Get context for payment processing
      final context = scaffoldMessengerKey.currentContext;
      if (context == null) {
        _showSnackBar(
          'Cannot process payment: Context not available',
          Colors.red,
          icon: Icons.error,
        );
        return;
      }

      // Initiate UPI payment directly without dialog
      final result = await _paymentViewModel.initiateUpiPaymentDirect(
        upiId: upiId,
        recipientName: contactName,
        description: description,
        amount: amount,
      );

      if (result != null) {
        _showSnackBar(
          result,
          result.contains('initiated') ? Colors.green : Colors.orange,
          icon: result.contains('initiated') ? Icons.check_circle : Icons.warning,
        );
      }
    } catch (e) {
      debugPrint('Error processing payment command: $e');
      _showSnackBar(
        'Error processing payment: $e',
        Colors.red,
        icon: Icons.error,
      );
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speech.stop();
      await _porcupineManager?.stop();
      await _porcupineManager?.delete();
      _porcupineManager = null;
      _isListening = false;
      _isProcessingCommand = false;
      debugPrint('🛑 Porcupine stopped');
    } catch (e) {
      debugPrint('Error stopping Porcupine: $e');
    }
  }

  bool get isListening => _isListening;
  bool get isEnabled => _isEnabled;
  bool get isProcessingCommand => _isProcessingCommand;

  void dispose() {
    stopListening();
  }
}