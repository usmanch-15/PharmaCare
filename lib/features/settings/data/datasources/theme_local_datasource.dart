import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_theme_mode.dart';

abstract class ThemeLocalDataSource {
  /// Returns the saved storage key ("light"/"dark"/"system"), or null
  /// if nothing has been saved yet.
  Future<String?> getThemeMode();

  /// Persists the storage key and notifies any active watchers.
  Future<void> setThemeMode(String storageKey);

  /// Emits the current value immediately, then again on every change.
  Stream<String> watchThemeMode();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  ThemeLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// Key under which the theme preference is stored.
  static const _kThemeModeKey = 'theme_mode';

  /// Broadcast controller used to push live updates to [watchThemeMode].
  /// SharedPreferences has no native stream API, so we maintain our own.
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  @override
  Future<String?> getThemeMode() async {
    try {
      return _prefs.getString(_kThemeModeKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> setThemeMode(String storageKey) async {
    try {
      await _prefs.setString(_kThemeModeKey, storageKey);
      // Notify any active watchers (e.g. MaterialApp listening for
      // theme changes triggered from a different screen).
      _controller.add(storageKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Stream<String> watchThemeMode() async* {
    try {
      // Emit current value first so new listeners get the saved
      // preference immediately, before any future change occurs.
      final current = _prefs.getString(_kThemeModeKey) ??
          AppThemeMode.system.storageKey;
      yield current;
      yield* _controller.stream;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}