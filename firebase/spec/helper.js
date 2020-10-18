const firebase = require('@firebase/testing');
const fs = require('fs');


/**
 * setup 은 Testing 환경을 설정한다.
 * 
 * @param auth 는 가짜(mock)사용자 Auth 지정한다.
 *          auth 는 uid 를 가지는 객체이면 되는 것 같다.
 * @param data 는 mock data 이다.
 *          object 로 원하는 데이터를 마음데로 지정하면 된다.
 *          여기서는 key 를 도큐먼트 path 로 하고,
 *                  value 를 도큐먼트 값으로 지정한다.
 *          즉, { 'animal/cat': {name: 'nell'}, 'animal/dog': {name: 'lobby', age: 2} } 와 같이 할 수 있다.
 *             
 */
module.exports.setup = async (auth, data) => {

    /**
     * Test database 를 initialize 할 때 마다 unique project id 가 필요하다.
     */
    const projectId = `rules-spec-${Date.now()}`;
    /**
     * Test app 를 생성한다.
     * 주의 할 점은 Test app 을 생성하면 아무런 security rule 이 지정되지 않은 상태이다.
     * 그래서, 원하는 데이터를 미리 좀 저장하고 나서, 나중에 security rule 을 지정 할 수 있다.
     */
    const app = firebase.initializeTestApp({
        projectId,
        auth
    });

    /**
     * Firestore 쿼리를 할 수 있는 Reference 를 구한다.
     */
    const db = app.firestore();

    /**
     * 그리고 mock data 를 집어 넣는다.
     * 
     * - 만약 mock data 가 안들어가면 임시 룰을 read, write true 로 만들어 적용한다.
     */
    if (data) {
        for (const key in data) {
            const ref = db.doc(key);
            await ref.set(data[key]);
        }
    }

    /**
     * 그리고 나서 security rule 을 적용한다.
     * 이 때 rule 은 firestore.rules 파일을 읽어서 지정한다.
     */
    await firebase.loadFirestoreRules({
        projectId,
        rules: fs.readFileSync('firestore.rules')
    });

    /// 설정이 끝났으면 Firestore ref 를 리턴한다.
    return db;


}

/**
 * 테스트가 끝나고 생성된 모든 앱을 제거하는 함수
 */

module.exports.teardown = async () => {
    await Promise.all(firebase.apps().map(app => app.delete()));
}

expect.extend({
    async toAllow(testPromise) {
        let pass = false;
        try {
            await firebase.assertSucceeds(testPromise);
            pass = true;
        } catch (err) {
            console.log(err);
        }

        return {
            pass,
            message: () =>
                "Expected Firebase operation to be allowed, but it was denied"
        };
    }
});

expect.extend({
    async toDeny(testPromise) {
        let pass = false;
        try {
            await firebase.assertFails(testPromise);
            pass = true;
        } catch (err) {
            console.log(err);
        }
        return {
            pass,
            message: () =>
                "Expected Firebase operation to be denied, but it was allowed"
        };
    }
});
