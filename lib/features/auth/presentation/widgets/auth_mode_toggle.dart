import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

enum AuthMode {
  login,
  register;

  String get label => switch (this) {
    login => tr('Masuk', 'Login'),
    register => tr('Daftar', 'Sign Up'),
  };
}

/// Segmented control whose thumb slides between sign-in and sign-up.
class AuthModeToggle extends StatelessWidget {
  const new({
    required this.mode,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: SegmentedStyle.track(context),
      height: SegmentedStyle.height + 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Thumb(mode: mode),
          _Options(mode: mode, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const new({required this.mode, required this.onChanged});

  final AuthMode mode;

  /// Null while the toggle is locked.
  final ValueChanged<AuthMode>? onChanged;

  VoidCallback? _choose(AuthMode option) {
    final change = onChanged;
    if (change == null || option == mode) return null;
    return () {
      Haptics.selection();
      change(option);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in AuthMode.values)
          Expanded(
            child: _Option(
              key: ValueKey('auth-tab-${option.name}'),
              label: option.label,
              selected: option == mode,
              onTap: _choose(option),
            ),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const new({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return AnimatedAlign(
      duration: still ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: mode == AuthMode.login
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 1,
        child: DecoratedBox(decoration: SegmentedStyle.thumb(context)),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: SegmentedStyle.splashRadius,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SegmentedStyle.label(context, active: selected),
          ),
        ),
      ),
    );
  }
}
