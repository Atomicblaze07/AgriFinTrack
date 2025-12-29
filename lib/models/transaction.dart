class AgriTransaction {
  final int? id;           // Primary key in SQLite (can be null before insert)
  final DateTime date;     // When the transaction happened
  final String type;       // 'expense' or 'income'
  final String category;   // Seeds, Fertilizer, Labor, etc.
  final String crop;       // Cotton, Soybean, etc.
  final int amount;        // Amount in rupees

  AgriTransaction({
    this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.crop,
    required this.amount,
  });

  // Convert to Map<String, dynamic> so sqflite can store it in a row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'crop': crop,
      'amount': amount,
    };
  }

  // Create AgriTransaction from a Map read from SQLite
  factory AgriTransaction.fromMap(Map<String, dynamic> map) {
    return AgriTransaction(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      category: map['category'] as String,
      crop: map['crop'] as String,
      amount: map['amount'] as int,
    );
  }
}
