// ignore_for_file: constant_identifier_names, deprecated_member_use

import 'package:flutter/widgets.dart';
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

  Function()? onWakeWordDetected;
  Function(String)? onError;
  Function(bool)? onStatusChanged;
  Function(String)? onCommandRecognized;

  static const String ACCESS_KEY =
      'pfBQ2zFX1lipi+davtRVPoUcoUg67OUTp+/tfphbhY9yiZ88SEgXcQ==';
  static const String WAKE_WORD_PATH = 'assets/fin.ppn';

  Future<bool> initialize() async {
    try {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        onError?.call('Microphone permission denied');
        return false;
      }

      // Initialize speech recognition
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      if (!available) {
        onError?.call('Speech recognition not available');
        return false;
      }

      return true;
    } catch (e) {
      onError?.call('Initialization error: $e');
      return false;
    }
  }

  Future<void> enable() async {
    _isEnabled = true;
    await startListening();
    onStatusChanged?.call(true);
  }

  Future<void> disable() async {
    _isEnabled = false;
    await stopListening();
    onStatusChanged?.call(false);
  }

  Future<void> startListening() async {
    if (_isListening || !_isEnabled) return;

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        ACCESS_KEY,
        [WAKE_WORD_PATH],
        (keywordIndex) async {
          debugPrint('Hey Fin detected!');
          onWakeWordDetected?.call();

          // Start listening for command after wake word
          await _listenForCommand();
        },
        errorCallback: (error) {
          debugPrint('Porcupine error: ${error.message}');
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
      debugPrint('Porcupine started listening for "Hey Fin"...');
    } on PorcupineActivationException {
      onError?.call('Invalid ACCESS_KEY');
    } on PorcupineActivationLimitException {
      onError?.call('ACCESS_KEY reached activation limit');
    } on PorcupineException catch (ex) {
      onError?.call('Porcupine error: ${ex.message}');
    }
  }

  Future<void> _listenForCommand() async {
    if (_isProcessingCommand) return;

    _isProcessingCommand = true;
    _recognizedText = '';

    // Temporarily stop wake word detection
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

      // debugPrint and callback with the final recognized text
      debugPrint('Final recognized command: $_recognizedText');
      if (_recognizedText.isNotEmpty) {
        onCommandRecognized?.call(_recognizedText);
      } else {
        onCommandRecognized?.call('No command detected');
      }
    } catch (e) {
      debugPrint('Error listening for command: $e');
      onError?.call('Error listening for command');
    } finally {
      _isProcessingCommand = false;

      // Restart wake word detection if still enabled
      if (_isEnabled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _porcupineManager?.start();
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
      debugPrint('Porcupine stopped');
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
