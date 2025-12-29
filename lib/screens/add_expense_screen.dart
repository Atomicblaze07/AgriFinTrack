import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/transaction.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _customCropController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedCategory = 'Seeds';
  String _selectedCrop = 'None';

  final _categories = [
    'Seeds',
    'Fertilizer',
    'Labor',
    'Pesticides',
    'Transport',
    'Water/Electricity',
    'Loan EMI',
    'Animal Feed',
    'Repairs',
    'Dairy Expense',
    'Others',
    'Other (custom)',
  ];

  final _crops = [
    'None',
    'Cotton',
    'Soybean',
    'Wheat',
    'Rice',
    'Sugarcane',
    'Vegetables',
    'Fruits',
    'Other',
  ];

  bool _isSaving = false;

  Future<void> _save() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) return;
    final amount = int.tryParse(text);
    if (amount == null || amount <= 0) return;

    // Handle custom crop
    final cropName = _selectedCrop == 'Other' &&
            _customCropController.text.trim().isNotEmpty
        ? _customCropController.text.trim()
        : _selectedCrop;

    // Handle custom category
    final categoryName = _selectedCategory == 'Other (custom)' &&
            _customCategoryController.text.trim().isNotEmpty
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    setState(() => _isSaving = true);

    final tx = AgriTransaction(
      date: DateTime.now(),
      type: 'expense',
      category: categoryName,
      crop: cropName,
      amount: amount,
    );

    await AppDatabase.instance.insertTransaction(tx);

    setState(() => _isSaving = false);

    // Go back and tell previous screen that data changed
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customCropController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Category + custom category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v ?? _selectedCategory),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedCategory == 'Other (custom)')
                TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Custom category name',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),

              // Crop + custom crop
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                items: _crops
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCrop = v ?? _selectedCrop),
                decoration: const InputDecoration(
                  labelText: 'Crop',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedCrop == 'Other')
                TextField(
                  controller: _customCropController,
                  decoration: const InputDecoration(
                    labelText: 'Custom crop name',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),

              // Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Expense',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
