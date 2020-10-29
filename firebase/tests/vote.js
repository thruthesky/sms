const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { firestore } = require("firebase-admin");
const { setup, myAuth, otherUid } = require("./helper");

const myPostId = "my-post-id";
const otherPostId = "other-post-id";
const mockData = {
  ["posts/" + myPostId]: {
    uid: myAuth.uid,
    title: "title",
    content: "content",
    updatedAt: 0
  },
  ["posts/" + otherPostId]: {
    uid: otherUid,
    title: "title",
    content: "content"
  },
  "posts/post-id-2/comments/comment-1": {
    uid: "user-2",
    content: "content",
    like: 0,
    dislike: 0
  },
  "likes/post-id-1-thruthesky": {
    uid: myAuth.uid,
    id: "post-id-1",
    vote: "like"
  },
  "likes/post-id-2-user-2": {
    uid: "user-2",
    id: "post-id-2",
    vote: "like"
  },
  "categories/apple": {
    title: "Apple"
  }
};

const otherUserAuth = {
  uid: "user-2",

  firebase: {
    sign_in_provider: "password" // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
  }
};

/// Rules. @see firestore.rules
///
describe("Vote test", () => {
  it("Voting on other post with title", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertFails(doc.update({ likes: 1, title: "change" }));
  });
  it("Voting on my post with title", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(myPostId);
    await assertSucceeds(
      doc.update({ likes: 1, title: "change", updatedAt: 5, category: "apple" })
    );
  });

  it("Voting on my post", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(myPostId);
    await assertSucceeds(doc.update({ likes: 1 }));
  });

  it("Voting on other post. set likes to 0", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertSucceeds(doc.update({ likes: 1 }));
  });
  it("Voting on other post. set likes 1", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertSucceeds(doc.update({ likes: 1 }));
  });

  it("Voting on other post. set likes to 2, 3, 4 or -1 should be error.", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertFails(doc.update({ likes: 2 }));
    await assertFails(doc.update({ likes: 3 }));
    await assertFails(doc.update({ likes: 4 }));
    await assertFails(doc.update({ likes: -1 }));
  });

  it("Voting on other post. set dislikes to 0", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertSucceeds(doc.update({ dislikes: 0 }));
  });
  it("Voting on other post. set dislikes to 1", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertSucceeds(doc.update({ dislikes: 1 }));
  });

  it("Voting on other post. set dislikes to 2, 3, 4 or -1 should be error.", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertFails(doc.update({ dislikes: 2 }));
    await assertFails(doc.update({ dislikes: 3 }));
    await assertFails(doc.update({ dislikes: 4 }));
    await assertFails(doc.update({ dislikes: -1 }));
  });

  it("Voting on other post. Together with likes and dislikes", async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection("posts");
    const doc = postsCol.doc(otherPostId);
    await assertSucceeds(doc.update({ likes: 0, dislikes: 0 }));
    await assertSucceeds(doc.update({ likes: 0, dislikes: 1 }));
    await assertSucceeds(doc.update({ likes: 1, dislikes: 0 }));
    await assertSucceeds(doc.update({ likes: 1, dislikes: 1 }));
  });

  //   it('create', async () => {

  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertSucceeds(doc.set({ uid: myAuth.uid, id: 'post-id-1', vote: 'like' }));
  //   });
  //   it('failed with extra daa', async () => {
  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertFails(doc.set({ uid: myAuth.uid, id: 'post-id-1', vote: 'like', oo: 'error' }));
  //   });
  //   it('failed with wrong user id', async () => {
  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertFails(doc.set({ uid: 'wrong user id', id: 'post-id-1', vote: 'like', oo: 'error' }));
  //   });
  //   it('update', async () => {
  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertSucceeds(doc.update({ uid: myAuth.uid, id: 'post-id-1', vote: 'dislike' }));
  //   });
  //   it('update fail with wrong user', async () => {
  //       const db = await setup({ uid: 'wrong' }, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertFails(doc.update({ uid: myAuth.uid, id: 'post-id-1', vote: 'dislike' }));
  //   });

  //   it('delete', async () => {
  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertSucceeds(doc.delete());
  //   });
  //   it('delete fail with wrong user', async () => {
  //       const db = await setup({ uid: 'wrong' }, mockData);
  //       const doc = db.collection('likes').doc('post-id-1-thruthesky');
  //       await assertFails(doc.delete());
  //   });

  //   it('vote as user-2', async () => {
  //       const db = await setup(otherUserAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-2-user-2');
  //       await assertSucceeds(doc.set({ uid: 'user-2', id: 'post-id-2', vote: 'like' }));
  //   });

  //   it('thruthesky votes on post-id-2', async () => {
  //       const db = await setup(myAuth, mockData);
  //       const doc = db.collection('likes').doc('post-id-2-thruthesky');
  //       await assertSucceeds(doc.set({ uid: myAuth.uid, id: 'post-id-2', vote: 'like' }));
  //   });

  //   it('update voting on another user post', async () => {
  //       const db = await setup({ uid: myAuth.uid }, mockData);
  //       const postsCol = db.collection('posts');
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ dislike: 1, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 3, dislike: 3, }, { merge: true }));

  //       await assertFails(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })); /// 값자기 2를 감소
  //       await assertFails(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true })); /// 값자기 3를 감소

  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true })); // 1 씩 감소
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })); // 1 씩 감소
  //   });

  //   it('voting on my post', async () => {
  //       const db = await setup({ uid: 'user-2' }, mockData);
  //       const postsCol = db.collection('posts');
  //       await assertFails(postsCol.doc('post-id-2').set({ like: 100, }, { merge: true }));
  //       await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1 }, { merge: true }));
  //   });

  //   it('update voting on another user comment', async () => {
  //       const db = await setup({ uid: myAuth.uid }, mockData);
  //       const doc = db.doc('posts/post-id-2/comments/comment-1');
  //       await assertSucceeds(doc.update({ like: 0, dislike: 0, }));
  //       await assertSucceeds(doc.update({ like: 1, dislike: 1, }));
  //       await assertSucceeds(doc.update({ like: 2, dislike: 2, }));
  //       await assertFails(doc.update({ like: 4, dislike: 2, }));
  //       await assertFails(doc.update({ like: 0, dislike: 2, }));
  //   });
  //   it('voting on my comment', async () => {
  //       const db = await setup({ uid: 'user-2' }, mockData);
  //       const doc = db.doc('posts/post-id-2/comments/comment-1');
  //       await assertSucceeds(doc.update({ like: 0, dislike: 0, }));
  //       await assertSucceeds(doc.update({ like: 1, dislike: 0, }));
  //   });
});
