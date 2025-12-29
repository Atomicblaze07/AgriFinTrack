import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/app_database.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<AgriTransaction> _allTransactions = [];
  List<AgriTransaction> _transactions = [];
  Map<String, int> _categoryTotals = {};
  bool _showThisMonthOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await AppDatabase.instance.getAllTransactions();
    setState(() {
      _allTransactions = all;
    });
    _applyFilter();
  }

  void _applyFilter() {
    final Map<String, int> totals = {};
    final now = DateTime.now();
    final thisMonth = now.month;
    final thisYear = now.year;

    final filtered = _allTransactions.where((tx) {
      if (!_showThisMonthOnly) return true;
      return tx.date.year == thisYear && tx.date.month == thisMonth;
    }).toList();

    for (final tx in filtered) {
      if (tx.type != 'expense') continue;
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }

    setState(() {
      _transactions = filtered;
      _categoryTotals = totals;
    });
  }

  int get _totalExpense {
    return _categoryTotals.values.fold(0, (a, b) => a + b);
  }

  List<PieChartSectionData> _buildPieSections() {
    if (_categoryTotals.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: 'No data',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 12),
        ),
      ];
    }

    final colors = [
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
    ];

    final sections = <PieChartSectionData>[];
    int i = 0;
    _categoryTotals.forEach((category, amount) {
      final value = amount.toDouble();
      final color = colors[i % colors.length];
      final percent =
          _totalExpense == 0 ? 0 : (amount * 100 / _totalExpense).round();

      sections.add(
        PieChartSectionData(
          value: value,
          color: color,
          radius: 70,
          title: '$percent%',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Charts'),
              Tab(icon: Icon(Icons.list), text: 'List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pie Chart + filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Title + filter dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense by Category',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<bool>(
                        value: _showThisMonthOnly,
                        items: const [
                          DropdownMenuItem(
                            value: false,
                            child: Text('All time'),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('This month'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _showThisMonthOnly = v);
                          _applyFilter();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _categoryTotals.entries.map((e) {
                        final category = e.key;
                        final amount = e.value;
                        final percent = _totalExpense == 0
                            ? 0
                            : (amount * 100 / _totalExpense).round();
                        return ListTile(
                          leading: const Icon(Icons.label),
                          title: Text(category),
                          subtitle: Text('₹$amount'),
                          trailing: Text('$percent%'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Raw list (uses same filtered _transactions)
            ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return ListTile(
                  title: Text('${tx.category} - ${tx.crop}'),
                  subtitle: Text(tx.date.toLocal().toString()),
                  trailing: Text(
                    '${tx.type == 'expense' ? '-' : '+'}₹${tx.amount}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

