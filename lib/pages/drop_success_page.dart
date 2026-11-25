import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/animated_check.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class DropSuccessPage extends StatefulWidget {
  const new({required this.stationName, required this.summary, super.key});

  final String stationName;
  final DropSessionSummary summary;

  @override
  State<DropSuccessPage> createState() => _DropSuccessPageState();
}

class _DropSuccessPageState extends State<DropSuccessPage> {
  static const List<Color> _confettiColors = [
    AppColors.primarySoft,
    AppColors.primary,
    AppColors.goldLight,
    AppColors.white,
  ];

  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    unawaited(HapticFeedback.heavyImpact());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_celebrated) return;
    _celebrated = true;
    if (!MediaQuery.disableAnimationsOf(context)) _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            _Body(stationName: widget.stationName, summary: widget.summary),
            _Rain(controller: _confetti, colors: _confettiColors),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const new({required this.stationName, required this.summary});

  final String stationName;
  final DropSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: _Receipt(stationName: stationName, summary: summary),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _HomeButton(),
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primarySoft,
          foregroundColor: AppColors.primary,
        ),
        child: Text(
          tr('Kembali ke Beranda', 'Back to Home'),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _Rain extends StatelessWidget {
  const new({required this.controller, required this.colors});

  final ConfettiController controller;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        child: ConfettiWidget(
          confettiController: controller,
          blastDirection: pi / 2,
          emissionFrequency: 0.04,
          numberOfParticles: 18,
          maxBlastForce: 22,
          minBlastForce: 8,
          colors: colors,
        ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const new({required this.stationName, required this.summary});

  final String stationName;
  final DropSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        color: context.palette.surface,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primarySoft, context.palette.surface],
                ),
              ),
              child: Column(
                children: [
                  const AnimatedCheck(),
                  const SizedBox(height: 16),
                  Text(
                    tr('Setoran Berhasil', 'Deposit Successful'),
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(stationName, style: textTheme.bodySmall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  _DetailRow(
                    icon: AppIcons.recycle,
                    label: tr('Total Kaleng', 'Total Cans'),
                    value: '${summary.cans}',
                  ),
                  Divider(color: context.palette.border, height: 24),
                  _DetailRow(
                    icon: AppIcons.coins,
                    label: tr('Poin Didapat', 'Points Earned'),
                    value: '+${PointsHeader.formatNumber(summary.points)}',
                  ),
                  Divider(color: context.palette.border, height: 24),
                  _DetailRow(
                    icon: AppIcons.eco,
                    label: tr('Dampak Karbon', 'Carbon Impact'),
                    value: '-${summary.carbonKg.toStringAsFixed(2)} kg CO2',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const new({required this.icon, required this.label, required this.value});

  final IconGlyph icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        HugeIcon(icon: icon, size: 20, color: context.palette.accent),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
