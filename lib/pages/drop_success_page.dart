import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/animated_check.dart';
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

  @override
  void initState() {
    super.initState();
    unawaited(HapticFeedback.heavyImpact());
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: _Receipt(
                            stationName: widget.stationName,
                            summary: widget.summary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: AppColors.primarySoft,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(
                          tr('Kembali ke Beranda', 'Back to Home'),
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: pi / 2,
                  emissionFrequency: 0.04,
                  numberOfParticles: 18,
                  maxBlastForce: 22,
                  minBlastForce: 8,
                  colors: _confettiColors,
                ),
              ),
            ),
          ],
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
        color: AppColors.surface,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primarySoft, AppColors.surface],
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
                    icon: Icons.recycling_rounded,
                    label: tr('Total Kaleng', 'Total Cans'),
                    value: '${summary.cans}',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow(
                    icon: Icons.toll_rounded,
                    label: tr('Poin Didapat', 'Points Earned'),
                    value: '+${summary.points}',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow(
                    icon: Icons.eco_rounded,
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

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(value, style: textTheme.titleMedium),
      ],
    );
  }
}
