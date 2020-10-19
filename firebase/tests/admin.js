const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, adminAuth } = require("./helper");

describe("Admin Test", () => {
  it("Editing 'isAdmin' property must be failed", async () => {
    ///
    ///
    const mockData = {
      ["users/" + myUid]: {
        displayName: "user-name",
        isAdmin: false
      }
    };
    const db = await setup(myAuth, mockData);
    usersCol = db.collection("users");
    await assertSucceeds(usersCol.doc(myUid).update({ birthday: 731016 }));
    await assertFails(usersCol.doc(myUid).update({ isAdmin: true }));
  });

  it("Edting 'isAdmin' property by admin must be failed", async () => {
    ///
    const mockData = {
      "users/a-user-uid": {
        displayName: "user-name",
        isAdmin: true
      }
    };
    const db = await setup(adminAuth, mockData);
    usersCol = db.collection("users");
    await assertFails(usersCol.doc(adminAuth.uid).update({ isAdmin: true }));
  });
});
