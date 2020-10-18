const firebase = require("@firebase/rules-unit-testing");
const assert = require("assert");
const { setup, myAuth, myUid } = require("./helper");

describe("Basic", () => {
  it("Read should success", async () => {
    const db = await setup();

    const testDoc = db.collection("readonlytest").doc("testDoc");

    await firebase.assertSucceeds(testDoc.get());
  });
  it("Write should fail", async () => {
    const db = await setup();
    const testDoc = db.collection("readonlytest").doc("testDoc");

    await firebase.assertFails(testDoc.set({ foo: "bar" })); // 실패 테스트
  });
  it("Write should fail", async () => {
    const db = await setup(myAuth);

    const testDoc = db.collection("readonlytest").doc(myUid);

    await firebase.assertSucceeds(testDoc.set({ foo: "bar" })); // 성공테스트
  });
  it("Read success on public doc", async () => {
    const db = await setup();
    const testQuery = db
      .collection("publictest")
      .where("visibility", "==", "public");
    await firebase.assertSucceeds(testQuery.get());
  });
  it("Read success on public doc", async () => {
    const db = await setup(myAuth);
    const testQuery = db.collection("publictest").where("uid", "==", myUid);
    await firebase.assertSucceeds(testQuery.get());
  });

  // 관리자 db instance 로 private 값을 미리 지정해서, 오류 테스트
  it("Read success on public doc", async () => {
    const db = await setup(null, {
      "publictest/privateDocId": {
        visibility: "private"
      },
      "publictest/publicDocId": {
        visibility: "public"
      }
    });
    let testQuery = db.collection("publictest").doc("privateDocId");
    await firebase.assertFails(testQuery.get());
    testQuery = db.collection("publictest").doc("publicDocId");
    await firebase.assertSucceeds(testQuery.get());
  });
});
