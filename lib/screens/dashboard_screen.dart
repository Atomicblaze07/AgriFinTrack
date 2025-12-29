import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/transaction.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'reports_screen.dart';
import 'schemes_screen.dart';
import 'dairy_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalExpenses = 0;
  int _todayExpense = 0;

  int _monthIncome = 0;
  int _monthExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = AppDatabase.instance;
    final List<AgriTransaction> all = await db.getAllTransactions();

    int expense = 0;
    int todayExp = 0;
    int monthIncome = 0;
    int monthExpense = 0;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (final tx in all) {
      if (tx.type == 'expense') {
        // All-time total expenses
        expense += tx.amount;

        // Today's expense
        if (tx.date.year == currentYear &&
            tx.date.month == currentMonth &&
            tx.date.day == now.day) {
          todayExp += tx.amount;
        }

        // This month expenses
        if (tx.date.year == currentYear && tx.date.month == currentMonth) {
          monthExpense += tx.amount;
        }
      } else if (tx.type == 'income') {
        // This month income
        if (tx.date.year == currentYear && tx.date.month == currentMonth) {
          monthIncome += tx.amount;
        }
      }
    }

    setState(() {
      _totalExpenses = expense;
      _todayExpense = todayExp;
      _monthIncome = monthIncome;
      _monthExpense = monthExpense;
    });
  }

  Future<void> _openAddExpense() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (changed == true) {
      _loadData();
    }
  }

  Future<void> _openAddIncome() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
    );
    if (changed == true) {
      _loadData();
    }
  }

  void _openReports() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );
  }

  void _openSchemes() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SchemesScreen()),
    );
  }

  void _openDairy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DairyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int monthProfit = _monthIncome - _monthExpense;
    final bool isProfit = monthProfit >= 0;

    return Scaffold(
      appBar: AppBar(title: const Text('AgriFinTrack Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total Expenses card (all-time)
            Card(
              color: Colors.orange.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Expenses'),
                    Text(
                      '₹$_totalExpenses',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Today's Expense card
            Card(
              child: ListTile(
                title: const Text('Today\'s Expense'),
                trailing: Text(
                  '₹$_todayExpense',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // This Month Summary card
            Card(
              color: isProfit ? Colors.green.shade100 : Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Month Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Income:   ₹$_monthIncome'),
                    Text('Expenses: ₹$_monthExpense'),
                    const SizedBox(height: 4),
                    Text(
                      isProfit
                          ? 'Profit: ₹$monthProfit'
                          : 'Loss:   ₹${monthProfit.abs()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isProfit ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _openAddExpense,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Income'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _openAddIncome,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Reports'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _openReports,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.policy),
                      label: const Text('Govt Schemes'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _openSchemes,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.local_drink),
                      label: const Text('Dairy (Milk Records)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _openDairy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
