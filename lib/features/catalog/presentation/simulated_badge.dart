import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// Marks an order whose rupiah part no payment gateway has confirmed.
class SimulatedBadge extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.palette.goldSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tr('Simulasi', 'Simulated'),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.palette.goldText),
      ),
    );
  }
}
