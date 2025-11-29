import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final bool isFromVoice; // NEW: Track if message is from voice command

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.isFromVoice = false,
  });
}

class ChatViewModel {
  List<ChatMessage> chatMessages = [];
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  ChatViewModel() {
    _initializeTts();
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
    });
  }

  Future<void> speak(String text) async {
    if (isSpeaking) {
      await flutterTts.stop();
    }
    isSpeaking = true;
    await flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      isSpeaking = false;
    }
  }

  void addUserMessage(String message, {bool isFromVoice = false}) {
    chatMessages.add(ChatMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
      isFromVoice: isFromVoice,
    ));
  }

  Future<void> generateAIResponse(String userMessage, {bool isFromVoice = false}) async {
  try {
    print('Sending to API: $userMessage');
    
    // Call the API
    final response = await http.post(
      Uri.parse('https://ez-8f2y.onrender.com/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': userMessage}),
    );

    print('API Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Handle nested response structure
      String botMessage;
      
      if (data['response'] != null) {
        // Check if response is a Map (nested structure)
        if (data['response'] is Map) {
          botMessage = data['response']['result'] ?? 
                       data['response']['output'] ?? 
                       'Sorry, I couldn\'t get a response.';
        } else if (data['response'] is String) {
          // Direct string response
          botMessage = data['response'];
        } else {
          botMessage = 'Sorry, I couldn\'t understand the response format.';
        }
      } else {
        botMessage = 'Sorry, I couldn\'t get a response.';
      }
      
      print('Bot Message: $botMessage');
      
      chatMessages.add(ChatMessage(
        message: botMessage,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: null,
        isFromVoice: isFromVoice,
      ));

      // Auto-speak if the message was from voice command
      if (isFromVoice) {
        await speak(botMessage);
      }
    } else {
      print('API Error: Status ${response.statusCode}');
      // Show error message
      chatMessages.add(ChatMessage(
        message: 'Sorry, I couldn\'t connect to the server. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: null,
        isFromVoice: isFromVoice,
      ));
    }
  } catch (e) {
    print('Error calling API: $e');
    // Show error message
    chatMessages.add(ChatMessage(
      message: 'Sorry, something went wrong. Please check your internet connection.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: null,
      isFromVoice: isFromVoice,
    ));
  }
}

  void clearChat() {
    chatMessages.clear();
    stopSpeaking();
  }

  void dispose() {
    flutterTts.stop();
  }
}