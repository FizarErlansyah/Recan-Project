import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/utils/initials.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class UserProfile {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.pointsBalance,
    this.totalCans = 0,
    this.avatar = AvatarRef.none,
  });

  /// Reads a `profiles` row. The email lives in auth, so the caller adds it.
  factory fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['full_name'] as String,
    email: json['email'] as String? ?? '',
    pointsBalance: (json['points'] as num).toInt(),
    totalCans: (json['total_cans'] as num).toInt(),
    avatar: AvatarRef(url: json['avatar_url'] as String?),
  );

  final String id;
  final String name;
  final String email;
  final int pointsBalance;
  final int totalCans;
  final AvatarRef avatar;

  String get initials => initialsOf(name);
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
    this.position,
  }) : nameId = name,
       nameEn = nameEn ?? name,
       locationId = location,
       locationEn = locationEn ?? location;

  /// Reads a row of the `stations_with_distance` function.
  factory fromJson(Map<String, dynamic> json) {
    final lat = json['lat'] as num?;
    final lng = json['lng'] as num?;
    return DropStation(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      location: json['location'] as String,
      locationEn: json['location_en'] as String?,
      capacityPercentage: (json['capacity_percentage'] as num).toInt(),
      status: json['status'] as String,
      distanceMeters: (json['distance_m'] as num?)?.round(),
      imageUrl: json['image_url'] as String?,
      position: lat == null || lng == null
          ? null
          : LatLng(lat.toDouble(), lng.toDouble()),
    );
  }

  final int id;
  final String nameId;
  final String nameEn;
  final String locationId;
  final String locationEn;
  final int capacityPercentage;
  final String status;

  final int? distanceMeters;
  final String? imageUrl;
  final LatLng? position;

  String get name => tr(nameId, nameEn);
  String get location => tr(locationId, locationEn);

  String? get distanceLabel {
    final m = distanceMeters;
    if (m == null) return null;
    return m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '$m m';
  }

  bool get isFull => status == 'full' || capacityPercentage >= 90;

  bool get isAlmostFull => capacityPercentage >= MapStation.fullThreshold;
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

  /// Reads a `catalog_items` row of type product.
  factory fromJson(Map<String, dynamic> json) => UpcycleProduct(
    id: json['id'] as int,
    name: json['name'] as String,
    nameEn: json['name_en'] as String?,
    description: json['description'] as String,
    descriptionEn: json['description_en'] as String?,
    pricePoints: (json['price_points'] as num).toInt(),
    priceIdr: (json['price_idr'] as num).toInt(),
    stock: (json['stock'] as num).toInt(),
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

  final UserProfile user;
  final List<DropStation> dropStations;
  final List<UpcycleProduct> products;
}
