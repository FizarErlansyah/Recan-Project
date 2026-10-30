class DropSessionSummary {
  const new({required this.cans});

  static const int pointsPerCan = 25;
  static const int gramsPerCan = 14;
  static const double carbonKgPerCan = 0.13;

  final int cans;

  int get points => cans * pointsPerCan;

  int get grams => cans * gramsPerCan;

  double get carbonKg => cans * carbonKgPerCan;
}
