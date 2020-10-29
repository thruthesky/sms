import 'package:after_layout/after_layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/link.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/screens/admin/admin.category.screen.dart';
import 'package:v1/screens/admin/admin.push-notification.dart';
import 'package:v1/screens/admin/admin.screen.dart';

import 'package:v1/screens/settings/settings.screen.dart';

import 'package:v1/screens/forum/forum.edit.screen.dart';
import 'package:v1/screens/forum/forum.screen.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/translations.dart';
import 'package:v1/screens/home/home.screen.dart';
import 'package:v1/screens/login/login.screen.dart';
import 'package:v1/screens/profile/profile.screen.dart';
import 'package:v1/screens/register/register.screen.dart';
import 'package:v1/services/route-names.dart';

import 'package:get/route_manager.dart';
import 'package:get/get.dart';
import 'package:v1/services/service.dart';

void main() async {
  await ff.init(
    enableNotification: true,
    firebaseServerToken:
        'AAAAjdyAvbM:APA91bGist2NNTrrKTZElMzrNV0rpBLV7Nn674NRow-uyjG1-Uhh5wGQWyQEmy85Rcs0wlEpYT2uFJrSnlZywLzP1hkdx32FKiPJMI38evdRZO0x1vBJLc-cukMqZBKytzb3mzRfmrgL',
    notificationHandler: (Map<String, dynamic> notification,
        Map<String, dynamic> data, NotificationType type) {
      print('NotificationType: $type');
      print('notification: $notification');
      print('data: $data');
      if (type == NotificationType.onMessage) {
        Get.snackbar(
          notification['title'].toString(),
          notification['body'].toString(),
          onTap: (_) {
            Get.toNamed(data['route']);
          },
          mainButton: FlatButton(
            child: Text('Open'),
            onPressed: () {
              Get.toNamed(data['route']);
            },
          ),
        );
      } else {
        // TODO: Make it work.
        /// App will come here when the user open the app by tapping a push notification on the system tray.
        /// Do something based on the `data`.
        if (data != null && data['postId'] != null) {
          // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
        }
      }
    },
    // socialLoginSuccessHandler: (user) => Get.toNamed(RouteNames.home),
    // socialLoginErrorHandler: (e) => Service.error(e),
  );

  KakaoContext.clientId = 'f2ab9c07815d4cf099a5e8b4d82398d4';
  KakaoContext.javascriptClientId = '2cdb6b324434311d304ab3f367f9edf3';

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with AfterLayoutMixin<MainApp> {
  final c = Get.put(UserController());

  @override
  void initState() {
    super.initState();

    // Timer(Duration(milliseconds: 300),
    //     () => Get.toNamed('forum', arguments: {'category': 'qna'}));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    /// When locale translation text downloaded from Firestore, update the screen.
    Service.updateLocale(download: () => setState(() => null));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS Version 1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: Locale('ko'),
      translations: AppTranslations(),
      initialRoute: RouteNames.home,
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
        GetPage(name: RouteNames.forumEdit, page: () => ForumEditScreen())
      ],
    );
  }
}
