class Review {
  final String? id;
  final String storeId;
  final String orderId;
  final String customerId;
  final String customerName;
  final double rating;
  final String comment;
  final String? merchantReply;
  final DateTime? createdAt;
  final DateTime? repliedAt;

  Review({
    this.id,
    required this.storeId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.merchantReply,
    this.createdAt,
    this.repliedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      storeId: json['storeId'] ?? '',
      orderId: json['orderId'] ?? '',
      customerId: json['userId'] ?? json['customerId'] ?? '',
      customerName: json['userName'] ?? json['customerName'] ?? '',
      rating: (json['starRating'] ?? json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      merchantReply: json['replyComment'] ?? json['merchantReply'],
      createdAt: _parseDate(json['createdAt']),
      repliedAt: _parseDate(json['repliedAt']),
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
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'merchantReply': merchantReply,
      'createdAt': createdAt?.toIso8601String(),
      'repliedAt': repliedAt?.toIso8601String(),
    };
  }
}
