import 'package:mobile_apps_recan/utils/localization.dart';

class UserProfile {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.pointsBalance,
  });

  factory fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    pointsBalance: json['points_balance'] as int,
  );

  final int id;
  final String name;
  final String email;
  final int pointsBalance;
}

class DropStation {
  const new({
    required this.id,
    required String name,
    required String location,
    required this.capacityPercentage,
    required this.status,
    String? nameEn,
    String? locationEn,
    this.distanceMeters,
    this.imageUrl,
  }) : nameId = name,
       nameEn = nameEn ?? name,
       locationId = location,
       locationEn = locationEn ?? location;

  factory fromJson(Map<String, dynamic> json) => DropStation(
    id: json['id'] as int,
    name: json['name'] as String,
    location: json['location'] as String,
    capacityPercentage: json['capacity_percentage'] as int,
    status: json['status'] as String,
    distanceMeters: (json['distance_m'] as num?)?.round(),
    imageUrl: json['image_url'] as String?,
  );

  final int id;
  final String nameId;
  final String nameEn;
  final String locationId;
  final String locationEn;
  final int capacityPercentage;
  final String status;

  final int? distanceMeters;
  final String? imageUrl;

  String get name => tr(nameId, nameEn);
  String get location => tr(locationId, locationEn);

  String? get distanceLabel {
    final m = distanceMeters;
    if (m == null) return null;
    return m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '$m m';
  }

  bool get isFull => status == 'full' || capacityPercentage >= 90;
}

enum ProductCategory {
  toy,
  decor;

  String get label => switch (this) {
    toy => tr('Mainan', 'Toys'),
    decor => tr('Hiasan', 'Decor'),
  };

  static ProductCategory parse(String? raw) => ProductCategory.values
      .firstWhere((value) => value.name == raw, orElse: () => toy);
}

class UpcycleProduct {
  const new({
    required this.id,
    required String name,
    required String description,
    required this.pricePoints,
    required this.priceIdr,
    required this.stock,
    String? nameEn,
    String? descriptionEn,
    this.category = ProductCategory.toy,
    this.imageUrl,
  }) : nameId = name,
       nameEn = nameEn ?? name,
       descriptionId = description,
       descriptionEn = descriptionEn ?? description;

  factory fromJson(Map<String, dynamic> json) => UpcycleProduct(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
    pricePoints: json['price_points'] as int,
    priceIdr: json['price_idr'] as int,
    stock: json['stock'] as int,
    category: ProductCategory.parse(json['category'] as String?),
    imageUrl: json['image_url'] as String?,
  );

  final int id;
  final String nameId;
  final String nameEn;
  final String descriptionId;
  final String descriptionEn;
  final int pricePoints;
  final int priceIdr;
  final int stock;
  final ProductCategory category;
  final String? imageUrl;

  String get name => tr(nameId, nameEn);
  String get description => tr(descriptionId, descriptionEn);

  UpcycleProduct withStock(int value) => UpcycleProduct(
    id: id,
    name: nameId,
    nameEn: nameEn,
    description: descriptionId,
    descriptionEn: descriptionEn,
    pricePoints: pricePoints,
    priceIdr: priceIdr,
    stock: value,
    category: category,
    imageUrl: imageUrl,
  );
}

class DashboardData {
  const new({
    required this.user,
    required this.dropStations,
    required this.products,
  });

  factory fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List<dynamic>)
            .map((e) => parse(e as Map<String, dynamic>))
            .toList();

    return DashboardData(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      dropStations: list('drop_stations', DropStation.fromJson),
      products: list('upcycle_products', UpcycleProduct.fromJson),
    );
  }

  final UserProfile user;
  final List<DropStation> dropStations;
  final List<UpcycleProduct> products;
}
