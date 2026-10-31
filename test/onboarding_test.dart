import 'package:komovia_core/komovia_core.dart';
import 'package:test/test.dart';

void main() {
  group('OnboardingProgress', () {
    const steps = [
      OnboardingStep(id: 'rules-1', title: 'How pieces move', body: '...'),
      OnboardingStep(id: 'rules-2', title: 'Winning', body: '...'),
      OnboardingStep(
        id: 'capture-demo',
        title: 'Try it',
        body: '...',
        requiresExplicitCompletion: true,
      ),
    ];

    test('starts on the first step, not complete', () {
      final progress = OnboardingProgress(steps: steps);

      expect(progress.currentStep.id, 'rules-1');
      expect(progress.isLastStep, isFalse);
      expect(progress.isFlowComplete, isFalse);
    });

    test('an ordinary step can always be advanced past', () {
      final progress = OnboardingProgress(steps: steps);

      expect(progress.canAdvance, isTrue);
      final next = progress.advance();
      expect(next.currentStep.id, 'rules-2');
    });

    test(
        'a step requiring explicit completion cannot be advanced past until '
        'marked complete', () {
      var progress = OnboardingProgress(steps: steps, currentIndex: 2);

      expect(progress.currentStep.id, 'capture-demo');
      expect(progress.canAdvance, isFalse);

      progress = progress.markStepCompleted('capture-demo');

      expect(progress.canAdvance, isTrue);
    });

    test('advance() throws when canAdvance is false', () {
      final progress = OnboardingProgress(steps: steps, currentIndex: 2);

      expect(progress.canAdvance, isFalse);
      expect(() => progress.advance(), throwsStateError);
    });

    test('advancing past the last step marks the flow complete', () {
      var progress = OnboardingProgress(steps: steps, currentIndex: 1);
      progress = progress.advance(); // -> index 2, the demo step
      progress = progress.markStepCompleted('capture-demo');

      expect(progress.isLastStep, isTrue);
      expect(progress.isFlowComplete, isFalse);

      progress = progress.advance();

      expect(progress.isFlowComplete, isTrue);
    });

    test('marking a step other than the current one is harmless', () {
      final progress =
          OnboardingProgress(steps: steps).markStepCompleted('capture-demo');

      // Still on step 0, and step 0 never required completion anyway.
      expect(progress.currentStep.id, 'rules-1');
      expect(progress.canAdvance, isTrue);
      expect(progress.completedStepIds, contains('capture-demo'));
    });

    test(
        'completedStepIds accumulates across multiple markStepCompleted '
        'calls', () {
      var progress = OnboardingProgress(steps: steps);
      progress = progress.markStepCompleted('rules-1');
      progress = progress.markStepCompleted('capture-demo');

      expect(progress.completedStepIds, {'rules-1', 'capture-demo'});
    });
  });
}
