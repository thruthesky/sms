const firebase = require("@firebase/rules-unit-testing");
const assert = require("assert");
const { setup, myAuth, myUid, yourUid } = require("./helper");

describe("User", () => {
  it("Create user doc without login", async () => {
    const db = await setup();
    await firebase.assertFails(db.collection("users").add({}));
  });

  it("Create user doc on other user id", async () => {
    const db = await setup(myAuth);
    await firebase.assertFails(
      db.collection("users").doc(yourUid).set({
        data: "something"
      })
    );
  });

  it("Create user doc with login", async () => {
    const db = await setup(myAuth);
    await firebase.assertSucceeds(
      db.collection("users").doc(myUid).set({
        data: "something"
      })
    );
  });

  it("Update on my doc", async () => {
    const db = await setup(myAuth, {
      ["users/" + myUid]: {
        displayName: "displayName"
      }
    });
    usersCol = db.collection("users");
    await firebase.assertSucceeds(
      usersCol.doc(myUid).update({ data: "something" })
    );
  });

  it("Update on other's doc", async () => {
    const db = await setup(myAuth, {
      ["users/" + yourUid]: {
        displayName: "displayName"
      }
    });
    usersCol = db.collection("users");
    await firebase.assertFails(
      usersCol.doc(yourUid).update({ data: "something" })
    );
  });
});
