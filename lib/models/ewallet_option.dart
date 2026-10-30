import 'package:mobile_apps_recan/utils/localization.dart';

class EWalletOption {
  const new({required this.provider, required this.nominal});

  static const int pointsPerRupiah = 1;

  static const List<String> providers = ['GoPay', 'OVO', 'DANA'];
  static const List<int> nominals = [20000, 50000, 100000];

  static final List<EWalletOption> all = [
    for (final provider in providers)
      for (final nominal in nominals)
        EWalletOption(provider: provider, nominal: nominal),
  ];

  final String provider;
  final int nominal;

  int get pointsCost => nominal * pointsPerRupiah;

  String get titleId => 'Saldo $provider Rp ${_format(nominal)}';

  String get titleEn => '$provider Balance Rp ${_format(nominal)}';

  String get title => tr(titleId, titleEn);

  static List<EWalletOption> forProvider(String provider) =>
      all.where((option) => option.provider == provider).toList();

  static String _format(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
