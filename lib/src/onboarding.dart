/// A step in a one-time, first-run onboarding flow (rules explanation →
/// first interactive success), game-agnostic.
///
/// Extracted from `komovia_shogi`'s `OnboardingScreen` (its 3-page flow:
/// how pieces move → win condition → an interactive "capture a piece"
/// demo gated on actually doing it), which is the only concrete
/// implementation across the Komovia family so far — see the
/// `差分表_komovia各アプリ_vs_優先度A.md` competitive/gap-analysis finding
/// that every other app either has no onboarding at all (chess, go,
/// Reversia) or only a partial one, despite "shortest path to a first
/// success" being a value every app's own competitive-research doc
/// converged on independently.
///
/// Deliberately a plain Dart value class — like [Entitlement]/
/// `Friendship`, no Flutter dependency, since komovia_core stays
/// Flutter-free. Each app's own screen renders [title]/[body]/[icon] in
/// whatever widget it likes (a `PageView` page, a card, ...); what this
/// type and [OnboardingProgress] actually share across apps is the
/// *flow* behavior — step order, and gating advancement on a step that
/// needs a real interactive demo, not just a "next" tap — not any UI.
class OnboardingStep {
  /// Stable identifier for this step, used by [OnboardingProgress] to
  /// track completion (e.g. `'capture-demo'`). Not shown to the player.
  final String id;

  final String title;

  final String body;

  /// An icon identifier, framework-agnostic (not a Flutter `IconData`) —
  /// e.g. a Material icon's name (`'touch_app'`). `null` if this step
  /// has no icon. Each app's screen maps this to its own icon lookup.
  final String? icon;

  /// Whether this step requires the app to explicitly mark it complete
  /// (via [OnboardingProgress.markStepCompleted]) before the flow can
  /// advance past it — e.g. a real interactive demo (capture a piece,
  /// play a legal move), not a bare "next" tap. `false` for an ordinary
  /// explanation page.
  final bool requiresExplicitCompletion;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.body,
    this.icon,
    this.requiresExplicitCompletion = false,
  });
}

/// Progress through a fixed [OnboardingStep] flow: which step the player
/// is on, and which steps requiring explicit completion have received it.
///
/// Pure state with no UI/widget dependency — an app's screen (a
/// `PageView`, typically) reads [currentStep]/[canAdvance] to decide what
/// to render and whether its "next"/"はじめる" button is enabled, and
/// calls [markStepCompleted]/[advance] in response to the player's
/// actions. Immutable: every mutating method returns a new instance,
/// matching the `copyWith`-free pattern [Friendship]/[Entitlement] use
/// for their own small, rarely-changing state.
class OnboardingProgress {
  final List<OnboardingStep> steps;
  final int currentIndex;
  final Set<String> completedStepIds;

  const OnboardingProgress({
    required this.steps,
    this.currentIndex = 0,
    this.completedStepIds = const {},
  });

  /// The step the player is currently on. Only valid while
  /// [isFlowComplete] is false.
  OnboardingStep get currentStep => steps[currentIndex];

  bool get isLastStep => currentIndex == steps.length - 1;

  /// True once the player has advanced past the final step.
  bool get isFlowComplete => currentIndex >= steps.length;

  /// Whether [currentStep] can be advanced past right now: always true
  /// unless it [OnboardingStep.requiresExplicitCompletion] and hasn't
  /// received it yet (via [markStepCompleted]).
  bool get canAdvance {
    if (isFlowComplete) return false;
    final step = currentStep;
    return !step.requiresExplicitCompletion ||
        completedStepIds.contains(step.id);
  }

  /// Marks the step with [stepId] as explicitly completed (e.g. after a
  /// real interactive demo succeeds). Marking a step other than the
  /// current one is allowed (harmless) but has no visible effect unless
  /// the player later returns to it.
  OnboardingProgress markStepCompleted(String stepId) {
    return OnboardingProgress(
      steps: steps,
      currentIndex: currentIndex,
      completedStepIds: {...completedStepIds, stepId},
    );
  }

  /// Advances to the next step (or past the last one, making
  /// [isFlowComplete] true).
  ///
  /// Throws a [StateError] if [canAdvance] is false — callers should gate
  /// their "next"/"はじめる" button on [canAdvance] rather than relying
  /// on this to silently no-op, the same way `ShogiGame.apply` throws on
  /// an illegal move rather than ignoring it.
  OnboardingProgress advance() {
    if (!canAdvance) {
      throw StateError(
        'Cannot advance past step "${currentStep.id}": it requires '
        'explicit completion first (see OnboardingStep.'
        'requiresExplicitCompletion).',
      );
    }
    return OnboardingProgress(
      steps: steps,
      currentIndex: currentIndex + 1,
      completedStepIds: completedStepIds,
    );
  }
}
