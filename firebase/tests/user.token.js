const firebase = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, otherUid } = require("./helper");
const tokenId = "token-1";

describe("User Push Notification Token", () => {
  // users/{uid}/meta/tokens

  it("users/{uid}/meta/tokens Add token on other's account should failed", async () => {
    const db = await setup(myAuth);
    const tokenDoc = db
      .collection("users")
      .doc(otherUid)
      .collection("meta")
      .doc("tokens");
    await firebase.assertFails(tokenDoc.set({ [tokenId]: true }));
  });

  it("Add token should success", async () => {
    const db = await setup(myAuth);
    const tokenDoc = db
      .collection("users")
      .doc(myUid)
      .collection("meta")
      .doc("tokens");
    await firebase.assertSucceeds(tokenDoc.set({ [tokenId]: true }));
  });
  it("Read token should success", async () => {
    const db = await setup();
    const tokenDoc = db
      .collection("users")
      .doc(otherUid)
      .collection("meta")
      .doc("tokens");
    await firebase.assertSucceeds(tokenDoc.get());
  });
});
