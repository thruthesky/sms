class Settings {
  static String defaultLanguage = 'ko';
  static List<String> supportedLanguages = ['en', 'ko', 'ch', 'ja'];
  static bool changeUserLanguageOnBoot = false;
  static bool letUserChangeLanguage = true;

  static String allTopic = 'allTopic';

  /// When user take photo for his profile photo,
  ///
  /// max width of the profile photo
  static double profilePhotoMaxWidth = 128;

  /// jpeg image quality
  static int profilePhotoImageQuality = 80;
}
