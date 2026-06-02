import 'dart:convert';

class OrderItem {
  final String? foodId;
  final String? imageUrl;
  final String name;
  final String options;
  final int quantity;
  final double price;

  OrderItem({
    this.foodId,
    this.imageUrl,
    required this.name,
    required this.options,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'],
      imageUrl: json['imageUrl'],
      name: json['name'] ?? '',
      options: _parseOptions(json['options']),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _parseOptions(dynamic optionsData) {
    if (optionsData == null) return '';
    String str = optionsData.toString().trim();
    if (str.isEmpty || str == '[]') return '';
    
    try {
      // Try parsing standard JSON
      if (str.startsWith('[')) {
        final List<dynamic> list = jsonDecode(str);
        return list.map((e) => e['name']?.toString() ?? '').where((e) => e.isNotEmpty).join(', ');
      }
    } catch (_) {
      // Fallback for Java's toString(): [{price=0.0, name=Thêm nem cua bể}]
      final regex = RegExp(r'name=([^,}\]]+)');
      final matches = regex.allMatches(str);
      if (matches.isNotEmpty) {
        return matches.map((m) => m.group(1)?.trim()).join(', ');
      }
    }
    return str;
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'imageUrl': imageUrl,
      'name': name,
      'options': options,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String? id;
  final String? userId;
  final String storeId;
  final String? storeName;
  final String code;
  final String? addressId;
  final String deliveryAddress;
  final String receiverName;
  final String receiverPhone;
  final double deliveryFee;
  final String driverName;
  final String driverPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? deliveryHeading;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? note;

  Order({
    this.id,
    this.userId,
    required this.storeId,
    this.storeName,
    required this.code,
    this.addressId,
    required this.deliveryAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.deliveryFee,
    required this.driverName,
    required this.driverPhone,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.deliveryHeading,
    this.deliveryLat,
    this.deliveryLng,
    this.note,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    
    String parsedStatus = json['status']?.toString() ?? 'Chờ xác nhận';
    // Map number to string if backend returns numbers
    if (parsedStatus == '0') parsedStatus = 'Chờ xác nhận';
    if (parsedStatus == '1') parsedStatus = 'Đang chuẩn bị';
    if (parsedStatus == '2') parsedStatus = 'Đang giao';
    if (parsedStatus == '3') parsedStatus = 'Hoàn thành';
    if (parsedStatus == '4') parsedStatus = 'Đã hủy';

    return Order(
      id: json['id'],
      userId: json['userId'],
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'],
      code: json['code'] ?? '',
      addressId: json['addressId'],
      deliveryAddress: json['deliveryAddress'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      items: itemsList.map((i) => OrderItem.fromJson(i)).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      status: parsedStatus,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveryHeading: (json['deliveryHeading'] as num?)?.toDouble(),
      deliveryLat: (json['deliveryLat'] as num?)?.toDouble(),
      deliveryLng: (json['deliveryLng'] as num?)?.toDouble(),
      note: json['note'],
    );
  }

  static String _parsePaymentMethod(dynamic value) {
    if (value == null) return 'Tiền mặt';
    String str = value.toString();
    if (str == '1') return 'Ví MoMo';
    if (str == '2') return 'Tiền mặt';
    if (str == '3') return 'ZaloPay';
    if (str == '4') return 'Thẻ ngân hàng';
    return str;
  }

  int get statusValue {
    if (status == 'Chờ xác nhận') return 0;
    if (status == 'Đang chuẩn bị') return 1;
    if (status == 'Đang giao') return 2;
    if (status == 'Hoàn thành') return 3;
    if (status == 'Đã hủy') return 4;
    return 0;
  }

  int get paymentMethodValue {
    if (paymentMethod == 'Ví MoMo') return 1;
    if (paymentMethod == 'Tiền mặt') return 2;
    if (paymentMethod == 'ZaloPay') return 3;
    if (paymentMethod == 'Thẻ ngân hàng') return 4;
    return 2;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'storeId': storeId,
      'storeName': storeName,
      'code': code,
      'addressId': addressId,
      'deliveryAddress': deliveryAddress,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'deliveryFee': deliveryFee,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethodValue,
      'status': statusValue,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveryHeading': deliveryHeading,
      'deliveryLat': deliveryLat,
      'deliveryLng': deliveryLng,
      'note': note,
    };
  }
}
