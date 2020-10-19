import 'package:get/get.dart';

Map<String, Map<String, String>> translations = {
  'home': {'en': 'Home', 'ko': '홈'},
  'menu': {'en': 'Menu', 'ko': '메뉴'}
};

Map<String, Map<String, String>> _keys = {};

/// Convert `translations` json text into `GetX locale format`.
convertJsonToTranslationFormat() {
  translations.forEach((code, value) {
    for (var ln in value.keys) {
      if (_keys[ln] == null) _keys[ln] = {};
      _keys[ln][code] = value[ln];
    }
  });
}

/// Update `translations` from Firestore into `GetX local format`.
updateTranslation(String code, Map<String, dynamic> texts) {
  for (var ln in texts.keys) {
    if (_keys[ln] == null) _keys[ln] = {};
    _keys[ln][code] = texts[ln].toString();
  }
}

/// GetX locale text translations.
class AppTranslations extends Translations {
  AppTranslations() {
    convertJsonToTranslationFormat();
  }
  Map<String, Map<String, String>> get keys => _keys;
}
