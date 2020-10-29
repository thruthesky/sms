import 'package:get/get.dart';

/// Default texts.
///
/// This will be overwritten by the translations from Remote Config.
/// This may be useful When app boots for the first time and the translations
/// has not arrived from Remote Config.
Map<String, Map<String, String>> translations = {
  "en": {
    "app_title": "App Title",
    "home": "Home",
    "menu": "Menu",
  },
  "ko": {
    "app_title": "앱 제목",
    "home": "홈",
    "menu": "메뉴",
  },
};

/// This is the Object that will be
///
// Map<String, Map<String, String>> translations = {};

/// Convert `translations` json text into `GetX locale format`.
// convertJsonToTranslationFormat() {
//   translations.forEach((code, value) {
//     for (var ln in value.keys) {
//       if (translations[ln] == null) translations[ln] = {};
//       translations[ln][code] = value[ln];
//     }
//   });
// }

/// Update `translations` from Firestore into `GetX local format`.
updateTranslations(Map<String, dynamic> data) {
  print('updateTranslations() data: ');
  print(data);
  data.forEach((ln, texts) {
    for (var name in texts.keys) {
      translations[ln][name] = texts[name];
    }
  });
  print('updateTranslations() translations:');
  print(translations);
}

/// GetX locale text translations.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
