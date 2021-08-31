---
title: "After reading <Effecttive Typescript>"
date: "2021-06-23"
tags: ["review"]
draft: false
og_description: "이펙티브 타입스크립트를 읽고 내맘대로 정리해보았다."
---

by Dan Vanderkam

- 모든 자바스크립트는 타입스크립트지만, 그 반대는 성립되지 않는다.
- js를 ts로 전환하는게 아니면 `noImplicitAny`를 설정하는 것이 좋다.
- _undefined is not an object_ 같은 런타임 오류 방지를 위해 `strictNullChecks`를 설정하는 것이 좋다.
- 타입스크립트 컴파일러는 두 가지 역할이 있으며, 이 둘은 완전히 독립적으로 수행된다.
  - 최신 ts/js를 브라우저에서 동작할 수 있게 구버전 js로 트랜스파일(transpile)한다.
  - 코드의 타입 오류를 체크한다.
- 단언문은 컴파일 중에 제거되므로, 타입 체커는 알지 못한다.
  - 따라서 `!`(non-null assertion)는 값이 null이 아니라고 확신할 수 있을 때만 사용해야 한다.

<hr />

- **type 키워드는 인터페이스보다 쓰임새가 많다.**
  - 유니온이 될 수도 있고, 매핑된 타입이나 조건부 타입처럼 고급 기능에 활용되기도 한다.
  - 튜플과 배열타입도 더 간결하게 표현할 수 있다.
    ```ts
    type Pair = [number, number];
    type StringList = string[];
    type NamedNums = [string, ...number[]];
    ```
- **제네릭 타입은 타입을 위한 함수와 같다.**
  - 타입에 대한 DRY(Don't Repeat Yourself) 원칙의 핵심이다.
  - 제네릭 타입에서 매핑할 수 있는 값, 즉 매개변수를 제한하려면 `extends`를 사용하자.
    ```ts
    interface Name {
      first: string;
      last: string;
    }
    type DancingDuo<T extends Name> = [T, T];
    ```
- **readonly를 사용하면 지역변수와 관련된 변경 오류를 방지할 수 있다.**
  - `readonly number[]`가 있다고 한다면,
  - 배열의 요소를 읽을 수 있지만, 쓸 수는 없다.
  - length를 읽을 수 있지만, 배열을 변경할 수는 없다.
  - 배열을 변경하는 pop과 같은 메서드를 호출할 수 없다.
  - 함수가 매개변수를 변경하지 않는다면, readonly로 선언해야 한다.
    ```ts
    function arrSum(arr: readonly number[]) {
      let sum = 0;
      for (const num of arr) {
        sum += num;
      }
      return sum;
    }
    ```
- **ts는 타입 추론을 적극적으로 수행한다.**
  - 타입 추론은 수동으로 명시해야 하는 타입 구문의 수를 줄여준다.
  - 즉, 추론 가능한 타입이라면 타입 명시를 안하는게 낫다.
    _ex) const x = 12 (**GOOD**) / const x: number = 12 (**BAD**)_
- **값 뒤에 as const를 작성하면 ts는 최대한 좁은 타입으로 추론한다.**
  - `const a1 = [1, 2, 3]` => 타입은 number[]
  - `const a2 = [1, 2, 3] as const` => 타입은 readonly [1, 2, 3];
  - 변수가 정말로 상수라면 상수 단언을 사용하자.
  - 그러나 상수 단언은 정의한 곳이 아닌 사용한 곳에서 오류가 발생할 수 있으니 주의하자.
