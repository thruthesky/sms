const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, otherUid } = require("./helper");


const mockData = {
  "posts/post-id-1": {
      uid: myAuth.uid,
      title: "title",
      content: "content",
      like: 0,
      dislike: 0,
  },
  "posts/post-id-2": {
      uid: "user-2",
      title: "title",
      content: "content",
      like: 0,
      dislike: 0
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
      vote: 'like'
  },
  "likes/post-id-2-user-2": {
      uid: "user-2",
      id: "post-id-2",
      vote: 'like'
  },
  'categories/apple': {
      title: 'Apple',
  },
};



const otherUserAuth = {
  uid: "user-2",

  firebase: {
      sign_in_provider: 'password' // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
  }
};

describe("Vote test", () => {

  it('read non-existing vote document', async () => {
    const db = await setup(otherUserAuth, mockData);
    const doc = db.doc('likes/post-1-new-user-uid'); // 존재하지 않는 document
    await assertSucceeds(doc.get());
  });

  it('create', async () => {
      
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertSucceeds(doc.set({ uid: myAuth.uid, id: 'post-id-1', vote: 'like' }));
  });
  it('failed with extra daa', async () => {
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertFails(doc.set({ uid: myAuth.uid, id: 'post-id-1', vote: 'like', oo: 'error' }));
  });
  it('failed with wrong user id', async () => {
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertFails(doc.set({ uid: 'wrong user id', id: 'post-id-1', vote: 'like', oo: 'error' }));
  });
  it('update', async () => {
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertSucceeds(doc.update({ uid: myAuth.uid, id: 'post-id-1', vote: 'dislike' }));
  });
  it('update fail with wrong user', async () => {
      const db = await setup({ uid: 'wrong' }, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertFails(doc.update({ uid: myAuth.uid, id: 'post-id-1', vote: 'dislike' }));
  });

  it('delete', async () => {
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertSucceeds(doc.delete());
  });
  it('delete fail with wrong user', async () => {
      const db = await setup({ uid: 'wrong' }, mockData);
      const doc = db.collection('likes').doc('post-id-1-thruthesky');
      await assertFails(doc.delete());
  });

  it('vote as user-2', async () => {
      const db = await setup(otherUserAuth, mockData);
      const doc = db.collection('likes').doc('post-id-2-user-2');
      await assertSucceeds(doc.set({ uid: 'user-2', id: 'post-id-2', vote: 'like' }));
  });

  it('thruthesky votes on post-id-2', async () => {
      const db = await setup(myAuth, mockData);
      const doc = db.collection('likes').doc('post-id-2-thruthesky');
      await assertSucceeds(doc.set({ uid: myAuth.uid, id: 'post-id-2', vote: 'like' }));
  });


  it('update vote on another user post', async () => {
      const db = await setup({ uid: myAuth.uid }, mockData);
      const postsCol = db.collection('posts');
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ dislike: 1, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 3, dislike: 3, }, { merge: true }));

      await assertFails(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })); /// 값자기 2를 감소
      await assertFails(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true })); /// 값자기 3를 감소


      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true })); // 1 씩 감소
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })); // 1 씩 감소
  });

  it('vote on my post', async () => {
      const db = await setup({ uid: 'user-2' }, mockData);
      const postsCol = db.collection('posts');
      await assertFails(postsCol.doc('post-id-2').set({ like: 100, }, { merge: true }));
      await assertSucceeds(postsCol.doc('post-id-2').set({ like: 1, dislike: 1 }, { merge: true }));
  });

  it('update vote on another user comment', async () => {
      const db = await setup({ uid: myAuth.uid }, mockData);
      const doc = db.doc('posts/post-id-2/comments/comment-1');
      await assertSucceeds(doc.update({ like: 0, dislike: 0, }));
      await assertSucceeds(doc.update({ like: 1, dislike: 1, }));
      await assertSucceeds(doc.update({ like: 2, dislike: 2, }));
      await assertFails(doc.update({ like: 4, dislike: 2, }));
      await assertFails(doc.update({ like: 0, dislike: 2, }));
  });
  it('vote on my comment', async () => {
      const db = await setup({ uid: 'user-2' }, mockData);
      const doc = db.doc('posts/post-id-2/comments/comment-1');
      await assertSucceeds(doc.update({ like: 0, dislike: 0, }));
      await assertSucceeds(doc.update({ like: 1, dislike: 0, }));
  });


});
