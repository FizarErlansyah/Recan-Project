import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/chat_topic.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class ChatSuggestionChips extends StatefulWidget {
  const new({
    required this.topics,
    required this.onSelected,
    super.key,
    this.enabled = true,
  });

  final List<ChatTopic> topics;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  State<ChatSuggestionChips> createState() => _ChatSuggestionChipsState();
}

class _ChatSuggestionChipsState extends State<ChatSuggestionChips> {
  ChatCategory? _category;

  List<ChatTopic> get _visible => _category == null
      ? widget.topics
      : widget.topics.where((t) => t.category == _category).toList();

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryTab(
                  label: tr('Semua', 'All'),
                  icon: AppIcons.apps,
                  active: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in ChatCategory.values) ...[
                  const SizedBox(width: 8),
                  _CategoryTab(
                    label: category.label,
                    icon: category.icon,
                    active: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: ListView.separated(
                key: ValueKey(_category),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => _SuggestionChip(
                  label: visible[i].question,
                  onTap: widget.enabled
                      ? () => widget.onSelected(visible[i].question)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconGlyph icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = active ? AppColors.white : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(icon: icon, size: 18, color: foreground),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = onTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.5,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primarySoft, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primarySoft.withValues(alpha: 0.5),
          highlightColor: AppColors.primarySoft.withValues(alpha: 0.3),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
