import 'package:mobile_apps_recan/utils/localization.dart';

class IndonesianDate {
  const new _();

  static const List<String> _monthsId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String date(DateTime value) =>
      '${value.day} ${trValue(_monthsId, _monthsEn)[value.month - 1]} ${value.year}';

  static String relativeDay(DateTime value, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final difference = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(value.year, value.month, value.day)).inDays;
    if (difference == 0) return tr('Hari ini', 'Today');
    if (difference == 1) return tr('Kemarin', 'Yesterday');
    return date(value);
  }

  static String dateTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${date(value)} • $hour:$minute';
  }
}
