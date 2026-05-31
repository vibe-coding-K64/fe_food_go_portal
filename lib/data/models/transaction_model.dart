class Transaction {
  final String? id;
  final String walletId;
  final String userId;
  final String type; // order_payment, withdrawal, refund
  final double amount;
  final double fee;
  final double netAmount;
  final String description;
  final String? orderId;
  final String status; // pending, completed, failed
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.walletId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.fee,
    required this.netAmount,
    this.description = '',
    this.orderId,
    required this.status,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      walletId: json['walletId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      orderId: json['orderId'],
      status: json['status'] ?? 'pending',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    if (dateData is String) return DateTime.tryParse(dateData);
    if (dateData is int) return DateTime.fromMillisecondsSinceEpoch(dateData);
    if (dateData is Map<String, dynamic>) {
      if (dateData.containsKey('_seconds')) {
        return DateTime.fromMillisecondsSinceEpoch((dateData['_seconds'] as int) * 1000);
      } else if (dateData.containsKey('seconds')) {
        return DateTime.fromMillisecondsSinceEpoch((dateData['seconds'] as int) * 1000);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'userId': userId,
      'type': type,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'description': description,
      'orderId': orderId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
