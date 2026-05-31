class Store {
  final String? id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String avtUrl;
  final String backUrl;
  final bool isOpen;
  final String deliveryTime;
  final double deliveryFee;
  final List<String> categoryIds;
  final dynamic restaurantCategories;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Store({
    this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.avtUrl,
    required this.backUrl,
    required this.isOpen,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.categoryIds,
    this.restaurantCategories,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      avtUrl: json['avtUrl'] ?? '',
      backUrl: json['backUrl'] ?? '',
      isOpen: json['isOpen'] ?? false,
      deliveryTime: json['deliveryTime'] ?? '',
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      restaurantCategories: json['restaurant_categories'],
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'avtUrl': avtUrl,
      'backUrl': backUrl,
      'isOpen': isOpen,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'categoryIds': categoryIds,
      'restaurant_categories': restaurantCategories,
      'lat': lat,
      'lng': lng,
    };
  }
}
