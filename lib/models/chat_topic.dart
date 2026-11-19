import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum ChatCategory {
  general,
  drop,
  rewards;

  String get label => switch (this) {
    general => tr('Umum', 'General'),
    drop => tr('Setor Kaleng', 'Drop Cans'),
    rewards => tr('Poin & Hadiah', 'Points & Rewards'),
  };

  IconGlyph get icon => switch (this) {
    general => AppIcons.info,
    drop => AppIcons.recycle,
    rewards => AppIcons.gift,
  };
}

class ChatTopic {
  const new({
    required this.category,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  final ChatCategory category;
  final String question;
  final String answer;
  final List<String> keywords;
}
