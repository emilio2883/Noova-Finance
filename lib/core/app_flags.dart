/// Lightweight session-level flags cached at startup so the synchronous
/// GoRouter redirect can read them without awaiting settings.
class AppFlags {
  AppFlags._();
  // Default true so widget tests (which don't run main) skip onboarding;
  // main() overwrites this from persisted settings.
  static bool onboardingDone = true;
}
