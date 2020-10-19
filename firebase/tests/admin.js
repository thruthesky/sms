const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, otherUid } = require("./helper");

describe("Admin Test", () => {
  


  it("fail on editing 'isAdmin' property by a user", async () => {
    /// 저장된 도큐먼트 ID 가 `a-user-uid`
    const mockData = {
        "users/a-user-uid": {
            displayName: "user-name",
            isAdmin: false,
        },
    };
    const db = await setup(myAuth, mockData);
    usersCol = db.collection('users');
    await assertSucceeds(usersCol.doc(myAuth.uid).update({ birthday: 731016 }));
    await assertFails(usersCol.doc(myAuth.uid).update({ isAdmin: true }));
  });


  it("fail on editing 'isAdmin' property by admin", async () => {
      /// 저장된 도큐먼트 ID 가 `a-user-uid`
      const mockData = {
          "users/a-user-uid": {
              displayName: "user-name",
              isAdmin: true,
          },
      };
      const db = await setup(myAuth, mockData);
      usersCol = db.collection('users');
      await assertSucceeds(usersCol.doc(myAuth.uid).update({ birthday: 731016 }));
      await assertSucceeds(usersCol.doc(myAuth.uid).update({ isAdmin: true }));
  });



});
