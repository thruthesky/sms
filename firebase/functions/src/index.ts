"use strict";
import * as functions from "firebase-functions";

/// 이름 변경 회수를 카운트한다.
export const myFunction = functions.firestore
  .document("users/{uid}")
  .onWrite((change, context) => {
    /// 사용자 값이 변경되기 이전, 이후의 값을 보관한다.
    const previousData = change.before.data() as any;
    const data = change.after.data() as any;

    /// 이름이 변경 될 때만 실행한다.
    /// 왜나하면, count 를 증가하면, 또 이 함수가 호출되어, 재귀적으로 무한 호출되기 때문이다.
    if (data.name == previousData.name) {
      return null; // null 을 리턴하면, 현재 함수에 의해 아무런 변경을 하지 않는 것 같다.
    }

    /// 데이터를 변경하려면, 반드시 `.set()` 함수의 `Promise` 를 리턴해야 한다.
    return change.after.ref.set(
      {
        name_change_count: data.count ? data.count + 1 : 1
      },
      { merge: true }
    );
  });
