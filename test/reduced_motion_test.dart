import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/pages/drop_success_page.dart';
import 'package:mobile_apps_recan/widgets/typewriter_text.dart';
import 'package:mobile_apps_recan/widgets/typing_indicator.dart';

import 'support/screen.dart';

Widget _still(Widget child) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  testWidgets('the typing dots rest under reduced motion', (tester) async {
    await tester.pumpWidget(_still(const TypingIndicator()));

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a reply is shown whole under reduced motion', (tester) async {
    await tester.pumpWidget(
      _still(const TypewriterText(text: 'Halo dari ReCan', style: null)),
    );

    expect(find.text('Halo dari ReCan'), findsNWidgets(2));
  });

  testWidgets('no confetti under reduced motion', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(
      _still(
        const DropSuccessPage(
          stationName: 'Drop Station',
          summary: DropSessionSummary(cans: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final confetti = tester.widget<ConfettiWidget>(find.byType(ConfettiWidget));
    expect(
      confetti.confettiController.state,
      isNot(ConfettiControllerState.playing),
    );
  });
}
