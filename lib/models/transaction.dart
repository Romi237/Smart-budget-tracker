// lib/models/transaction.dart
enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.locationLabel,
    this.latitude,
    this.longitude,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
        'locationLabel': locationLabel,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        type: TransactionType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => TransactionType.expense,
        ),
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        description: map['description'] as String,
        date: DateTime.parse(map['date'] as String),
        locationLabel: map['locationLabel'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
      );

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? locationLabel,
    double? latitude,
    double? longitude,
  }) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        description: description ?? this.description,
        date: date ?? this.date,
        locationLabel: locationLabel ?? this.locationLabel,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}
