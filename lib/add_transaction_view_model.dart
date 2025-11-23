import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'transaction_view_model.dart';

class AddTransactionViewModel extends GetxController {
  // Text controllers
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  
  // Observable variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isProcessingImage = false.obs;
  final RxBool isManualEntry = false.obs;
  final RxString selectedCategory = 'Food'.obs;
  final RxBool isExpense = true.obs;
  
  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  
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
        
        // Clear manual entry fields
        descriptionController.clear();
        amountController.clear();
        
        // Simulate OCR processing
        await processImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
        
        // Clear manual entry fields
        descriptionController.clear();
        amountController.clear();
        
        // Simulate OCR processing
        await processImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Process image with OCR (simulated)
  Future<void> processImage() async {
    isProcessingImage.value = true;
    
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate OCR results
    descriptionController.text = 'Coffee at Cafe';
    amountController.text = '250';
    
    isProcessingImage.value = false;
    
    Get.snackbar(
      'Success',
      'Bill scanned successfully!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Remove selected image
  void removeImage() {
    selectedImage.value = null;
    descriptionController.clear();
    amountController.clear();
  }

  // Enable manual entry
  void enableManualEntry() {
    isManualEntry.value = true;
    if (selectedImage.value != null) {
      removeImage();
    }
  }

  // Validate and submit transaction
  bool validateTransaction() {
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }

  // Submit transaction
  void submitTransaction() {
    if (!validateTransaction()) return;
    
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
    
    // Add to transactions
    final transactionVM = Get.find<TransactionViewModel>();
    transactionVM.addTransaction(transaction);
    
    // Reset form
    resetForm();
  }

  // Reset form
  void resetForm() {
    descriptionController.clear();
    amountController.clear();
    selectedImage.value = null;
    isManualEntry.value = false;
    selectedCategory.value = 'Food';
    isExpense.value = true;
  }
}