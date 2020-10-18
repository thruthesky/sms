
const { setup, teardown } = require('./helper');
describe('User push notification token', () => {

    /// 테스트를 할 때, 설정을 한다.
    beforeAll(async () => {

    });

    /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
    afterAll(async () => {
        await teardown();
    });

    test('add & read', async () => {
        const db = await setup({
            uid: 'my-uid',
        });
        const tokenDoc = db.collection('users').doc('my-uid').collection('tokens').doc('token-1');
        await expect(tokenDoc.set({ token: 'token-1' })).toAllow();
        await expect(tokenDoc.set({ token: 'token-2' })).toAllow();
    });

    test('deny test', async () => {
        const db = await setup({
            uid: 'another-uid',
        }, {
        });
        const tokenDoc = db.collection('users').doc('your-uid').collection('tokens').doc('token-3');
        await expect(tokenDoc.set({ token: 'token-3' })).toDeny();
        await expect(tokenDoc.get()).toAllow();

    });

});