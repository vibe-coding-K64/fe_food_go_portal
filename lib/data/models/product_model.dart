class ProductOption {
  final String name;
  final double price;

  ProductOption({required this.name, required this.price});

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}

class ProductOptionGroup {
  final String name;
  final List<ProductOption> options;

  ProductOptionGroup({
    required this.name, 
    required this.options
  });

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      name: json['name'] ?? '',
      options: (json['options'] as List?)?.map((item) => ProductOption.fromJson(item)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class Product {
  final String? id;
  final String storeId;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double basePrice;
  final String? imageUrl;
  final bool isOutOfStock;
  final bool isFeatured;
  final List<ProductOptionGroup>? optionGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.storeId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.basePrice,
    this.imageUrl,
    this.isOutOfStock = false,
    this.isFeatured = false,
    this.optionGroups,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      storeId: json['storeId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      isOutOfStock: json['isOutOfStock'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      optionGroups: (json['optionGroups'] as List?)?.map((item) => ProductOptionGroup.fromJson(item)).toList(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'isOutOfStock': isOutOfStock,
      'isFeatured': isFeatured,
      'optionGroups': optionGroups?.map((e) => e.toJson()).toList(),
    };
  }
}
