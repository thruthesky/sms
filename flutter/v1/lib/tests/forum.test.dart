import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/functions.dart';
import 'package:get/get.dart';
import 'package:v1/services/models.dart';

class ForumTest {
  final user = Get.find<UserController>();
  bool ran = false;
  log(msg) {
    print("[ Log ]\t$msg");
  }

  runAncestorTest() {
    final post = PostModel.fromDocument({});

    final orders = [
      ['a', '999999.999.999.999.999.999.999.999.999.999.999.999'],
      ['aa', '999999.998.999.999.999.999.999.999.999.999.999.999'],
      ['aaa', '999999.998.998.999.999.999.999.999.999.999.999.999'],
      ['b', '999998.999.999.999.999.999.999.999.999.999.999.999'],
      ['ba', '999998.998.999.999.999.999.999.999.999.999.999.999'],
      ['baa', '999998.998.998.999.999.999.999.999.999.999.999.999'],
      ['baaa', '999998.998.998.998.999.999.999.999.999.999.999.999'],
      ['baaaa', '999998.998.998.998.998.999.999.999.999.999.999.999'],
      ['baaab', '999998.998.998.998.997.999.999.999.999.999.999.999'],
      ['baaaba', '999998.998.998.998.997.998.999.999.999.999.999.999'],
      ['baaac', '999998.998.998.998.996.999.999.999.999.999.999.999'],
      ['baab', '999998.998.998.997.999.999.999.999.999.999.999.999'],
      ['bab', '999998.998.997.999.999.999.999.999.999.999.999.999'],
      ['bb', '999998.997.999.999.999.999.999.999.999.999.999.999'],
      ['bba', '999998.997.998.999.999.999.999.999.999.999.999.999'],
      ['bbaa', '999998.997.998.998.999.999.999.999.999.999.999.999'],
      ['bbab', '999998.997.998.997.999.999.999.999.999.999.999.999'],
      ['bbac', '999998.997.998.996.999.999.999.999.999.999.999.999'],
      ['bbaca', '999998.997.998.996.998.999.999.999.999.999.999.999'],
      ['bbacaa', '999998.997.998.996.998.998.999.999.999.999.999.999'],
      ['bbacaaa', '999998.997.998.996.998.998.998.999.999.999.999.999'],
      ['bbad', '999998.997.998.995.999.999.999.999.999.999.999.999'],
      ['bc', '999998.996.999.999.999.999.999.999.999.999.999.999'],
      ['bcd', '999998.996.998.999.999.999.999.999.999.999.999.999'],
      ['bcde', '999998.996.998.998.999.999.999.999.999.999.999.999'],
      ['bcdef', '999998.996.998.998.998.999.999.999.999.999.999.999'],
      ['bcdefg', '999998.996.998.998.998.998.999.999.999.999.999.999'],
      ['bcdefgh', '999998.996.998.998.998.998.998.999.999.999.999.999'],
      ['bcdefghi', '999998.996.998.998.998.998.998.998.999.999.999.999'],
      ['c', '999997.999.999.999.999.999.999.999.999.999.999.999'],
      ['d', '999996.999.999.999.999.999.999.999.999.999.999.999'],
      ['e', '999995.999.999.999.999.999.999.999.999.999.999.999'],
      ['f', '999994.999.999.999.999.999.999.999.999.999.999.999'],
      ['fa', '999994.998.999.999.999.999.999.999.999.999.999.999'],
    ];

    orders.forEach(
      (element) {
        post.comments.add(
          CommentModel.fromDocument(
            {
              'content': element[0],
              'order': element[1],
            },
          ),
        );
      },
    );

    var a0 = getAncestors(
        post.comments, '999997.999.999.999.999.999.999.999.999.999.999.999');
    print('ancestors');
    print(a0);

    var a1 = getAncestors(
        post.comments, '999999.998.999.999.999.999.999.999.999.999.999.999');
    print('ancestors');
    print(a1);

    var a2 = getAncestors(
        post.comments, '999998.998.998.998.997.999.999.999.999.999.999.999');

    print('ancestors. a2: ');
    print(a2);

    var a3 = getAncestors(
        post.comments, '999998.998.998.998.997.998.999.999.999.999.999.999');
    for (var o in a3) print(o);

    var a4 = getAncestors(
        post.comments, '999994.998.999.999.999.999.999.999.999.999.999.999');
    for (var o in a4) print(o);
    var a5 = getAncestors(
        post.comments, '999998.997.998.996.998.998.998.999.999.999.999.999');
    for (var o in a5) print(o);
    var a6 = getAncestors(
        post.comments, '999998.996.998.998.998.998.998.998.999.999.999.999');
    for (var o in a6) print(o);

    //
  }

