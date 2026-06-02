class Wallet {
  final String? id;
  final String userId;
  final String role; // merchant
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;
  final double pendingBalance;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Wallet({
    this.id,
    required this.userId,
    required this.role,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.pendingBalance,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'] ?? '',
      role: json['role'] ?? 'merchant',
      balance: (json['balance'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      bankAccountName: json['bankAccountName'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      'balance': balance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'pendingBalance': pendingBalance,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
