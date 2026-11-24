import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/faq_item.dart';
import 'package:mobile_apps_recan/pages/ai_chat_page.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/faq_tile.dart';

class HelpCenterPage extends StatelessWidget {
  const new({super.key});

  static void open(BuildContext context) {
    Navigator.of(context)
        .push(FadePageRoute<void>(page: const HelpCenterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Pusat Bantuan', 'Help Center'))),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 104 + bottomInset),
            children: [
              Text(
                tr('Pertanyaan Umum', 'Frequently Asked Questions'),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                tr('Jawaban cepat seputar ReCan', 'Quick answers about ReCan'),
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              for (final item in FaqItem.all) ...[
                FaqTile(item: item),
                const SizedBox(height: 12),
              ],
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24 + bottomInset,
            child: _AskAiButton(onTap: () => AiChatPage.open(context)),
          ),
        ],
      ),
    );
  }
}

class _AskAiButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.silverLight.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HugeIcon(icon: AppIcons.ai, color: AppColors.primarySoft),
              const SizedBox(width: 12),
              Text(
                tr('Tanya ReCan AI', 'Ask ReCan AI'),
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primarySoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
