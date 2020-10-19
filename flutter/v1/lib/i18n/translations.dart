import 'package:get/get.dart';

class AppTranslations extends Translations {
  Map<String, Map<String, String>> get keys => {
        'en': {
          'version': 'Version',
          'home': 'Home',
          'yes': 'Yes',
          'no': 'No',
        },
        'ko': {
          'version': '버전',
          'home': '홈',
          'yes': '예',
          'no': '아니오',
        },
      };
}
