const firebase = require("@firebase/rules-unit-testing");
const MY_PROJECT_ID = "social-management-system"; // 실제 Firebase Project ID.
const myUid = "my_uid";
const yourUid = "yourUid";
const myAuth = { uid: myUid, email: "my@gmail.com" };

// Firestore intance 를 가져오는 함수
function getFirestore(auth = null) {
  return firebase
    .initializeTestApp({ projectId: MY_PROJECT_ID, auth: auth })
    .firestore();
}

// Firestore admin instance 를 가져오는 함수. 이 객체는 모든 권한을 다 가진다.
function getAdminFirestore() {
  return firebase.initializeAdminApp({ projectId: MY_PROJECT_ID }).firestore();
}

module.exports.setup = async (auth, data) => {
  await firebase.clearFirestoreData({ projectId: MY_PROJECT_ID });
  const db = getFirestore(auth); // Firestore instance 를 가져온다
  if (data) {
    // 데이터가 있으면,
    const adminDb = getAdminFirestore(); // Admin DB 를 가져와서
    for (const key in data) {
      // key 마다, 데이터를 모두 기록한다.
      const ref = adminDb.doc(key);
      await ref.set(data[key]);
    }
  }
  return db;
};

module.exports.myAuth = myAuth;
module.exports.myUid = myUid;
module.exports.yourUid = yourUid;
