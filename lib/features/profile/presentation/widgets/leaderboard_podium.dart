import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/utils/weight_format.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';

/// The top three: second, first and third from left to right, rising into
/// place with the winner last.
class LeaderboardPodium extends StatelessWidget {
  const new({required this.entries, super.key});

  /// The best three at most, in rank order.
  final List<LeaderboardEntry> entries;

  static const List<int> _order = [1, 0, 2];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final place in _order)
          Expanded(
            child: place < entries.length
                ? _Standing(entry: entries[place], place: place)
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

typedef _Medal = ({Color fill, Color label, double height, double delay});

const List<_Medal> _medals = [
  (fill: AppColors.warm, label: AppColors.onWarm, height: 96, delay: 0.4),
  (
    fill: AppColors.silverLight,
    label: AppColors.primaryDeep,
    height: 72,
    delay: 0.2,
  ),
  (fill: AppColors.bronzeLight, label: AppColors.onWarm, height: 56, delay: 0),
];

class _Standing extends StatelessWidget {
  const new({required this.entry, required this.place});

  final LeaderboardEntry entry;

  /// 0 for first place.
  final int place;

  @override
  Widget build(BuildContext context) {
    final medal = _medals[place];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(
            initials: entry.initials,
            avatar: entry.avatar,
            size: place == 0 ? 68 : 52,
            borderColor: medal.fill,
            borderWidth: 3,
          ),
          const SizedBox(height: 8),
          _Who(entry: entry),
          const SizedBox(height: 8),
          _Step(rank: entry.rank, place: place),
        ],
      ),
    );
  }
}

class _Who extends StatelessWidget {
  const new({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = entry.isCurrentUser
        ? tr('${entry.name} (Kamu)', '${entry.name} (You)')
        : entry.name;

    return Column(
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(
            color: entry.isCurrentUser ? context.palette.accent : null,
          ),
        ),
        Text(
          formatWeight(entry.totalKg * 1000),
          maxLines: 1,
          style: textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const new({required this.rank, required this.place});

  static const Duration _rise = Duration(milliseconds: 1000);

  final int rank;
  final int place;

  @override
  Widget build(BuildContext context) {
    final medal = _medals[place];
    final still = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: still ? Duration.zero : _rise,
      curve: Interval(medal.delay, 1, curve: Curves.easeOutBack),
      builder: (context, grown, child) => SizedBox(
        key: ValueKey('podium-${place + 1}'),
        height: medal.height * grown,
        width: double.infinity,
        child: child,
      ),
      child: _StepFace(rank: rank, medal: medal),
    );
  }
}

class _StepFace extends StatelessWidget {
  const new({required this.rank, required this.medal});

  final int rank;
  final _Medal medal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: medal.fill,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDecorations.controlRadius),
        ),
      ),
      child: ClipRect(
        child: Center(
          child: Text(
            '$rank',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: medal.label),
          ),
        ),
      ),
    );
  }
}
