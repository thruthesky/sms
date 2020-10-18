// TODO:
// - test on depth 0 and 13
//
const { setup, teardown } = require('./helper');
describe('Post', () => {

    const mockData = {
        "posts/post-id-1": {
            uid: "thruthesky",
            title: "this is the title."
        },
        "posts/post-id-1/comments/comment-id-1": {
            uid: "thruthesky",
            order: "99999.9999.999.999.999.999.999.999.999.999.999.999",
            content: 'content'
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


    /// 테스트를 할 때, 설정을 한다.
    beforeAll(async () => {

    });

    /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
    afterAll(async () => {
        await teardown();
    });

    test('without login', async () => {
        const db = await setup();
        const col = db.collection('posts').doc('post-id-1').collection('comments');
        await expect(col.add({ uid: 'uid', content: 'content' })).toDeny();
    });
    test('with login', async () => {
        const db = await setup(mockUser);
        const col = db.collection('posts').doc('non-exisiting-post-id').collection('comments');
        await expect(col.doc('non-exisiting-post-id').set({ uid: 'uid', content: 'content' })).toDeny();
    });

    test('with wrong post id', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('non-exisiting-post-id').collection('comments');
        await expect(col.add({ uid: 'uid', content: 'content' })).toDeny();
    });

    test('with wrong order', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments');
        await expect(col.add({ uid: 'uid', content: 'content' })).toDeny();
    });
    test('create', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments');
        await expect(col.add({
            uid: mockUser.uid,
            content: 'content',
            depth: 1,
            order: '99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999',
            like: 0,
            dislike: 0,
        })).toAllow();
    });

    test('update with wrong uid( not my comment )', async () => {
        const db = await setup({ uid: 'wrong-uid' }, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.update({
            content: 'content change',
        })).toDeny();
    });
    test('update with uid', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.update({
            content: 'content',
            uid: 'new-uid'
        })).toDeny();
    });
    test('update with order', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.update({
            content: 'content',
            order: '99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99990' // uid 변경
        })).toDeny();
    });
    test('update with non-exist-post', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('non-exist').collection('comments').doc('comment-id-1');
        await expect(col.update({
            content: 'content change',
        })).toDeny();
    });

    test('update with wrong comment -id', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('wrong-comment-id');
        await expect(col.update({
            content: 'content change',
        })).toDeny();
    });

    test('update comment', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.update({
            content: 'content change',
        })).toAllow();
    });

    test('delete with wrong uid', async () => {
        const db = await setup({uid: 'wrong'}, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.delete()).toDeny();
    });

    test('delete with wrong post id', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('wrong').collection('comments').doc('comment-id-1');
        await expect(col.delete()).toDeny();
    });

    test('delete with wrong wrong comment id', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('wrong');
        await expect(col.delete()).toDeny();
    });

    test('delete comment', async () => {
        const db = await setup(mockUser, mockData);
        const col = db.collection('posts').doc('post-id-1').collection('comments').doc('comment-id-1');
        await expect(col.delete()).toAllow();
    });

});
