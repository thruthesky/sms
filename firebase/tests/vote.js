const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { firestore } = require("firebase-admin");
const { setup, myAuth, otherUid, otherAuth } = require("./helper");

const postId = "my-post-id";
const postMyVotePath = "/posts/" + postId + "/votes/" + myAuth.uid;
const postOtherVotePath = "/posts/" + postId + "/votes/" + otherUid;
const mockData = {
  ["posts/" + postId]: {
    uid: myAuth.uid,
    title: "title",
    content: "content",
    createdAt: 0,
    updatedAt: 0
  },
  [postOtherVotePath]: {
    choice: "dislike"
  },
  "categories/apple": {
    title: "Apple"
  }
};

/// Rules. @see firestore.rules
///
describe("Vote test on Post", () => {
  it("Voting on other uid", async () => {
    const db = await setup(myAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertFails(doc.set({ choice: "like" }));
  });

  it("Voting with empty string for the first time", async () => {
    const db = await setup(myAuth, mockData);
    const doc = db.doc(postMyVotePath);
    await assertFails(doc.set({ choice: "" }));
  });

  it("Voting like for the first time", async () => {
    const db = await setup(myAuth, mockData);
    const doc = db.doc(postMyVotePath);
    await assertSucceeds(doc.set({ choice: "like" }));
  });

  it("Voting dislike for the first time", async () => {
    const db = await setup(myAuth, mockData);
    const doc = db.doc(postMyVotePath);
    await assertSucceeds(doc.set({ choice: "dislike" }));
  });

  it("Voting empty string on existing vote", async () => {
    const db = await setup(otherAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertSucceeds(doc.set({ choice: "" }, { merge: true }));
  });
  it("Voting like on existing vote", async () => {
    const db = await setup(otherAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertSucceeds(doc.set({ choice: "like" }, { merge: true }));
  });
  it("Voting dislike again", async () => {
    const db = await setup(otherAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertFails(doc.set({ choice: "dislike" }, { merge: true }));
  });

  it("Voting with wrong choice", async () => {
    const db = await setup(myAuth, mockData);
    const doc = db.doc(postMyVotePath);
    await assertFails(doc.set({ choice: "li" }));
  });

  it("Voting empty string", async () => {
    const db = await setup(otherAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertSucceeds(doc.set({ choice: "" }, { merge: true }));
  });
  it("Voting empty string again must failed", async () => {
    const db = await setup(otherAuth, mockData);
    const doc = db.doc(postOtherVotePath);
    await assertSucceeds(doc.set({ choice: "" }, { merge: true }));
    await assertFails(doc.set({ choice: "" }, { merge: true }));
  });
});

const commentPath = "/posts/b/comments/c";
const commentMyVotePath = commentPath + "/votes/" + myAuth.uid;
const commentOtherVotePath = commentPath + "/votes/" + otherUid;
const commentMockData = {
  [commentPath]: {
    uid: myAuth.uid,
    content: "content",
    createdAt: 0,
    updatedAt: 0
  },
  [commentOtherVotePath]: {
    choice: "dislike"
  },
  "categories/apple": {
    title: "Apple"
  }
};

describe("Vote test on Comment", () => {
  it("Voting on other uid", async () => {
    const db = await setup(myAuth, commentMockData);
    const doc = db.doc(commentOtherVotePath);
    await assertFails(doc.set({ choice: "like" }));
  });

  it("Voting with empty string for the first time", async () => {
    const db = await setup(myAuth, commentMockData);
    const doc = db.doc(commentMyVotePath);
    await assertFails(doc.set({ choice: "" }));
  });

  it("Voting like for the first time", async () => {
    const db = await setup(myAuth, commentMockData);
    const doc = db.doc(commentMyVotePath);
    await assertSucceeds(doc.set({ choice: "like" }));
  });

  it("Voting dislike for the first time", async () => {
    const db = await setup(myAuth, commentMockData);
    const doc = db.doc(commentMyVotePath);
    await assertSucceeds(doc.set({ choice: "dislike" }));
  });

  it("Voting empty string on existing vote", async () => {
    const db = await setup(otherAuth, commentMockData);
    const doc = db.doc(commentOtherVotePath);
    await assertSucceeds(doc.set({ choice: "" }, { merge: true }));
  });
  it("Voting like on existing vote", async () => {
    const db = await setup(otherAuth, commentMockData);
    const doc = db.doc(commentOtherVotePath);
    await assertSucceeds(doc.set({ choice: "like" }, { merge: true }));
  });
  it("Voting dislike again", async () => {
    const db = await setup(otherAuth, commentMockData);
    const doc = db.doc(commentOtherVotePath);
    await assertFails(doc.set({ choice: "dislike" }, { merge: true }));
  });

  it("Voting with wrong choice", async () => {
    const db = await setup(myAuth, commentMockData);
    const doc = db.doc(commentMyVotePath);
    await assertFails(doc.set({ choice: "li" }));
  });
});
