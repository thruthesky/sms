import 'package:v1/services/functions.dart';

class ForumTest {
  ForumTest() {
    run();
  }
  log(msg) {
    print("[ Log ]\t$msg");
  }

  run() {
    log('Begin ForumTest');

    final postsCol = postsCollection();
  }
}
