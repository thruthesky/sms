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
    "qna": "QnA",
    "likes": "Likes",
    "dislikes": "Dislikes",
  },
  "ko": {
    "app_title": "앱 제목",
    "home": "홈",
    "menu": "메뉴",
    "qna": "질문게시판",
    "likes": "찬성",
    "dislikes": "반대",
  }
};

/// Update `translations` from Firestore into `GetX local format`.
updateTranslations(Map<dynamic, dynamic> data) {
  if (data == null) return;
  data.forEach((ln, texts) {
    for (var name in texts.keys) {
      translations[ln][name] = texts[name];
    }
  });
  // print('updated: translations');
  // print(translations);
}

/// GetX locale text translations.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
