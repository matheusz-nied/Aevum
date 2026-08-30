import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static const _onboardingKey = 'aevum.onboarding.completed';

  final SharedPreferences _preferences;

  bool get onboardingCompleted => _preferences.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _preferences.setBool(_onboardingKey, value);

  Future<void> reset() => _preferences.clear();
}
