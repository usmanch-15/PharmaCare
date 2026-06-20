/// App-wide theme preference.
///
/// - [light]  — always use the light color scheme.
/// - [dark]   — always use the dark color scheme.
/// - [system] — follow the device's OS-level theme setting.
///
/// Persisted as a plain string ("light" / "dark" / "system") in
/// local storage (SharedPreferences) — see ThemeLocalDataSource.
enum AppThemeMode {
  light('Light', 'light'),
  dark('Dark', 'dark'),
  system('System default', 'system');

  const AppThemeMode(this.label, this.storageKey);

  /// Human-readable label shown in the theme selector UI.
  final String label;

  /// Value persisted to local storage.
  final String storageKey;

  /// Parses a stored string back into [AppThemeMode].
  /// Defaults to [system] if the value is missing or unrecognized,
  /// so a fresh install always starts by following the OS theme.
  static AppThemeMode fromStorageKey(String? key) {
    return AppThemeMode.values.firstWhere(
      (e) => e.storageKey == key,
      orElse: () => AppThemeMode.system,
    );
  }
}