import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/transaction.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Market Sale';
  String _selectedCrop = 'None';

  final _incomeCategories = [
    'Market Sale',
    'Govt Subsidy',
    'Dairy Income',
    'Other Income',
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

  final _customCropController = TextEditingController();
  final _customCategoryController = TextEditingController();

  bool _isSaving = false;

  Future<void> _save() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) return;
    final amount = int.tryParse(text);
    if (amount == null || amount <= 0) return;

    final cropName = _selectedCrop == 'Other' &&
            _customCropController.text.trim().isNotEmpty
        ? _customCropController.text.trim()
        : _selectedCrop;

    final categoryName = _selectedCategory == 'Other Income' &&
            _customCategoryController.text.trim().isNotEmpty
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    setState(() => _isSaving = true);

    final tx = AgriTransaction(
      date: DateTime.now(),
      type: 'income',
      category: categoryName,
      crop: cropName,
      amount: amount,
    );

    await AppDatabase.instance.insertTransaction(tx);

    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCropController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _incomeCategories
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
                  labelText: 'Income source',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedCategory == 'Other Income')
                TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Custom income source',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
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
                  labelText: 'Crop (if related)',
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
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount received (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
                          'Save Income',
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
