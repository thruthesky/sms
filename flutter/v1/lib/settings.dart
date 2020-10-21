class Settings {
  static String defaultLanguage = 'en';
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
  static String firebaseServerToken =
      'AAAAjdyAvbM:APA91bGist2NNTrrKTZElMzrNV0rpBLV7Nn674NRow-uyjG1-Uhh5wGQWyQEmy85Rcs0wlEpYT2uFJrSnlZywLzP1hkdx32FKiPJMI38evdRZO0x1vBJLc-cukMqZBKytzb3mzRfmrgL';
}
