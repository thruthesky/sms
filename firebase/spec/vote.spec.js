
const { setup, teardown } = require('./helper');
describe('Vote', () => {

    const mockData = {
        "posts/post-id-1": {
            uid: "thruthesky",
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
            uid: "thruthesky",
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
    const mockUser = {
        uid: "thruthesky",

        firebase: {
            sign_in_provider: 'password' // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
        }
    };
    const mockUser2 = {
        uid: "user-2",

        firebase: {
            sign_in_provider: 'password' // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
        }
    };


    /// 테스트를 할 때, 설정을 한다.


    beforeAll(async () => {

    });

    /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
    afterAll(async () => {
        await teardown();
    });



    test('read non-existing vote document', async () => {
        const db = await setup(mockUser2, mockData);
        const doc = db.doc('likes/post-1-new-user-uid'); // 존재하지 않는 document
        await expect(doc.get()).toAllow();
    });

    test('create', async () => {
        
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.set({ uid: 'thruthesky', id: 'post-id-1', vote: 'like' })).toAllow();
    });
    test('failed with extra daa', async () => {
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.set({ uid: 'thruthesky', id: 'post-id-1', vote: 'like', oo: 'error' })).toDeny();
    });
    test('failed with wrong user id', async () => {
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.set({ uid: 'wrong user id', id: 'post-id-1', vote: 'like', oo: 'error' })).toDeny();
    });
    test('update', async () => {
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.update({ uid: 'thruthesky', id: 'post-id-1', vote: 'dislike' })).toAllow();
    });
    test('update fail with wrong user', async () => {
        const db = await setup({ uid: 'wrong' }, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.update({ uid: 'thruthesky', id: 'post-id-1', vote: 'dislike' })).toDeny();
    });

    test('delete', async () => {
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.delete()).toAllow();
    });
    test('delete fail with wrong user', async () => {
        const db = await setup({ uid: 'wrong' }, mockData);
        const doc = db.collection('likes').doc('post-id-1-thruthesky');
        await expect(doc.delete()).toDeny();
    });

    test('vote as user-2', async () => {
        const db = await setup(mockUser2, mockData);
        const doc = db.collection('likes').doc('post-id-2-user-2');
        await expect(doc.set({ uid: 'user-2', id: 'post-id-2', vote: 'like' })).toAllow();
    });

    test('thruthesky votes on post-id-2', async () => {
        const db = await setup(mockUser, mockData);
        const doc = db.collection('likes').doc('post-id-2-thruthesky');
        await expect(doc.set({ uid: 'thruthesky', id: 'post-id-2', vote: 'like' })).toAllow();
    });


    test('update voet on another user post', async () => {
        const db = await setup({ uid: 'thruthesky' }, mockData);
        const postsCol = db.collection('posts');
        await expect(postsCol.doc('post-id-2').set({ like: 1, }, { merge: true })).toAllow();
        await expect(postsCol.doc('post-id-2').set({ dislike: 1, }, { merge: true })).toAllow();
        await expect(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true })).toAllow();
        await expect(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })).toAllow();
        await expect(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true })).toAllow();
        await expect(postsCol.doc('post-id-2').set({ like: 3, dislike: 3, }, { merge: true })).toAllow();

        await expect(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })).toDeny(); /// 값자기 2를 감소
        await expect(postsCol.doc('post-id-2').set({ like: 0, dislike: 0, }, { merge: true })).toDeny(); /// 값자기 3를 감소


        await expect(postsCol.doc('post-id-2').set({ like: 2, dislike: 2, }, { merge: true })).toAllow(); // 1 씩 감소
        await expect(postsCol.doc('post-id-2').set({ like: 1, dislike: 1, }, { merge: true })).toAllow(); // 1 씩 감소
    });

    test('vote on my post', async () => {
        const db = await setup({ uid: 'user-2' }, mockData);
        const postsCol = db.collection('posts');
        await expect(postsCol.doc('post-id-2').set({ like: 100, }, { merge: true })).toDeny();
        await expect(postsCol.doc('post-id-2').set({ like: 1, dislike: 1 }, { merge: true })).toAllow();
    });

    test('update voet on another user comment', async () => {
        const db = await setup({ uid: 'thruthesky' }, mockData);
        const doc = db.doc('posts/post-id-2/comments/comment-1');
        await expect(doc.update({ like: 0, dislike: 0, })).toAllow();
        await expect(doc.update({ like: 1, dislike: 1, })).toAllow();
        await expect(doc.update({ like: 2, dislike: 2, })).toAllow();
        await expect(doc.update({ like: 4, dislike: 2, })).toDeny();
        await expect(doc.update({ like: 0, dislike: 2, })).toDeny();
    });
    test('vote on my comment', async () => {
        const db = await setup({ uid: 'user-2' }, mockData);
        const doc = db.doc('posts/post-id-2/comments/comment-1');
        await expect(doc.update({ like: 0, dislike: 0, })).toAllow();
        await expect(doc.update({ like: 1, dislike: 0, })).toAllow();
    });


});
