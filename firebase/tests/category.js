const firebase = require("@firebase/rules-unit-testing");
const { setup, myAuth,  adminAuth, myUid, otherUid, } = require("./helper");


/// 저장된 도큐먼트 ID 가 `user-uid`
const adminMockData = {
  "users/admin_uid": {
      displayName: "user-name",
      isAdmin: true,
  },
};

describe("Category test", () => {
  it('success on reading without login', async () => {
    const db = await setup();
    const col = db.collection('categories');
    await firebase.assertSucceeds(col.limit(10).get());
  });

  it('fail on creating without login', async () => {
    const db = await setup();
    const col = db.collection('categories');
    await firebase.assertFails(col.add({ id: 'abc' }));
  });

  it('fail on creating with non-admin account.', async () => {
    const db = await setup({ uid: otherUid });
    const col = db.collection('categories');
    await firebase.assertFails(col.add({ id: 'abc' }));
  });

  it('success on creating a category with admin account.', async () => {
    const db = await setup(adminAuth, adminMockData);
    const doc = db.collection('categories').doc('abc');
    await firebase.assertSucceeds(doc.set({ id: 'abc', title: 'alphabet' }));
  });

  it('failed on updating a category with non-admin account.', async () => {
    const db = await setup(myAuth);
    const doc = db.collection('categories').doc('abc');
    await firebase.assertFails(doc.update({ title: 'updated title' }));
  });

  it('success on reading a category with non-admin account.', async () => {
    const db = await setup(myAuth);
    const doc = db.collection('categories').doc('abc');
    await firebase.assertSucceeds(doc.get());
  });

  it('fail on changing a category id with admin account.', async () => {
    const db = await setup(adminAuth, Object.assign(adminMockData, {
        'categories/abc': {
            id: 'abc',
            title: 'alphabet',
        }
    })
    );
    const doc = db.collection('categories').doc('abc');
    await firebase.assertFails(doc.update({ id: 'change-should-be-denied' }));
  });

  it('success on updating with same id but different title with admin account.', async () => {
    const db = await setup(adminAuth, Object.assign(adminMockData, {
        'categories/abc': {
            id: 'abc',
            title: 'alphabet',
        }
    })
    );
    const doc = db.collection('categories').doc('abc');
    await firebase.assertSucceeds(doc.update({ id: 'abc', title: 'new title' }));
  });


});
