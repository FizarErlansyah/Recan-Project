import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/tutorial/domain/can_tutorial.dart';
import 'package:mobile_apps_recan/features/tutorial/presentation/tutorial_step_view.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';

class CanTutorialPage extends StatefulWidget {
  const new({super.key});

  static void open(BuildContext context) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: const CanTutorialPage()));
  }

  @override
  State<CanTutorialPage> createState() => _CanTutorialPageState();
}

class _CanTutorialPageState extends State<CanTutorialPage> {
  static const Duration _turn = Duration(milliseconds: 300);

  final PageController _pages = PageController();
  int _index = 0;

  bool get _isLast => _index == CanTutorial.steps.length - 1;

  void _goTo(int index) {
    Haptics.selection();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: _turn,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = CanTutorial.steps.length;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Olah Kaleng', 'Craft With Cans'))),
      body: Column(
        children: [
          _Progress(index: _index, total: total),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: total,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (_, index) => TutorialStepView(
                step: CanTutorial.steps[index],
                number: index + 1,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _Controls(
        onBack: _index == 0 ? null : () => _goTo(_index - 1),
        onNext: _isLast
            ? () => Navigator.of(context).maybePop()
            : () => _goTo(_index + 1),
        isLast: _isLast,
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const new({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final step = index + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(child: _Segment(done: i <= index)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tr('Langkah $step dari $total', 'Step $step of $total'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const new({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final palette = context.palette;

    return AnimatedContainer(
      duration: still ? Duration.zero : const Duration(milliseconds: 260),
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: ShapeDecoration(
        color: done ? palette.accent : palette.border,
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const new({required this.onBack, required this.onNext, required this.isLast});

  /// Null on the first step.
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final back = onBack;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          if (back != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: back,
                child: Text(tr('Kembali', 'Back')),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: onNext,
              child: Text(
                isLast ? tr('Selesai', 'Done') : tr('Lanjut', 'Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
