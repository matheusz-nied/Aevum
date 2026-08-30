class AppLinks {
  const AppLinks._();

  static const privacyPolicyUrl = String.fromEnvironment('AEVUM_PRIVACY_URL');
  static const sourceCodeUrl = String.fromEnvironment('AEVUM_SOURCE_URL');
  static const contactUrl = String.fromEnvironment('AEVUM_CONTACT_URL');
  static const supportUrl = String.fromEnvironment('AEVUM_SUPPORT_URL');

  static bool isConfigured(String value) => value.trim().isNotEmpty;
}
