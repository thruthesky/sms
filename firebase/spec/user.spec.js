const { setup, teardown } = require("./helper");
describe("User", () => {
  /// 테스트를 할 때, 설정을 한다.
  beforeAll(async () => {});

  /// 테스트가 끝나면 생성된 앱을 모두 제거한다.
  afterAll(async () => {
    await teardown();
  });

  test("creating without login", async () => {
    const db = await setup();
    const usersCol = db.collection("users");
    await expect(usersCol.add({})).toDeny();
  });

  test("creating with login", async () => {
    const db = await setup({
      uid: "uid",
      firebase: {
        sign_in_provider: "password" // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
      }
    });
    const usersCol = db.collection("users");
    await expect(usersCol.add({ data: "something" })).toAllow();
  });

  test("should success on update & get", async () => {
    const mockData = {
      "users/thruthesky": {
        displayName: "thruthesky"
      }
    };
    const mockUser = {
      uid: "thruthesky",
      firebase: {
        sign_in_provider: "password" // auth.token.firebase.sign_in_provider 에서 `auth.token`은 빼고 입력
      }
    };
    const db = await setup(mockUser, mockData);
    usersCol = db.collection("users");

    await expect(
      usersCol
        .doc(mockUser.uid)
        .update({ data: "something", birthday: "123456" })
    ).toAllow();

    const snapshot = await usersCol.doc(mockUser.uid).get();

    const data = snapshot.data();
    expect(data.birthday).toEqual("123456");
  });

  test("should fail on wrong user update", async () => {
    /// 로그인: `thruthesky` 로 로그인
    const mockUser = {
      uid: "thruthesky"
    };
    /// 데이터: 저장된 사용자 ID(도큐먼트 ID) 가 `wrong-uid`
    const mockData = {
      "users/thruthesky": {
        displayName: "wrongName"
      }
    };
    const db = await setup(mockUser, mockData);
    usersCol = db.collection("users");

    /// 로그인을 `thruthesky`로 했는데, `wrong-uid` 도큐먼트를 수정하려고 함
    await expect(
      usersCol
        .doc("wrong-uid")
        .update({ data: "something", birthday: "123456" })
    ).toDeny();
  });
});
