import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_transaction_view_model.dart';

class AddTransactionView extends StatelessWidget {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AddTransactionViewModel controller =
        Get.put(AddTransactionViewModel());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.resetForm();
            if (Get.isSnackbarOpen) {
              Get.closeAllSnackbars();
            }
            Future.microtask(() => Get.back());
          },
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Option Cards
            Obx(() => Column(
                  children: [
                    // Scan Bill Option
                    _buildOptionCard(
                      icon: Icons.camera_alt,
                      title: 'Scan Bill',
                      subtitle: 'Take a photo of your receipt',
                      color: const Color(0xFF4D7FFF),
                      isSelected: controller.selectedImage.value != null,
                      isDisabled: controller.isManualEntry.value,
                      onTap: () => _showImageSourceDialog(controller),
                    ),

                    const SizedBox(height: 16),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Manual Entry Option
                    _buildOptionCard(
                      icon: Icons.edit,
                      title: 'Manual Entry',
                      subtitle: 'Type description and amount',
                      color: const Color(0xFF6B9FFF),
                      isSelected: controller.isManualEntry.value,
                      isDisabled: controller.selectedImage.value != null,
                      onTap: () {
                        controller.enableManualEntry();
                      },
                    ),
                  ],
                )),

            const SizedBox(height: 24),

            // Image Preview or Processing
            Obx(() {
              if (controller.isProcessingImage.value) {
                return _buildProcessingCard();
              } else if (controller.selectedImage.value != null) {
                return _buildImagePreview(controller);
              }
              return const SizedBox.shrink();
            }),

            // Transaction Form
            Obx(() {
              if (controller.selectedImage.value != null ||
                  controller.isManualEntry.value) {
                return _buildTransactionForm(controller);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.selectedImage.value != null ||
            controller.isManualEntry.value) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: controller.submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D7FFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isSelected ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4D7FFF)),
          ),
          const SizedBox(height: 16),
          Text(
            'Processing image...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is extracting bill details',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(AddTransactionViewModel controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  controller.selectedImage.value!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: controller.removeImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Bill scanned successfully',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(AddTransactionViewModel controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Type Toggle
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      'Expense',
                      controller.isExpense.value,
                      () => controller.isExpense.value = true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      'Income',
                      !controller.isExpense.value,
                      () => controller.isExpense.value = false,
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 20),

          // Description Field
          TextField(
            controller: controller.descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Coffee at Starbucks',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4D7FFF), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount Field
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixIcon: const Icon(Icons.currency_rupee),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4D7FFF), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Dropdown
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.selectedCategory.value,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF4D7FFF), width: 2),
                  ),
                ),
                items: controller.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Text(
                          controller.categoryIcons[category] ?? '📌',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedCategory.value = newValue;
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4D7FFF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(AddTransactionViewModel controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D7FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF4D7FFF)),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D7FFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.photo_library, color: Color(0xFF4D7FFF)),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
