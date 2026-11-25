import 'package:mobile_apps_recan/models/dashboard_data.dart';

/// Which drawing stands in for a craft that has no photo yet.
enum ProductArt {
  raceCar,
  jet,
  classicCar,
  ship,
  vase,
  lamp,
  can;

  static const List<ProductArt> _toys = [raceCar, jet, classicCar];
  static const List<ProductArt> _decor = [ship, vase, lamp];

  /// Neighbouring ids get different drawings within their category.
  static ProductArt of(ProductCategory category, int seed) {
    final pool = switch (category) {
      ProductCategory.toy => _toys,
      ProductCategory.decor => _decor,
    };
    return pool[(seed - 1) % pool.length];
  }
}
