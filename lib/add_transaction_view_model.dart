import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'transaction_view_model.dart';

class AddTransactionViewModel extends GetxController {
  // Text controllers
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // Observable variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessingImage = false.obs;
  final RxBool isManualEntry = false.obs;
  final RxBool isImageProcessed = false.obs; // NEW: Track if image was processed
  final RxBool isSubmitting = false.obs; // NEW: Track submission state
  final RxString selectedCategory = 'Food'.obs;
  final RxBool isExpense = true.obs;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // API Configuration
  static const String apiBaseUrl = 'https://ez-8f2y.onrender.com';
  static const String billDetailsEndpoint = '/investments/get-bill-details';

  // Categories
  final List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  // Category icons
  final Map<String, String> categoryIcons = {
    'Food': '🍔',
    'Travel': '🚗',
    'Shopping': '🛒',
    'Bills': '💡',
    'Entertainment': '🎬',
    'Health': '⚕️',
    'Education': '📚',
    'Other': '📌',
  };

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        isManualEntry.value = false;
        isImageProcessed.value = false;
        isProcessingImage.value = true;

        // Clear manual entry fields
        descriptionController.clear();
        amountController.clear();

        // Process image with API immediately
        await processImage();
      }
    } catch (e) {
      isProcessingImage.value = false;
      isImageProcessed.value = false;
      selectedImage.value = null;

      _showSnackbar('Error', 'Failed to capture image', isError: true);
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        isManualEntry.value = false;
        isImageProcessed.value = false;
        isProcessingImage.value = true;

        // Clear manual entry fields
        descriptionController.clear();
        amountController.clear();

        // Process image with API immediately
        await processImage();
      }
    } catch (e) {
      isProcessingImage.value = false;
      isImageProcessed.value = false;
      selectedImage.value = null;

      _showSnackbar('Error', 'Failed to pick image', isError: true);
    }
  }

  // Process image with OCR API
  Future<void> processImage() async {
    if (selectedImage.value == null) return;

    isProcessingImage.value = true;

    try {
      // Create multipart request
      final uri = Uri.parse('$apiBaseUrl$billDetailsEndpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['accept'] = 'application/json';

      // Get the file path and determine MIME type
      final filePath = selectedImage.value!.path;
      final fileExtension = filePath.toLowerCase().split('.').last;

      // Map file extension to correct MIME type
      String mimeType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'heic':
          mimeType = 'image/heic';
          break;
        default:
          mimeType = 'image/jpeg'; // Default fallback
      }

      // Add file with explicit MIME type
      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: http.MediaType.parse(mimeType),
      );
      request.files.add(file);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse response
        final responseData = json.decode(response.body);

        // Extract bill details from response
        await parseBillDetails(responseData);

        // Mark image as processed and stop processing
        isProcessingImage.value = false;
        isImageProcessed.value = true; // Set this to true
        selectedImage.value = null;

        // Show success snackbar
        _showSnackbar('Success', 'Bill details extracted successfully',
            isError: false);
      } else {
        // Handle non-200 status codes
        isProcessingImage.value = false;
        isImageProcessed.value = false;
        selectedImage.value = null;

        String errorMessage = 'Failed to process bill';

        // Try to get more specific error message
        try {
          final errorData = json.decode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (e) {
          errorMessage = 'Server error occurred';
        }

        _showSnackbar('Error', errorMessage, isError: true);
        return;
      }
    } catch (e) {
      isProcessingImage.value = false;
      isImageProcessed.value = false;
      selectedImage.value = null;

      _showSnackbar('Error', 'Failed to connect to server', isError: true);
    }
  }

  // Helper method to show snackbar safely
  void _showSnackbar(String title, String message, {required bool isError}) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = Get.key.currentContext;
      if (context != null && context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          message,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: isError
                  ? Colors.red.withOpacity(0.9)
                  : Colors.green.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } catch (e) {
          print('Snackbar error: $e - Message: $message');
        }
      } else {
        print('No context available - $title: $message');
      }
    });
  }

  // Parse bill details from API response
  Future<void> parseBillDetails(Map<String, dynamic> responseData) async {
    try {
      String description = '';
      String amount = '';
      String category = 'Other';

      // Check different possible response structures
      if (responseData.containsKey('text')) {
        final extractedText = responseData['text'] as String;

        // Parse amount from text
        final amountRegex = RegExp(r'(?:Rs\.?|₹|INR)?\s*(\d+(?:\.\d{2})?)',
            caseSensitive: false);
        final amountMatch = amountRegex.firstMatch(extractedText);
        if (amountMatch != null) {
          amount = amountMatch.group(1) ?? '';
        }

        // Extract merchant/description
        final lines = extractedText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();
        if (lines.isNotEmpty) {
          description = lines.first.trim();
        }
      } else if (responseData.containsKey('description')) {
        description = responseData['description'].toString();
      } else if (responseData.containsKey('merchant')) {
        description = responseData['merchant'].toString();
      }

      if (responseData.containsKey('amount')) {
        amount =
            responseData['amount'].toString().replaceAll(RegExp(r'[^\d.]'), '');
      } else if (responseData.containsKey('total')) {
        amount =
            responseData['total'].toString().replaceAll(RegExp(r'[^\d.]'), '');
      }

      if (responseData.containsKey('category')) {
        final apiCategory = responseData['category'].toString();
        if (categories.contains(apiCategory)) {
          category = apiCategory;
        }
      }

      // Intelligent category detection based on description
      if (category == 'Other' && description.isNotEmpty) {
        category = detectCategory(description);
      }

      // Set the values
      descriptionController.text = description.isEmpty ? 'Bill' : description;
      amountController.text = amount;
      selectedCategory.value = category;
    } catch (e) {
      print('Error parsing bill details: $e');
      descriptionController.text = 'Bill';
      amountController.text = '';
      selectedCategory.value = 'Other';
    }
  }

  // Detect category based on description keywords
  String detectCategory(String description) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('restaurant') ||
        lowerDesc.contains('cafe') ||
        lowerDesc.contains('coffee') ||
        lowerDesc.contains('food') ||
        lowerDesc.contains('pizza') ||
        lowerDesc.contains('burger') ||
        lowerDesc.contains('starbucks') ||
        lowerDesc.contains('mcdonald')) {
      return 'Food';
    }

    if (lowerDesc.contains('uber') ||
        lowerDesc.contains('ola') ||
        lowerDesc.contains('taxi') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('petrol') ||
        lowerDesc.contains('transport')) {
      return 'Travel';
    }

    if (lowerDesc.contains('amazon') ||
        lowerDesc.contains('flipkart') ||
        lowerDesc.contains('mall') ||
        lowerDesc.contains('store') ||
        lowerDesc.contains('shop')) {
      return 'Shopping';
    }

    if (lowerDesc.contains('electricity') ||
        lowerDesc.contains('water') ||
        lowerDesc.contains('internet') ||
        lowerDesc.contains('mobile') ||
        lowerDesc.contains('utility')) {
      return 'Bills';
    }

    if (lowerDesc.contains('movie') ||
        lowerDesc.contains('cinema') ||
        lowerDesc.contains('netflix') ||
        lowerDesc.contains('spotify') ||
        lowerDesc.contains('game')) {
      return 'Entertainment';
    }

    if (lowerDesc.contains('hospital') ||
        lowerDesc.contains('pharmacy') ||
        lowerDesc.contains('doctor') ||
        lowerDesc.contains('medical') ||
        lowerDesc.contains('medicine')) {
      return 'Health';
    }

    if (lowerDesc.contains('school') ||
        lowerDesc.contains('college') ||
        lowerDesc.contains('course') ||
        lowerDesc.contains('book') ||
        lowerDesc.contains('tuition')) {
      return 'Education';
    }

    return 'Other';
  }

  // Remove selected image
  void removeImage() {
    selectedImage.value = null;
    isImageProcessed.value = false;
    descriptionController.clear();
    amountController.clear();
  }

  // Enable manual entry
  void enableManualEntry() {
    isManualEntry.value = true;
    isImageProcessed.value = false;
    if (selectedImage.value != null) {
      removeImage();
    }
  }

  // Validate transaction
  bool validateTransaction() {
    if (descriptionController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Please enter a description',
          isError: true);
      return false;
    }

    if (amountController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Please enter an amount',
          isError: true);
      return false;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackbar('Validation Error', 'Please enter a valid amount',
          isError: true);
      return false;
    }

    return true;
  }

  // Submit transaction
  Future<void> submitTransaction() async {
    if (!validateTransaction()) return;

    // Show loading indicator
    isSubmitting.value = true;

    // Create transaction object
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: descriptionController.text.trim(),
      category: selectedCategory.value,
      amount: double.parse(amountController.text),
      date: DateTime.now(),
      isExpense: isExpense.value,
      icon: categoryIcons[selectedCategory.value],
    );

    // Add to transactions (now it will call the API)
    final transactionVM = Get.find<TransactionViewModel>();
    final success = await transactionVM.addTransaction(transaction);

    // Hide loading indicator
    isSubmitting.value = false;

    if (success) {
      // Show success message using ScaffoldMessenger
      final context = Get.key.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Transaction added successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      // Navigate back after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isRegistered<AddTransactionViewModel>()) {
          Get.back();
        }
      });
    } else {
      // Show error message
      _showSnackbar('Error', 'Failed to add transaction. Please try again.',
          isError: true);
    }
  }

  // Reset form
  void resetForm() {
    descriptionController.clear();
    amountController.clear();
    selectedImage.value = null;
    isManualEntry.value = false;
    isImageProcessed.value = false;
    selectedCategory.value = 'Food';
    isExpense.value = true;
  }
}