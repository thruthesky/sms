/**
 * helper.js 에서 만든 설정과 teardown 을 import 하낟.
 */
const { setup, teardown } = require('./helper');

describe('Database rules', () => {

    /// 테스트를 할 때, 설정을 한다.
    beforeAll(async () => {
    });


    /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
    afterAll(async () => {
        await teardown();
    })


    test("fail on editing 'isAdmin' property by a user", async () => {
        /// 저장된 도큐먼트 ID 가 `a-user-uid`
        const mockData = {
            "users/a-user-uid": {
                displayName: "user-name",
                isAdmin: false,
            },
        };
        /// 로그인은 `thruthesky` 로 함.
        const mockUser = {
            uid: "a-user-uid",
        };
        const db = await setup(mockUser, mockData);
        usersCol = db.collection('users');
        await expect(usersCol.doc(mockUser.uid).update({ birthday: 731016 })).toAllow();
        await expect(usersCol.doc(mockUser.uid).update({ isAdmin: true })).toDeny();
    });


    test("fail on editing 'isAdmin' property by admin", async () => {
        /// 저장된 도큐먼트 ID 가 `a-user-uid`
        const mockData = {
            "users/a-user-uid": {
                displayName: "user-name",
                isAdmin: true,
            },
        };
        /// 로그인은 `thruthesky` 로 함.
        const mockUser = {
            uid: "a-user-uid",
        };
        const db = await setup(mockUser, mockData);
        usersCol = db.collection('users');
        await expect(usersCol.doc(mockUser.uid).update({ birthday: 731016 })).toAllow();
        await expect(usersCol.doc(mockUser.uid).update({ isAdmin: true })).toAllow();
    });


});