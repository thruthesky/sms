"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
if (!admin.apps.length) {
  admin.initializeApp();
}
const firestore = admin.firestore();
exports.firestore = firestore;

const algoliasearch = require("algoliasearch");
const ALGOLIA_ID = "2P90MM35DW";
const ALGOLIA_ADMIN_KEY = "e511858133eed17717b2204a564c32c7";
const ALGOLIA_INDEX_NAME = "DEV_FORUM";
const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);

///////////////////////////////////////////////////////////////////////////////

function _decrease(n) {
  n--;
  if (n < 0) return 0;
  else return n;
}
async function doVotes(change) {
  const parentRef = change.after.ref.parent.parent;
  const snapshot = await parentRef.get();
  if (!snapshot.exists) {
    /// Error if post or comment does not exists.
    console.error("Document does not exists: ", parentRef.path);
    return;
  }
  const postData = snapshot.data();
  // console.log("snapshot", postData);
  if (postData.likes === undefined) postData.likes = 0;
  if (postData.dislikes === undefined) postData.dislikes = 0;

  const afterVoteData = change.after.data();
  const beforeVoteData = change.before.data();
  // if (beforeVoteData) console.log("beforeVoteData", beforeVoteData);
  // 처음 추천 하는 경우,
  if (!change.before.exists) {
    // console.log("=> vote docuemnt does not exists");
    if (afterVoteData.choice === "like") postData.likes++;
    else if (afterVoteData.choice === "dislike") postData.dislikes++;
    else {
      // 처음 추천인데, choice 값이 없거나, 공백이거나, 기타 like, dislike 가 아니면, 에러
      return;
    }
    // console.log("=> postData: ", postData);
    await parentRef.set(
      { likes: postData.likes, dislikes: postData.dislikes },
      { merge: true }
    );
  } else {
    // console.log("=> vote docuemnt exists");
    // 두번째 이상 추천 하는 경우,

    // 추천을 했는데, 추천 결과가 변경되지 않았으면,
    //  예를 들어, 추천을 했는데, 또 추천을 하면,
    //  그냥 리턴한다.
    //  왜? 보안과 관련된 문제가 아니면, 복잡한 코딩은 클라이언트에서 편하게 한다.
    if (beforeVoteData.choice === afterVoteData.choice) {
      return;

      // if (afterVoteData.choice == "like") {
      //   await change.after.ref.set({ choice: "" }, { merge: true });
      //   postData.likes = postData.likes - 1;
      //   if (postData.likes < 0) postData.likes = 0;
      //   await parentRef.set({ like: postData.likes }, { merge: true });
      // } else if (afterVoteData.choice == "dislike") {
      // } else {
      //   console.error("Choice must be like or likes");
      // }
    } else if (afterVoteData.choice === "") {
      // 추천을 한 후, 결과 값이 없으면(빈 문자열이면, 추천 취소) 해당 추천을 글에서 1 감소한다.
      const ch = beforeVoteData.choice;
      switch (ch) {
        case "like":
          await parentRef.set(
            { likes: admin.firestore.FieldValue.increment(-1) },
            { merge: true }
          );
          break;
        case "dislike":
          await parentRef.set(
            { dislikes: admin.firestore.FieldValue.increment(-1) },
            { merge: true }
          );
          break;
        default:
          /// {abc: 'def'} 와 같이 choice 가 없는 값이 들어오면, 여기에 온다.
          break;
      }
    } else {
      /// 이전 추천과 현재 추천이 서로 다른 경우,
      /// 예: 이전에 like 했는데 지금은 dislike 하는 경우, 또는 그 반대
      let likes;
      let dislikes;
      if (afterVoteData.choice === "like") {
        // likes = postData.likes + 1;
        /// If the previous vote was empty string(''), it means, there was no vote.
        /// So, no need to decrease counterpart.
        var data = {
          likes: admin.firestore.FieldValue.increment(1)
        };
        if (beforeVoteData.choice !== "")
          data["dislikes"] = admin.firestore.FieldValue.increment(-1);
        await parentRef.set(data, { merge: true });
      } else if (afterVoteData.choice === "dislike") {
        // dislikes = postData.dislikes + 1;
        /// If the previous vote was empty string(''), it means, there was no vote.
        /// So, no need to decrease counterpart.
        if (beforeVoteData.choice === "") likes = postData.likes;
        else likes = _decrease(postData.likes);

        var data = {
          dislikes: admin.firestore.FieldValue.increment(1)
        };
        if (beforeVoteData.choice !== "")
          data["likes"] = admin.firestore.FieldValue.increment(-1);
        await parentRef.set(data, { merge: true });
      } else {
        console.error("Choice mus tbe like or dislike");
        return;
      }
    }
  }
}
exports.voteOnPost = functions.firestore
  .document("/posts/{postId}/votes/{uid}")
  .onWrite(async (change, context) => {
    await doVotes(change);
  });

exports.voteOnComment = functions.firestore
  .document("/posts/{postId}/comments/{commentId}/votes/{uid}")
  .onWrite(async (change, context) => {
    await doVotes(change);
  });

///////////////////////////////////////////////////////////////////////////////
//
//
// 글 생성, 업데이트시 색인.
exports.onPostWrite = functions.firestore
  .document("/posts/{postId}")
  .onWrite((change, context) => {
    const note = change.after.data();

    // 글 경로 저장
    note.objectID = change.after.ref.path;

    // 색인
    const index = client.initIndex(ALGOLIA_INDEX_NAME);
    return index.saveObject(note);
  });

// 코멘트 생성, 업데이트시 식앤
exports.onCommentWrite = functions.firestore
  .document("/posts/{postId}/comments/{commentId}")
  .onWrite((change, context) => {
    const note = change.after.data();

    // 코멘트 경로 저장
    note.objectID = change.after.ref.path;

    // 색인
    const index = client.initIndex(ALGOLIA_INDEX_NAME);
    return index.saveObject(note);
  });
