/**
 * helper.js 에서 만든 설정과 teardown 을 import 하낟.
 */
const { setup, teardown } = require('./helper');

/**
 * 그리고 operation 이 성공했는지 또는 실패했는지 알 수 있는 Assertion helper(테스트) 함수를 import 한다.
 * Assertion helper 함수들은 async operation 을 하는 1개의 인자를 가지는데, 예를 들면, ref.get() 과 같은 읽기 async 이다.
 * assertFails 는 rule 에 block 되면, resolve 된다. 즉, fail 을 expect 하는 것이다.
 * 그래서
 *      cosnt expectFailedRead = assertFails( ref.get () );
 * 와 같이 하면, fail 이 나면 정상인 것이다.
 * 그래서
 *      expect( expectFailedRead )
 * 테스트를 통과 하는 것이다.
 * 
 * - 도큐먼트 읽기와 출력
 *  `console.log( (await doc.get()).data() );`
 */
const { assertFails, assertSucceeds } = require('@firebase/testing');

describe('Database rules', () => {
    let db;
    let ref;

    /// 테스트를 할 때, 설정을 한다.
    beforeAll(async () => {
        /// 로그인을 하지 않은 체 테스트를 하려면, 그냥 setup() 에 아무런 인자를 주지 않으면 된다.
        db = await setup();

        /// 기본적으로 read, write false 이므로, 아무곳에 쓰면 에러가 난다.
        ref = db.collection('non-existing-collection');
    });


    /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
    afterAll(async () => {
        await teardown();
    })

    /// 실제 테스트를 작성한다.
    /// 기본적으로 read,write false rule 이어서 다 막혀있다. 그래서, 여기서는 읽기 쓰기 모두 에러가 난다.
    test('fail when reading/writing on an unauthorized collection', async () => {

        /// 두 줄로 테스트 작성
        const expectFailedRead = await assertFails(ref.get());
        expect(expectFailedRead);

        /// 한 줄로 테스트 작성
        expect(await assertFails(ref.add({})));

        /// 이해하기 쉽게 작성
        /// Jest 의 Custom matcher 기능을 통해서, 보다 쉽게 코딩을 할 수 있다.
        await expect(ref.get()).toDeny();

        /// 또는 필요할 때 아래와 같이 작성하면 된다.
        // await expect(ref.get()).toAllow();
    });

    test('login', async () => {
        /// 로그인은 (임시) `user-uid` 로 함.
        const mockUser = {
            uid: "user-uid", // uid 는 바로 지정.
            email: 'user1@gmail.com', // auth.token.email 에서 `auth.token` 부분을 빼고 바로 입력
            name: 'user display name', // auth.token.displayName 이다.
            firebase: {
                sign_in_provider: 'password' // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
            }
        };
        const db = await setup(mockUser, {});
    })


});