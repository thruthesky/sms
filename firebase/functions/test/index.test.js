const chai = require("chai");
const assert = chai.assert;

const test = require("firebase-functions-test")(
  {
    databaseURL: "https://social-management-system.firebaseio.com",
    storageBucket: "ocial-management-system.appspot.com",
    projectId: "social-management-system"
  },
  "../service-account-key.json" //
);

const myFunctions = require("../index.js");
// 사용하기 간편하게, firestore 를 lib/index.js 의 것을 가져와서 사용한다.
const firestore = myFunctions.firestore;
const postPath = "/posts/a";
const postMyVotePath = postPath + "/votes/my-uid";
const postOtherVotePath = postPath + "/votes/other-uid";

const commentPath = "/posts/a/comments/b";
const commentMyVotePath = commentPath + "/votes/my-uid";
const commentOtherVotePath = commentPath + "/votes/other-uid";

// change 를 간편하게 만드는 함수
function makeChange(_path, _beforeSnap, _afterSnap) {
  const beforeSnap = test.firestore.makeDocumentSnapshot(_beforeSnap, _path);
  const afterSnap = test.firestore.makeDocumentSnapshot(_afterSnap, _path);
  const change = test.makeChange(beforeSnap, afterSnap);
  return change;
}

describe("vote", () => {
  it("post like and dislike", async () => {
    // 실제 Firestore 데이터베이스 초기화
    await firestore.doc(postMyVotePath).delete();
    await firestore.doc(postPath).set({});

    // Constructed Data
    const change = makeChange(postMyVotePath, {}, { choice: "like" });

    // Wrapped Function 으로 전달하는 값은, Firestore 데이터베이스에 기록되지 않는다.
    // 그래서, beforeSanp, afterSnap 을 통해서, 테스트를 한다.
    const wrapped = test.wrap(myFunctions.voteOnPost);
    await wrapped(change);

    // 글 도큐먼트에서 likes: 1 이 되었는지 검사
    let snapshot = await firestore.doc(postPath).get();
    // console.log("=> postPath: snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 1);

    // like 를 했는데 또 like 를 하면, 변함없다.
    await wrapped(
      makeChange(postMyVotePath, { choice: "like" }, { choice: "like" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 1); // 결과는 0 이 된다.

    // 다른 사용자가 like 1.
    await wrapped(makeChange(postOtherVotePath, {}, { choice: "like" }));
    snapshot = await firestore.doc(postPath).get();
    // console.log("snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 2); // 결과는 2 이 된다.

    // 나의 choice 를 빈 문자열로 지정. 추천 취소.
    // 기존의 like 또는 dislike 에 따라 글의 likes, dislikes 를 1 감소한다.
    await wrapped(
      makeChange(postMyVotePath, { choice: "like" }, { choice: "" })
    );
    snapshot = await firestore.doc(postPath).get();
    // console.log("snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 1);

    // 다른 사용자도 추천 취소.
    await wrapped(
      makeChange(postOtherVotePath, { choice: "like" }, { choice: "" })
    );
    snapshot = await firestore.doc(postPath).get();
    // console.log("snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 0);

    // 나의 dislike
    await wrapped(
      makeChange(postMyVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 dislike
    await wrapped(
      makeChange(postOtherVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 중복 dislike. 변화 없음.
    await wrapped(
      makeChange(
        postOtherVotePath,
        { choice: "dislike" },
        { choice: "dislike" }
      )
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 dislike 취소.
    await wrapped(
      makeChange(postOtherVotePath, { choice: "dislike" }, { choice: "" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 또 다시 dislike. 그래봐야 최대 1 증가 밖에 못시킴.
    await wrapped(
      makeChange(postOtherVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 choice 변경. dislike 에서 like 로 변경
    await wrapped(
      makeChange(postOtherVotePath, { choice: "dislike" }, { choice: "like" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 1);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 choice 변경. like 에서 dislike 로 변경
    await wrapped(
      makeChange(postOtherVotePath, { choice: "like" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(postPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);
  });

  it("comment like and dislike", async () => {
    // 실제 Firestore 데이터베이스 초기화
    await firestore.doc(commentMyVotePath).delete();
    await firestore.doc(commentPath).set({});

    // Constructed Data
    const change = makeChange(commentMyVotePath, {}, { choice: "like" });

    // Wrapped Function 으로 전달하는 값은, Firestore 데이터베이스에 기록되지 않는다.
    // 그래서, beforeSanp, afterSnap 을 통해서, 테스트를 한다.
    const wrapped = test.wrap(myFunctions.voteOnComment);
    await wrapped(change);

    // 코멘트 도큐먼트에서 likes: 1 이 되었는지 검사
    let snapshot = await firestore.doc(commentPath).get();
    // console.log("=> comment: snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 1);

    // like 를 했는데 또 like 를 하면, 변함없다.
    await wrapped(
      makeChange(commentMyVotePath, { choice: "like" }, { choice: "like" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 1); // 결과는 0 이 된다.

    // 다른 사용자가 like 1.
    await wrapped(makeChange(commentOtherVotePath, {}, { choice: "like" }));
    snapshot = await firestore.doc(commentPath).get();
    // console.log("snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 2); // 결과는 2 이 된다.

    // choice 를 빈 문자열로 지정
    // 기존의 like 또는 dislike 에 따라 글의 likes, dislikes 를 1 감소한다.
    await wrapped(
      makeChange(commentMyVotePath, { choice: "like" }, { choice: "" })
    );
    snapshot = await firestore.doc(commentPath).get();
    // console.log("snapshot: ", snapshot.data());
    assert.equal(snapshot.data().likes, 1);

    // 다른 사용자의 choice 도 동일하게 like 를 해서, likes 를 0으로 만든다.
    await wrapped(
      makeChange(commentOtherVotePath, { choice: "like" }, { choice: "" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);

    // 나의 dislike
    await wrapped(
      makeChange(commentMyVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 dislike
    await wrapped(
      makeChange(commentOtherVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 중복 dislike. 변화 없음.
    await wrapped(
      makeChange(
        commentOtherVotePath,
        { choice: "dislike" },
        { choice: "dislike" }
      )
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 dislike 취소.
    await wrapped(
      makeChange(commentOtherVotePath, { choice: "dislike" }, { choice: "" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 또 다시 dislike. 그래봐야 최대 1 증가 밖에 못시킴.
    await wrapped(
      makeChange(commentOtherVotePath, { choice: "" }, { choice: "dislike" })
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);

    // 다른 사용자의 choice 변경. dislike 에서 like 로 변경
    await wrapped(
      makeChange(
        commentOtherVotePath,
        { choice: "dislike" },
        { choice: "like" }
      )
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 1);
    assert.equal(snapshot.data().dislikes, 1);

    // 다른 사용자의 choice 변경. like 에서 dislike 로 변경
    await wrapped(
      makeChange(
        commentOtherVotePath,
        { choice: "like" },
        { choice: "dislike" }
      )
    );
    snapshot = await firestore.doc(commentPath).get();
    assert.equal(snapshot.data().likes, 0);
    assert.equal(snapshot.data().dislikes, 2);
  });
});
