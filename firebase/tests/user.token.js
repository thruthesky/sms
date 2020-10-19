const firebase = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, otherUid } = require("./helper");
const tokenId = "token-1";

describe("User Push Notification Token", () => {
  it("Add token on other's account should failed", async () => {
    const db = await setup(myAuth);
    const tokenDoc = db
      .collection("users")
      .doc(otherUid)
      .collection("tokens")
      .doc(tokenId);
    await firebase.assertFails(tokenDoc.set({ token: tokenId }));
  });
  it("Add token should success", async () => {
    const db = await setup(myAuth);
    const tokenDoc = db
      .collection("users")
      .doc(myUid)
      .collection("tokens")
      .doc(tokenId);
    await firebase.assertSucceeds(tokenDoc.set({ token: tokenId }));
  });
  it("Read token should success", async () => {
    const db = await setup();
    const tokenDoc = db
      .collection("users")
      .doc(otherUid)
      .collection("tokens")
      .doc("it-will-pass-since-token-is-redable");
    await firebase.assertSucceeds(tokenDoc.get());
  });
});
