const { assertFails, assertSucceeds } = require("@firebase/rules-unit-testing");
const { setup, myAuth, myUid, otherUid } = require("./helper");
const tokenId = "token-1";

const mockData = {
  "posts/post-id-1": {
      uid: myUid,
      title: "this is the title."
  },
  'categories/apple': {
      title: 'Apple',
  },
};


describe("Post Creation", () => {
  /// Write without logging in
  it("Post create without login", async () => {
    const db = await setup();
    const postsDoc = db
      .collection("posts")
      .doc('post-id-1')
    await assertFails(postsDoc.set({ uid: 'my-id', title: 'title' }));
  });
    ///  Test creating a post with someone else's UID.
    it("fail on creating a post with other user's uid", async() => {
      const db = await setup(myAuth);
      const postsCol = db.collection('posts');      
    await assertFails(postsCol.add({ uid: 'other-uid', title: 'title' }));
  });

  it('fail on creating a post with login but without categories', async () => {
    const db = await setup(myAuth);
    const postsCol = db.collection('posts');
    await assertFails(postsCol.add({ uid: myAuth.uid, title: 'title' }));
  });

  it('create success', async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection('posts');
    await assertSucceeds(postsCol.add({ uid: myAuth.uid, title: 'title', category: 'apple', like: 0, dislike: 0 }));
  });
  
  it('fail on wrong category', async () => {
    const db = await setup(myAuth, mockData);
    const postsCol = db.collection('posts');
    await assertFails(postsCol.add({ uid: myAuth.uid, title: 'title', category: 'wrong-category' }));
  });

  it('fail with array category', async () => {
    const db = await setup(myAuth);
    const postsCol = db.collection('posts');
    await assertFails(postsCol.add({ uid: myAuth.uid, title: 'title', category: ['abc'] }));
  });

  it('fail on updating a post with wrong user', async () => {
    const db = await setup({ uid: otherUid }, mockData);
    const postsDoc = db.collection('posts')
      .doc('post-id-1');
    await assertFails(postsDoc.update({ uid: 'my-id', title: 'title' }));
  });

  it('fail on updating a post create by another user', async () => {
    const db = await setup(myAuth, {
        "posts/post-id-1": {
            uid: otherUid,
            title: "this is the title."
        }
    });
    const postsDoc = db.collection('posts')
      .doc('post-id-1');
    await assertFails(postsDoc.update({ uid: myAuth.uid, title: 'title' }));
  });

  it('updating my post', async () => {
    const db = await setup(myAuth, mockData);
    const postsDoc = db.collection('posts').doc('post-id-1')
    await assertSucceeds(postsDoc.update({ uid: myAuth.uid, title: 'title', category: 'apple' }));
  });

  
  it("fail on deleting another's post", async () => {
    const db = await setup(myAuth, {
        "posts/post-id-3": {
            uid: "written-by-another-user",
            title: "this is the title."
        }
    });
    const postsDoc = db.collection('posts').doc('post-id-3');
    await assertFails(postsDoc.delete());
  });

  
  it("success on deleting my post", async () => {
    const db = await setup(myAuth, mockData);
    const postsDoc = db.collection('posts').doc('post-id-1');
    await assertSucceeds(postsDoc.delete());
  });

});
