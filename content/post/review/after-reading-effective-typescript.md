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
    type Range = [start: number, end: number];
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
    - _ex) const x = 12 (**GOOD**) / const x: number = 12 (**BAD**)_
    - _그러나 객체는 as const로 상수 단언한 것이 아니라면 타입선언해주는 편이 낫다_
- **값 뒤에 as const를 작성하면 ts는 최대한 좁은 타입으로 추론한다.**
  - `const a1 = [1, 2, 3]` => 타입은 number[]
  - `const a2 = [1, 2, 3] as const` => 타입은 readonly [1, 2, 3];
  - 변수가 정말로 상수라면 상수 단언을 사용하자.
  - 그러나 상수 단언은 정의한 곳이 아닌 사용한 곳에서 오류가 발생할 수 있으니 주의하자.
- **선택의 여지가 있다면 프로미스를 생성하기 보다는 async/await을 사용하자**
  - 좀더 간결하고, async함수는 항상 프로미스를 반환하도록 강제되기 때문이다.
    ```ts
    // 반환타입은 Promise<number>
    const getNumber = async () => 42;
    ```
  - 즉시 사용가능한 값에도 프로미스를 반환하는 것이 이상해 보일 수 있지만, 실제로는 비동기 함수로 통일하도록 강제하는 데 도움이 된다.
  - 함수는 항상 동기 또는 비동기로 실행되어야 하며 절대 혼용해서는 안된다.
  - 참고로 async 함수에서 프로미스로 래핑해도 반환타입은 `Promise<Promise<T>>`가 아닌 `Promise<T>`이다.
- **부정확한 타입보다는 미완성 타입 사용하기**
  - 실수가 발생하기 쉽고 잘못된 타입은 차라리 타입이 없는 것보다 못할 수 있다.
  - 일반적으로 any 같은 추상적인 타입은 정제하는 것이 좋지만
  - 타입이 구체적으로 정제된다고 해서 정확도가 무조건 올라가는 것은 아니다.
  - 타입에 의존하기 시작하면 부정확함으로 인해 발생하는 문제는 커진다.
  - 예를 들어 아래는 타입정보는 정밀해졌지만 결과적으로 복잡해졌다.
  - 즉, 타입정보를 구체화할수록 오류메시지와 자동완성기능에 주의를 기울이자.
    ```ts
    type FnName = "+" | "-" | "*" | "/" | ">" | "rgb";
    type CallExpression = [FnName, ...any[]];
    type Expression = number | string | CallExpression;
    const tests: Expression[] = [
      10,
      "red",
      // TypeError: **는 FnName 형식에 할당할 수 없음
      ["**", 1, 2],
    ];
    ```
- **가능한 좁은 범위에서만 any타입 사용하기**

  - 아래처럼 any의 영향을 최대한 좁히자.
  - x의 반환타입 any는 코드 전반에 영향을 주지만,
  - good함수 내 x는 test함수의 인자로 넘길 때에만 영향
    ```ts
    function bad() {
      const x: any = callFunction();
      test(x);
    }
    function good() {
      const x = callFunction();
      test(x as any);
    }
    ```
  - any를 구체적으로 변형해서 사용하자.
  - good함수처럼 정확히 배열타입을 선언해주면,
  - 함수호출 시 매개변수가 배열인지 체크된다.
    ```ts
    function bad(arr: any) {...}
    function good(arr: any[]) {...}
    ```

- **문자열 열거형(enum)대신 리터럴 타입 유니온 사용하기**

  - 아래처럼 enum은 명목적 타이핑(nominally typing)을 사용한다.
  - 구조적 타이핑: 구조가 같으면 할당이 허용
  - 명목적 타이핑: 타입의 이름이 같아야 할당이 허용
    ```ts
    enum Flavor {
      VANILLA = "vanilla",
      CHOCOLATE = "chocolate",
      STRAWBERRY = "strawberry",
    }
    let falvor = Flavor.CHOCOLATE;
    flavor = "strawberry";
    // "strawberry" 형식은 'Flavor' 형식에 할당될 수 없습니다.
    ```
  - 위 예시에서 Flavor는 런타임 시점에는 문자열인데도 ts에서는 enum을 임포트해서 써야 한다.
  - enum 대신 리터럴 타입 유니온을 쓰면 js와도 호환되고 안전하며 자동완성 기능도 쓸 수 있다.
    ```ts
    function scoop(flavor: Flavor) {...}
    scoop('vanilla');
    // "vanilla" 형식은 'Flavor' 형식의 매개변수에 할당될 수 없습니다.
    ```
    ```ts
    type Flavor = "vanilla" | "chocolate" | "strawberry";
    let falvor = Flavor.CHOCOLATE;
    flavor = "mint";
    // "mint" 유형은 'Flavor' 형식에 할당될 수 없습니다.
    ```

- **public, protected, private 접근제어자는 타입 시스템에서만 강제된다.**
  - 런타임에는 소용이 없으며 단언을 통해서만 우회할 수 있다.
  - 따라서 접근제어자로 데이터를 감추려고 하면 안 된다.
  - 확실히 데이터를 감추고 싶다면 클로저를 사용해야 한다.
