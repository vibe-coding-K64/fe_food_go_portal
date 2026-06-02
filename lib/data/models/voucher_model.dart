import 'package:intl/intl.dart';

class Voucher {
  final String? id;
  final String? storeId;
  final String name;
  final String code;
  final int type; // 1: %, 2: cash
  final double value;
  final int pointsRequired;
  final String imageUrl;
  final int remaining;
  final String terms;
  final double minOrderValue;
  final int limitCount;
  final int usedCount;
  final DateTime? expiryDate;
  final bool isActive;
  final bool isFreeship;

  Voucher({
    this.id,
    this.storeId,
    required this.name,
    required this.code,
    required this.type,
    required this.value,
    required this.pointsRequired,
    required this.imageUrl,
    required this.remaining,
    required this.terms,
    required this.minOrderValue,
    required this.limitCount,
    this.usedCount = 0,
    this.expiryDate,
    this.isActive = true,
    this.isFreeship = false,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'] ?? json['title'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 1,
      value: (json['value'] ?? 0).toDouble(),
      pointsRequired: json['pointsRequired'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      remaining: json['remaining'] ?? 0,
      terms: json['terms'] ?? '',
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      limitCount: json['limitCount'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      expiryDate: _parseDate(json['expiryDate']),
      isActive: json['isActive'] ?? true,
      isFreeship: json['isFreeship'] ?? false,
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
      'storeId': storeId,
      'name': name,
      'code': code,
      'type': type,
      'value': value,
      'pointsRequired': pointsRequired,
      'imageUrl': imageUrl,
      'remaining': remaining,
      'terms': terms,
      'minOrderValue': minOrderValue,
      'limitCount': limitCount,
      'usedCount': usedCount,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'isActive': isActive,
      'isFreeship': isFreeship,
    };
  }

  String get discountText {
    if (type == 1) {
      return 'Giảm ${value.toInt()}%';
    } else {
      return 'Giảm ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value)}';
    }
  }

  String get minOrderText {
    return 'Đơn tối thiểu ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(minOrderValue)}';
  }
}