  runOrderTest() async {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        log('@exit. login first');
      } else {
        if (ran) return;
        _testGetOrders();
        ran = true;
      }
    });
  }

  _testGetOrders() async {
    log('Begin ForumTest');

    final postsCol = postsCollection();
    final postData = {
      'uid': user.uid,
      'category': 'qna',
      'title': 'title',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final commentA = {
      'uid': user.uid,
      'content': 'a',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder()
    };
    print(postData);
    final doc = await postsCol.add(postData);
    final commentsCol = doc.collection('comments');
    print('commentA: $commentA');
    final a = await commentsCol.add(commentA);

    final commentB = {
      'uid': user.uid,
      'content': 'b',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder(order: commentA['order'], depth: 0),
    };
    print('commentB: $commentB');
    final b = await commentsCol.add(commentB);

    final commentC = {
      'uid': user.uid,
      'content': 'c',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder(order: commentB['order'], depth: 0),
    };
    print('commentC: $commentC');
    final c = await commentsCol.add(commentC);

    final commentBA = {
      'uid': user.uid,
      'content': 'ba',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentB['depth'] + 1,
      'order': getCommentOrder(
          order: commentB['order'], depth: commentB['depth'] + 1),
    };
    print('commentBA: $commentBA');
    final ba = await commentsCol.add(commentBA);

    final commentBB = {
      'uid': user.uid,
      'content': 'bb',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentB['depth'] + 1,
      'order': getCommentOrder(
          order: commentBA['order'], depth: commentB['depth'] + 1),
    };
    print('commentBB: $commentBB');
    final bb = await commentsCol.add(commentBB);

    final commentD = {
      'uid': user.uid,
      'content': 'd',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder(order: commentC['order'], depth: 0),
    };
    print('commentD: $commentD');
    final d = await commentsCol.add(commentD);

    final commentE = {
      'uid': user.uid,
      'content': 'e',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder(order: commentD['order'], depth: 0),
    };
    print('commentE: $commentE');
    final e = await commentsCol.add(commentE);

    final commentAA = {
      'uid': user.uid,
      'content': 'aa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentA['depth'] + 1,
      'order': getCommentOrder(
          order: commentA['order'], depth: commentA['depth'] + 1),
    };
    print('commentAA: $commentAA');
    final aa = await commentsCol.add(commentAA);

    final commentAAA = {
      'uid': user.uid,
      'content': 'aaa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentAA['depth'] + 1,
      'order': getCommentOrder(
          order: commentAA['order'], depth: commentAA['depth'] + 1),
    };
    print('commentAAA: $commentAAA');
    final aaa = await commentsCol.add(commentAAA);

    final commentF = {
      'uid': user.uid,
      'content': 'f',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': 0,
      'order': getCommentOrder(order: commentE['order'], depth: 0),
    };
    print('commentF: $commentF');
    final f = await commentsCol.add(commentF);

    final commentBAA = {
      'uid': user.uid,
      'content': 'baa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBA['order'], depth: commentBA['depth'] + 1),
    };
    print('commentBAA: $commentBAA');
    final baa = await commentsCol.add(commentBAA);

    final commentBAB = {
      'uid': user.uid,
      'content': 'bab',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBAA['order'], depth: commentBA['depth'] + 1),
    };
    print('commentBAB: $commentBAB');
    final bab = await commentsCol.add(commentBAB);

    final commentFA = {
      'uid': user.uid,
      'content': 'fa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentF['depth'] + 1,
      'order': getCommentOrder(
          order: commentF['order'], depth: commentF['depth'] + 1),
    };
    print('commentFA: $commentFA');
    final fa = await commentsCol.add(commentFA);

    final commentBAAA = {
      'uid': user.uid,
      'content': 'baaa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBAA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBAA['order'], depth: commentBAA['depth'] + 1),
    };
    print('commentBAAA: $commentBAAA');
    final baaa = await commentsCol.add(commentBAAA);

    final commentBAAAA = {
      'uid': user.uid,
      'content': 'baaaa',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBAAA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBAAA['order'], depth: commentBAAA['depth'] + 1),
    };
    print('commentBAAAA: $commentBAAAA');
    final baaaa = await commentsCol.add(commentBAAAA);

    final commentBAAB = {
      'uid': user.uid,
      'content': 'baab',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBAA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBAAA['order'], depth: commentBAA['depth'] + 1),
    };
    print('commentBAAB: $commentBAAB');
    final baab = await commentsCol.add(commentBAAB);

    final commentBAAAB = {
      'uid': user.uid,
      'content': 'baaab',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentBAAA['depth'] + 1,
      'order': getCommentOrder(
          order: commentBAAAA['order'], depth: commentBAAA['depth'] + 1),
    };
    print('commentBAAAB: $commentBAAAB');
    final baaab = await commentsCol.add(commentBAAAB);

    final commentBC = {
      'uid': user.uid,
      'content': 'bc',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'depth': commentB['depth'] + 1,
      'order': getCommentOrder(
          order: commentBB['order'], depth: commentB['depth'] + 1),
    };
    print('commentBC: $commentBC');
    final bc = await commentsCol.add(commentBC);

    List<String> expects = [
      'a',
      'aa',
      'aaa',
      'b',
      'ba',
      'baa',
      'baaa',
      'baaaa',
      'baaab',
      'baab',
      'bab',
      'bb',
      'bc',
      'c',
      'd',
      'e',
      'f',
      'fa',
    ];

    final snapshots =
        await commentsCol.orderBy('order', descending: true).get();
    // snapshots.docs.forEach((DocumentSnapshot comment) {
    //   String content = comment['content'];
    //   print("$content\t${comment['order']}");
    // });
    String re = '';
    map(snapshots.docs, (i, DocumentSnapshot comment) {
      String content = comment['content'];

      if (expects[i] == content) {
        re = re + 'O ';
      } else {
        re = re + 'X($content) ';
      }
    });
    print(re);
    map(snapshots.docs, (i, DocumentSnapshot comment) {
      String content = comment['content'];
      print("['$content', '${comment['order']}'],");
    });
  }
}
