import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class UserController extends GetxController {
  User user;
  Map<String, dynamic> userData = {};

  bool get isLoggedIn {
    return user != null;
  }

  bool get isNotLoggedIn {
    return !isLoggedIn;
  }

  bool get isAdmin {
    if (isNotLoggedIn) return false;
    if (userData['isAdmin'] == null) return false;
    return userData['isAdmin'];
  }

  String get uid {
    return user?.uid;
  }

  String get displayName {
    return user?.displayName;
  }

  String get photoUrl {
    return user?.photoURL;
  }

  /// Returns the user document.
  ///
  /// Becarefult to call this method after the user has logged in (`user` must not  be null).
  DocumentReference get myDocument {
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  /// Returns promise of the login user's document.
  ///
  /// Becarefult to call this method after the user has logged in (`user` must not  be null).
  Future<DocumentSnapshot> getMyDocument() {
    return myDocument.get();
  }

  @override
  void onInit() {
    /// authStateChanges() firebase twcie on boot. This seems to be normal.
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      this.user = user;
      if (user == null) {
        userData = null;
      } else {
        myDocument.snapshots().listen((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            userData = snapshot.data();
            print('userData: ');
            print(userData);
            update();
          }
        });
        // getMyDocument().then((DocumentSnapshot snapshot) {
        //   if (snapshot.exists) {
        //     userData = snapshot.data();
        //   }
        // });

      }
      update();
    });

    super.onInit();
  }

  reload() async {
    await user.reload();
    user = FirebaseAuth.instance.currentUser;
    update();
  }
}
