import 'package:flutter/material.dart';

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

  IconData get icon => switch (this) {
    general => Icons.info_outline_rounded,
    drop => Icons.recycling_rounded,
    rewards => Icons.card_giftcard_rounded,
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
