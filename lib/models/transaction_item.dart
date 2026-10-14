class TransactionItem {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String type; // expense or credit
  final String frequency;

  const TransactionItem({this.id, required this.title, required this.amount, required this.category,
    required this.date, this.description = '', this.type = 'expense', this.frequency = 'Monthly'});

  Map<String, Object?> toMap() => {
    'id': id, 'title': title, 'amount': amount, 'category': category,
    'date': date.toIso8601String(), 'description': description, 'type': type, 'frequency': frequency,
  };

  factory TransactionItem.fromMap(Map<String, Object?> map) => TransactionItem(
    id: map['id'] as int?, title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(), category: map['category'] as String,
    date: DateTime.parse(map['date'] as String), description: (map['description'] as String?) ?? '',
    type: (map['type'] as String?) ?? 'expense', frequency: (map['frequency'] as String?) ?? 'Monthly');
}
