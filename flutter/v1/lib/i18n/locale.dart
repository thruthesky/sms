import 'package:devicelocale/devicelocale.dart';

/// 글 번역
///
class I18n {
  /// [locale]
  /// ``` dart
  /// I18n.locale;
  /// ```
  static String locale;

  /// [forceLocale] 이 값이 설정되어져 있으면, 해당 언어로만 표시를 한다.
  /// 예) 'en', 'ko'
  /// @example
  /// ``` dart
  /// I18n.forceLocale = 'ko';
  /// ```
  static String forceLocale;

  /// 앱이 부팅 될 때, 이 함수를 한번 호출 해 주어야 한다.
  static Future<String> init() async {
    // List languages = await Devicelocale.preferredLanguages;
    String current = await Devicelocale.currentLocale;
    locale = current.substring(0, 2);
    return locale;
  }
}
