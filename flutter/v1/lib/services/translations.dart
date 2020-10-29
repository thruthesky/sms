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
    "qna": "QnA"
  },
  "ko": {
    "app_title": "앱 제목",
    "home": "홈",
    "menu": "메뉴",
    "qna": "질문게시판",
  }
};

/// Update `translations` from Firestore into `GetX local format`.
updateTranslations(Map<String, dynamic> data) {
  data.forEach((ln, texts) {
    for (var name in texts.keys) {
      translations[ln][name] = texts[name];
    }
  });
}

/// GetX locale text translations.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
