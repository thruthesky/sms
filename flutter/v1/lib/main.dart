import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/link.dart';
import 'package:v1/screens/admin/admin.category.screen.dart';
import 'package:v1/screens/admin/admin.push-notification.dart';
import 'package:v1/screens/admin/admin.screen.dart';
import 'package:v1/screens/forum/forum.view.screen.dart';
import 'package:v1/screens/mobile-auth/mobile_auth.screen.dart';
import 'package:v1/screens/mobile-auth/mobile_code_verification.screen.dart';
import 'package:v1/screens/search/search.screen.dart';

import 'package:v1/screens/settings/settings.screen.dart';

import 'package:v1/screens/forum/forum.edit.screen.dart';
import 'package:v1/screens/forum/forum.screen.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/translations.dart';
import 'package:v1/screens/home/home.screen.dart';
import 'package:v1/screens/login/login.screen.dart';
import 'package:v1/screens/profile/profile.screen.dart';
import 'package:v1/screens/register/register.screen.dart';
import 'package:v1/services/route_names.dart';

import 'package:get/route_manager.dart';
import 'package:get/get.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Map<String, Map<String, dynamic>> stack = {};

  @override
  void initState() {
    super.initState();

    ff.init(
      enableNotification: true,
      pushNotificationSound: "caralarm",
      firebaseServerToken:
          'AAAAjdyAvbM:APA91bGist2NNTrrKTZElMzrNV0rpBLV7Nn674NRow-uyjG1-Uhh5wGQWyQEmy85Rcs0wlEpYT2uFJrSnlZywLzP1hkdx32FKiPJMI38evdRZO0x1vBJLc-cukMqZBKytzb3mzRfmrgL',
      settings: {
        "forum": {
          "no-of-posts-per-fetch": 10,
          "like": true,
          "dislike": true,
        },
        "app": {
          "show-phone-verification-after-login": true,
          "create-phone-verified-user-only": true,
        }
      },
      translations: translations,
    );

    KakaoContext.clientId = 'f2ab9c07815d4cf099a5e8b4d82398d4';
    KakaoContext.javascriptClientId = '2cdb6b324434311d304ab3f367f9edf3';

    Service.initLocale().then((value) => Get.updateLocale(Locale(value)));

    /// Settings changed.
    ///
    /// App may needs to re-initialize based on settings change.
    // print(ff.appSetting());
    ff.settingsChange.listen((settings) {
      // print(ff.appSetting());
      setState(() {}); // You may re-render the screen if you wish.
    });
    ff.translationsChange.listen(
        (translations) => setState(() => updateTranslations(translations)));

    ff.notification.listen(
      (x) {
        Map<String, dynamic> notification = x['notification'];
        Map<dynamic, dynamic> data = x['data'];
        NotificationType type = x['type'];
        print('NotificationType: $type');
        print('notification: $notification');
        print('data: $data');
        if (type == NotificationType.onMessage) {
          Get.snackbar(
            notification['title'].toString(),
            notification['body'].toString(),
            onTap: (_) {
              Get.toNamed(data['screen'], arguments: {'id': data['id']});
            },
            mainButton: FlatButton(
              child: Text('Open'),
              onPressed: () {
                Get.toNamed(data['screen'], arguments: {'id': data['id']});
              },
            ),
          );
        } else {
          /// App will come here when the user open the app by tapping a push notification on the system tray.
          if (data != null && data['screen'] != null) {
            Get.toNamed(data['screen'],
                arguments: {'id': data['id'], 'data': data});
          }
        }
      },
    );

    // Timer(Duration(milliseconds: 300),
    //     () => Get.toNamed('forum', arguments: {'category': 'qna'}));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS Version 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: Locale('ko'),
      translations: AppTranslations(),
      initialRoute: RouteNames.home,
      // routingCallback: AppRouter.observer,
      getPages: [
        GetPage(name: RouteNames.home, page: () => HomeScreen()),
        GetPage(name: RouteNames.login, page: () => LoginScreen()),
        GetPage(name: RouteNames.register, page: () => RegisterScreen()),
        GetPage(name: RouteNames.profile, page: () => ProfileScreen()),
        GetPage(name: RouteNames.settings, page: () => SettingsScreen()),
        GetPage(name: RouteNames.admin, page: () => AdminScreen()),
        GetPage(
            name: RouteNames.adminCategory, page: () => AdminCategoryScreen()),
        GetPage(
            name: RouteNames.adminPushNotification,
            page: () => AdminPushNotificationScreen()),
        GetPage(name: RouteNames.forum, page: () => ForumScreen()),
        GetPage(name: RouteNames.forumEdit, page: () => ForumEditScreen()),
        GetPage(name: RouteNames.forumView, page: () => ForumViewScreen()),
        GetPage(name: RouteNames.mobileAuth, page: () => MobileAuthScreen()),
        GetPage(
            name: RouteNames.mobileCodeVerification,
            page: () => MobileCodeVerificationScreen()),
        GetPage(name: RouteNames.search, page: () => SearchScreen())
      ],
    );
  }
}
