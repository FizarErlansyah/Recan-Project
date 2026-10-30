import 'package:mobile_apps_recan/utils/localization.dart';

class MemberTier {
  const new({
    required this.name,
    required this.emoji,
    required this._rangeLabel,
    required this._rangeLabelEn,
    required this._benefits,
    required this._benefitsEn,
    this.nextName,
    this.target,
  });

  static const MemberTier bronze = MemberTier(
    name: 'Bronze',
    emoji: '🥉',
    rangeLabel: 'Kurang dari 1.000 Poin',
    rangeLabelEn: 'Less than 1,000 Points',
    benefits: [
      'Akses Drop Station dasar',
      'Kumpulkan poin dari setiap setoran kaleng',
    ],
    benefitsEn: [
      'Basic Drop Station access',
      'Earn points from every can deposit',
    ],
    nextName: 'Silver',
    target: 1000,
  );
  static const MemberTier silver = MemberTier(
    name: 'Silver',
    emoji: '🥈',
    rangeLabel: '1.000 - 5.000 Poin',
    rangeLabelEn: '1,000 - 5,000 Points',
    benefits: ['Diskon redeem 5%', 'Misi Harian ekstra'],
    benefitsEn: ['5% redeem discount', 'Extra Daily Missions'],
    nextName: 'Gold',
    target: 5000,
  );
  static const MemberTier gold = MemberTier(
    name: 'Gold',
    emoji: '🥇',
    rangeLabel: 'Lebih dari 5.000 Poin',
    rangeLabelEn: 'More than 5,000 Points',
    benefits: [
      'Prioritas redeem produk premium (Jet/F1)',
      'Merchandise eksklusif',
    ],
    benefitsEn: [
      'Priority redemption of premium products (Jet/F1)',
      'Exclusive merchandise',
    ],
  );

  static const List<MemberTier> all = [bronze, silver, gold];

  final String name;
  final String emoji;
  final String _rangeLabel;
  final String _rangeLabelEn;
  final List<String> _benefits;
  final List<String> _benefitsEn;
  final String? nextName;
  final int? target;

  String get rangeLabel => tr(_rangeLabel, _rangeLabelEn);
  List<String> get benefits => trValue(_benefits, _benefitsEn);

  int get rank => all.indexOf(this);

  static MemberTier of(int points) {
    if (points < bronze.target!) return bronze;
    if (points < silver.target!) return silver;
    return gold;
  }

  double progress(int points) {
    final goal = target;
    return goal == null ? 1.0 : (points / goal).clamp(0.0, 1.0);
  }
}
