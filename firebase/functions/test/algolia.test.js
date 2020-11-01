const chai = require("chai");
const assert = chai.assert;

const test = require("firebase-functions-test")(
  {
    databaseURL: "https://social-management-system.firebaseio.com",
    storageBucket: "ocial-management-system.appspot.com",
    projectId: "social-management-system"
  },
  "../firebase-service-account-key.json" //
);

const myFunctions = require("../index.js");

// change 를 간편하게 만드는 함수
function makeChange(_path, _beforeSnap, _afterSnap) {
  const beforeSnap = test.firestore.makeDocumentSnapshot(_beforeSnap, _path);
  const afterSnap = test.firestore.makeDocumentSnapshot(_afterSnap, _path);
  const change = test.makeChange(beforeSnap, afterSnap);
  return change;
}

describe("Algolia", () => {
  it("Create indexes", async () => {
    const wrapped = test.wrap(myFunctions.onPostWrite);
    await wrapped(
      makeChange(
        "/posts/abc",
        {},
        { title: "안녕하세요. 제목입니다.", content: "그리고 내용입니다." }
      )
    );

    await wrapped(
      makeChange(
        "/posts/abc",
        {},
        {
          title: "안녕하세요. 제목을 수정합니다.",
          content: "그리고 내용입니다."
        }
      )
    );

    await wrapped(
      makeChange(
        "/posts/apple",
        {},
        {
          title: "지연이랑 사과가 먹고 싶습니다.",
          content: "지연이가 보고 싶습니다. 은수도..."
        }
      )
    );

    await wrapped(
      makeChange(
        "/posts/abc/comments/def",
        {},
        {
          content: "코멘트 내용입니다. 경로 수정"
        }
      )
    );
  });
});
