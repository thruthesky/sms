import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // check permissions when app is resumed
  // this is when permissions are changed in app settings outside of app
  //
  // [see](https://github.com/Baseflow/flutter-permission-handler/issues/247)
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // print('---> Does it come here?');

    /// If the app resumed(from background), check the status again.
    if (state == AppLifecycleState.resumed) {
      permission = await location.hasPermission();
      service = await location.instance.serviceEnabled();
      setState(() {});
    }
  }


  bool permission = false;
  bool service = false;
  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    () async {
      permission = await location.hasPermission();
      service = await location.instance.serviceEnabled();
      setState(() {});
    }();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('app name'.tr),
        showBackButton: false,
      ),
      endDrawer: CommonAppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                  stream: ff.userChange,
                  builder: (context, snapshot) {
                    if (!ff.loggedIn) {
                      return Column(
                        children: [
                          RaisedButton(
                            onPressed: () => Get.toNamed(RouteNames.login),
                            child: Text('Login'),
                          ),
                          RaisedButton(
                            onPressed: () => Get.toNamed(RouteNames.register),
                            child: Text('Register'),
                          ),
                        ],
                      );
                    }

                    /// when user logged in,
                    return Column(
                      children: [
                        Text('app_title'.tr),
                        Text("User Uid: ${ff.user.uid}"),
                        Text("User Email: ${ff.user.email}"),
                        Text("User Nickname: ${ff.user.displayName}"),
                        Text("User Gender: ${ff.userData['gender']}"),
                        Text("User Phone number: ${ff.user.phoneNumber}"),
                        Text("User PhotoUrl: ${ff.user.photoURL}"),
                        RaisedButton(
                          onPressed: () => Get.toNamed(RouteNames.profile),
                          child: Text('Profile'),
                        ),
                        RaisedButton(
                          onPressed: ff.logout,
                          child: Text('Logout'),
                        ),
                        RaisedButton(
                          onPressed: () => Get.toNamed(RouteNames.settings),
                          child: Text('Settings'),
                        ),
                        RaisedButton(
                          onPressed: () => Get.toNamed(RouteNames.usersNearMe),
                          child: Text('Who\'s Near Me?'),
                        ),
                      ],
                    );
                  }),
              RaisedButton(
                onPressed: () async {
                  // ff.usersCol
                  //     .doc(ff.user.uid)
                  //     .collection('meta')
                  //     .doc('tokens')
                  //     .snapshots()
                  //     .listen((DocumentSnapshot document) {
                  //   List<String> tokens = [];
                  //   print(document.id);
                  //   tokens.add(document.id);
                  // print(tokens);

                  ff.sendNotification(
                    'Sample push notification to topic',
                    'This is the content of this sample push notification',
                    screen: '/home',
                    topic: ff.allTopic,
                    test: true,
                  );

                  // ff.sendNotification(
                  //   'test title message only',
                  //   'test body message, from test notification button.',
                  //   // token: ff.firebaseMessagingToken,
                  //   // tokens: tokens,
                  //   id: '0X1upoaLklWc2Z07dsbn',
                  //   screen: '/forumView',
                  //   topic: ff.allTopic,
                  // );
                  // });
                },
                child: Text('Send Test Notification'),
              ),
              RaisedButton(
                onPressed: () => Get.toNamed(RouteNames.admin),
                child: Text('Admin Screen'),
              ),
              RaisedButton(
                onPressed: () => Get.toNamed(
                  RouteNames.forum,
                  arguments: {'category': 'qna'},
                ),
                child: Text('QNA'),
              ),
              Text('Location Service: ' + (service ? 'ON' : 'OFF')),
              Text('Location Permission: ' + (permission ? 'ON' : 'OFF')),
            ],
          ),
        ),
      ),
    );
  }
}
