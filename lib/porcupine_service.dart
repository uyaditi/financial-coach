// ignore_for_file: constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PorcupineService {
  PorcupineManager? _porcupineManager;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isEnabled = false;
  bool _isProcessingCommand = false;
  String _recognizedText = '';
  
  // Global key for showing snackbars from anywhere
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  Function()? onWakeWordDetected;
  Function(String)? onError;
  Function(bool)? onStatusChanged;
  Function(String)? onCommandRecognized;

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

    await _porcupineManager?.stop();

    try {
      // Listen for 10 seconds
      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          debugPrint('Heard: $_recognizedText');
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
      );

      // Wait for listening to complete
      await Future.delayed(const Duration(seconds: 10));

      // Stop speech recognition
      await _speech.stop();

      // Show the recognized command immediately
      debugPrint('✓ Final recognized command: $_recognizedText');
      
      if (_recognizedText.isNotEmpty) {
        // Show command recognized snackbar immediately
        _showSnackBar(
          'You said: "$_recognizedText"',
          Colors.blue,
          icon: Icons.message,
        );
        onCommandRecognized?.call(_recognizedText);
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

      // Restart wake word detection if still enabled
      if (_isEnabled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _porcupineManager?.start();
        debugPrint('🔄 Restarted listening for "Hey Fin"...');
      }
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