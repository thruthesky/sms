"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
if (!admin.apps.length) {
  admin.initializeApp();
}
const firestore = admin.firestore();
exports.firestore = firestore;

function _decrease(n) {
  n--;
  if (n < 0) return 0;
  else return n;
}
async function doVotes(change) {
  const parentRef = change.after.ref.parent.parent;
  const postDoc = await parentRef.get();
  if (!postDoc.exists) {
    console.error("Document does not exists: ", parentRef.path);
    return; // 글이 존재하지 않으면, 에러
  }
  const postData = postDoc.data();
  // console.log("postDoc", postData);
  if (postData.likes == undefined) postData.likes = 0;
  if (postData.dislikes == undefined) postData.dislikes = 0;

  const afterVoteData = change.after.data();
  const beforeVoteData = change.before.data();
  // if (beforeVoteData) console.log("beforeVoteData", beforeVoteData);
  // 처음 추천 하는 경우,
  if (!change.before.exists) {
    // console.log("=> vote docuemnt does not exists");
    if (afterVoteData.choice == "like") postData.likes++;
    else if (afterVoteData.choice == "dislike") postData.dislikes++;
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
    if (beforeVoteData.choice == afterVoteData.choice) {
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
    } else if (afterVoteData.choice == "") {
      // 추천을 한 후, 결과 값이 없으면(빈 문자열이면, 추천 취소) 해당 추천을 글에서 1 감소한다.
      const ch = beforeVoteData.choice;
      switch (ch) {
        case "like":
          await parentRef.set(
            { likes: _decrease(postData.likes) },
            { merge: true }
          );
          break;
        case "dislike":
          await parentRef.set(
            { dislikes: _decrease(postData.dislikes) },
            { merge: true }
          );
          break;
        default:
          break;
      }
    } else {
      /// 이전 추천과 현재 추천이 서로 다른 경우,
      /// 예: 이전에 like 했는데 지금은 dislike 하는 경우, 또는 그 반대
      let likes;
      let dislikes;
      if (afterVoteData.choice == "like") {
        likes = postData.likes + 1;
        dislikes = _decrease(postData.dislikes);
      } else if (afterVoteData.choice == "dislike") {
        likes = _decrease(postData.likes);
        dislikes = postData.dislikes + 1;
        // console.log("==> dislikes: ", dislikes);
      } else {
        console.error("Choice mus tbe like or dislike");
        return;
      }

      await parentRef.set(
        {
          likes: likes,
          dislikes: dislikes
        },
        { merge: true }
      );
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
