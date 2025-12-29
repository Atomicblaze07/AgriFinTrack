import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/transaction.dart';

class DairyScreen extends StatefulWidget {
  const DairyScreen({super.key});

  @override
  State<DairyScreen> createState() => _DairyScreenState();
}

class _DairyScreenState extends State<DairyScreen> {
  final _litresController = TextEditingController();
  final _rateController = TextEditingController(text: '40'); // default ₹/litre

  DateTime _selectedDate = DateTime.now();
  final List<_DairyEntry> _entries = [];

  bool _isSaving = false;

  @override
  void dispose() {
    _litresController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addEntry() async {
    final litresText = _litresController.text.trim();
    final rateText = _rateController.text.trim();
    final litres = double.tryParse(litresText);
    final rate = double.tryParse(rateText);

    if (litres == null || litres <= 0 || rate == null || rate <= 0) {
      return;
    }

    final income = litres * rate;

    setState(() => _isSaving = true);

    // 1) Update local list for UI
    setState(() {
      _entries.insert(
        0,
        _DairyEntry(
          date: _selectedDate,
          litres: litres,
          rate: rate,
          income: income,
        ),
      );
    });

    // 2) Also save as INCOME transaction in SQLite so it affects totals
    final tx = AgriTransaction(
      date: _selectedDate,
      type: 'income',
      category: 'Dairy Income',
      crop: 'None',
      amount: income.round(),
    );
    await AppDatabase.instance.insertTransaction(tx);

    setState(() => _isSaving = false);

    _litresController.clear();
  }

  double get _totalLitres {
    return _entries.fold(0.0, (sum, e) => sum + e.litres);
  }

  double get _totalIncome {
    return _entries.fold(0.0, (sum, e) => sum + e.income);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dairy Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Selected date'),
                subtitle: Text(
                  '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _litresController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Milk (litres)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Rate (₹/litre)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _isSaving ? 'Saving...' : 'Add Dairy Entry',
                ),
                onPressed: _isSaving ? null : _addEntry,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Summary (this session)'),
                subtitle: Text(
                  'Total milk: ${_totalLitres.toStringAsFixed(1)} L   |   Income: ₹${_totalIncome.toStringAsFixed(0)}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(
                      child: Text('No dairy entries yet. Add today\'s milk.'),
                    )
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final e = _entries[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${e.litres.toStringAsFixed(1)} L  @  ₹${e.rate.toStringAsFixed(0)}/L',
                            ),
                            subtitle: Text(
                              '${e.date.day}-${e.date.month}-${e.date.year}',
                            ),
                            trailing:
                                Text('₹${e.income.toStringAsFixed(0)}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DairyEntry {
  final DateTime date;
  final double litres;
  final double rate;
  final double income;

  _DairyEntry({
    required this.date,
    required this.litres,
    required this.rate,
    required this.income,
  });
}
