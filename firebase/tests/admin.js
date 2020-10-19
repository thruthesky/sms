const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { setup } = require("./helper");

describe("Admin Test", () => {
  


  it("fail on editing 'isAdmin' property by a user", async () => {
    /// 저장된 도큐먼트 ID 가 `a-user-uid`
    const mockData = {
        "users/a-user-uid": {
            displayName: "user-name",
            isAdmin: false,
        },
    };
    /// 로그인은 `thruthesky` 로 함.
    const mockUser = {
        uid: "a-user-uid",
    };
    const db = await setup(mockUser, mockData);
    usersCol = db.collection('users');
    await assertSucceeds(usersCol.doc(mockUser.uid).update({ birthday: 731016 }));
    await assertFails(usersCol.doc(mockUser.uid).update({ isAdmin: true }));
  });


  it("fail on editing 'isAdmin' property by admin", async () => {
      /// 저장된 도큐먼트 ID 가 `a-user-uid`
      const mockData = {
          "users/a-user-uid": {
              displayName: "user-name",
              isAdmin: true,
          },
      };
      /// 로그인은 `thruthesky` 로 함.
      const mockUser = {
          uid: "a-user-uid",
      };
      const db = await setup(mockUser, mockData);
      usersCol = db.collection('users');
      await assertSucceeds(usersCol.doc(mockUser.uid).update({ birthday: 731016 }));
      await assertSucceeds(usersCol.doc(mockUser.uid).update({ isAdmin: true }));
  });



});
