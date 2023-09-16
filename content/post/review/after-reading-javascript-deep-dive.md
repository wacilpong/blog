---
title: "After reading <modern javascript deep dive>"
date: "2021-06-23"
tags: ["review"]
draft: false
og_description: "모던 자바스크립트 deep dive를 읽고 내맘대로 정리해보았다."
---

by 이웅모

무려 900쪽이 넘는 엄청난 분량으로, 읽다가 _오?_ 했던 것만 한번 정리해본다.

<br />

## 기본적인 개념

- 리터럴(literal)
  - 사람이 이해할 수 있는 문자 또는 약속된 기호를 사용해 값을 생성하는 표기법이다.
  - _ex) 숫자 리터럴 3을 코드에 기술하면 자바스크립트 엔진은 이를 평가해 숫자 값 3을 생성한다._
- `NaN`는 자신과 일치하지 않는 유일한 값이므로, 숫자가 NaN인지는 빌트인 함수 isNaN로 체크한다.
- 원시값 vs 객체
  - 원시 값을 변수에 할당하면 확보된 메모리 공간에는 실제 값이 저장된다.
  - 객체를 변수에 할당하면 확보된 메모리 공간에는 참조 값이 저장된다.
  - **"값에 의한 전달"과 "참조에 의한 전달"은 식별자가 기억하는 메모리 공간에 저장되어 있는 값을 복사해 전달한다는 면에서 동일하다.**
  - 식별자가 기억하는 메모리 공간, 즉 변수에 저장되어 있는 값이 원시값인지 참조값인지에 대한 차이 뿐이다.
  - 따라서 엄격히 말하면 자바스크립트에는 참조에 의한 전달이 아닌 값에 의한 전달만 존재한다.
- `함수 선언문(function a ...)` 함수를 선언문 이전에 호출하면 함수 호이스팅에 의해 호출 가능하다.
- `함수 표현식(var a = function ...)` 함수는 변수 호이스팅이 일어나므로 런타임에서 평가된다.
- 함수의 매개변수는 코드를 이해하는 데 방해되므로 이상적인 매개변수 개수는 0개이다.
- 매개변수는 최대 3개 이상을 넘지 않는 것을 권장한다.

<hr />

- 스코프
  - **동적 스코프: 함수를 어디서 호출했는지에 따라 그 상위 스코프를 결정한다.**
  - **정적 스코프 or 렉시컬 스코프: 함수를 어디서 정의했는지에 따라 상위 스코프가 정해진다.**
  - 전역 변수를 반드시 사용해야 할 이유가 없다면, 지역 변수를 사용해야 한다.
  - 변수의 스코프는 좁을수록 좋다.
- **생성자 함수 내부에서는 return문을 반드시 생략해야 한다.**
  - 생성자 함수는 암묵적으로 this를 반환한다.
  - 원시값을 return해도 무시하고 this를 반환한다.
  - 객체를 return하면 this가 아닌 해당 객체가 반환된다.
  - 따라서 this가 아닌 다른 값을 명시적으로 반환하면 기본 동작이 훼손된다.
- **프로토타입 체인은 프로퍼티를 한방향으로만 검색해야 하므로, 단방향 연결 리스트로 구현되어야 한다.**
  - 자바스크립트는 객체의 프로퍼티(메서드 포함)에 접근하려고 할 때 해당 객체에 접근하려는 프로퍼티가 없으면 `[[Prototype]]` 내부 슬롯의 참조를 따라 자신의 부모 역할을 하는 프로토타입의 프로퍼티를 순차적으로 검색하는데, 이것이 프로토타입 체인이다.
  - 프로토타입 체인은 자바스크립트가 객체지향 프로그래밍의 상속을 구현하는 메커니즘이다.
- String, Number, Boolean 등 표준 빌트인 생성자 함수가 존재한다.
  - `wrapper object`: 문자열, 숫자, 불리언 등 원시값에 대해 객체처럼 접근하면 생성되는 임시 객체
  - 원시값을 객체처럼 사용하면 js 엔진은 연관 객체를 만들어 처리하고 다시 원시값으로 돌린다.
  - _ex) "text".length, "text".toUpperCase()_
- 실행컨텍스트는 식별자를 등록하고 관리하는 스코프와 코드의 실행순서관리를 구현한 내부 메커니즘이다.
  - 렉시컬 환경은 스코프와 식별자를 관리, 실행컨텍스트 스택은 코드의 실행순서를 관리한다.
  - 식별자를 검색할 떄는 항상 현재 실행 중인 실행컨텍스트 렉시컬 환경에서 검색하기 시작한다.
- **렉시컬 스코프는 달리 말하면 정적 스코프로, 함수를 어디에 정의했는지에 따라 상위 스코프가 결정되는 것이다.**
- 외부함수보다 더 오래 유지되는 중첩함수가 외부함수의 변수를 참조할 수 있는데, 이때 중첩함수가 클로저이다.
- **고차함수는 외부상태 변경과 가변 데이터를 피하고, 불변성을 지향하는 함수형 프로그래밍이 기반이다.**
  - 함수형 프로그래밍은 변수의 사용과 부수효과를 억제해 오류를 피하려는 노력의 일환이다.
  - js는 고차함수를 다수 지원한다.
    _ex) Array.prototype.sort, forEach, map, flatMap, filter, reduce..._

<br />

## 클래스

- 생성자 함수와 클래스는 프로토타입 기반의 객체지향을 구현했다는 점에서 유사하나, extends와 super 키워드는 상속 관계 구현을 더 명료하게 한다. 따라서 syntax sugar보다는 새로운 객체 생성 메커니즘으로 보는 것이 좀더 합당하다.
- 클래스에 contructor를 생략하면 빈 constructor가 암묵적으로 정의된다.
- 클래스는 클래스 정의 이전에 참조할 수 없어서 마치 호이스팅이 발생하지 않는 것처럼 보인다.
- `var`, `let`, `const`, `function`, `function*`, `class` 키워드로 선언된 모든 식별자는 호이스팅된다.
  ```ts
  const Person = "";
  {
    // 호이스팅이 발생하지 않으면 ''이 출력되어야 함
    console.log(Person);
    class Person {}
  }
  ```
- static 키워드를 붙이면 정적 메서드가 되고, **정적 메서드는 인스턴스를 생성하지 않아도 호출할 수 있다.**
- 클래스 내 정적 메서드 vs 프로토타입 메서드
  - 속해 있는 프로토타입 체인이 다르다.
  - **정적 메서드는 클래스로 호출하고, 프로토타입 메서드는 인스턴스로 호출한다.**
  - 정적 메서드는 인스턴스 프로퍼티를 참조할 수 없다.
  - 프로토타입 메서드는 인스턴스 프로퍼티를 참조할 수 있다.
  - **즉, 둘의 this 바인딩이 다르므로 this를 사용하지 않는 메서드를 정적 메서드로 정의하면 좋다.**
    ```ts
    class Square {
      static area(w, h) {
        return w * h;
      }
    }
    console.log(Square.area(10, 10));
    ```
    ```ts
    class Square {
      constructor(w, h) {
        this.w = w;
        this.h = h;
      }
      area() {
        return this.w * this.h;
      }
    }
    const squareInstance = new Square(10, 10);
    console.log(squareInstance.area());
    ```
- 클래스 필드에 함수를 할당하면 프로퍼티가 아니라 인스턴스 메서드가 되므로 권장하지 않는다.
- 클래스 필드에 화살표 함수를 할당해서 함수 내부 this가 인스턴스를 가리키게 의도할 수 있다.

<br />

## ES6 함수의 추가 기능

- ES6부터 일반함수는 constructor이지만, 메서드와 화살표 함수는 non-constructor이다.
- ES6 메서드는 본연의 기능(super)을 추가하고 의미상 맞지 않는 기능(constructor)는 제거되었다.
- **따라서 메서드를 정의할 때 프로퍼티 값으로 익명함수 표현식을 할당하는 방식은 권장하지 않는다.**
- rest 파라미터(...)는 함수에 전달된 인수들의 목록을 배열로 전달받는다.
- 일반 매개변수와 rest 파라미터는 함께 사용할 수 있고, 순차적으로 할당된다.

<br />

## 배열

- **배열은 인덱스를 나타내는 문자열을 프로퍼티 키로 갖는 객체다.**
  - 따라서 존재하지 않는 요소를 참조하면 undefined를 반환한다.
- 배열의 요소를 위한 메모리 공간이 다른 크기일 수 있고, 연속적으로 이어져있지 않을 수 있다.
  - `희소 배열(sparse array)`이라고 하며, 배열 일부가 비어있을 수 있다.
    _ex) const sparse = [, 2, , 4]_
  - js 문법적으로 희소 배열을 허용하지만, 연속적인 값의 집합으로 쓰는 것이 성능상 좋다.
- js 배열은 해시테이블로 구현된 객체이므로 인덱스로 접근하면 일반 배열보다 성능이 느리다.
- js 배열은 특정 요소를 검색/삽입/삭제하는 경우 일반 배열보다 빠른 성능을 기대할 수 있다.
- **delete 연산자로 프로퍼티를 삭제할 수 있지만, length값은 변하지 않는다.**
  - 따라서 희소 배열을 만드는 delete 연산자는 배열에 사용하지 말자.
  - 희소 배열로 만들지 않고 특정 요소를 완전히 삭제하려면 `splice` 메서드를 쓰자.
- unshift 메서드보다는 spread 문법을 사용해 원본을 변경하지 않도록 하자.
  - spread 문법은 표현식만으로 맨앞에 요소를 추가할 수 있고 부수효과도 없다.

<br />

## 정규식

- 정규 표현식은 일정한 규칙(패턴)을 가진 문자열의 집합을 표현하기 위한 형식 언어다.
- `RegExp.prototype.exec`은 g 플래그 지정해도 첫번째 매칭 결과만 반환한다.
- `String.prototype.match`는 g 플래그 지정하면 모든 매칭 결과를 배열로 반환한다.
- 정규식 관련 플래그
  - i: 대소문자 구별하지 않고 패턴 검색
  - g: 패턴과 일치하는 모든 문자열 전역 검색
  - m: 문자열 행이 바뀌어도 패턴 검색 계속함
- 예시
  - _임의의 3자리 문자열 -> /.../g_
  - _A가 최소 n, 최대 m번 반복되는 문자열 -> /A{1,2}/g_
  - _A 또는 B -> /A|B/g_
  - \_숫자가 아닌 문자들 -> /[\D,]+/g
  - _com으로 끝나는지 검사 -> /com$/_

<br />

## 이터러블 (iterable)

- `이터러블 프로토콜`
  - ex. 배열, 문자열, Map, Set
  - Symbol.iterator를 프로퍼티 키로 사용한 메서드를 직접 구현하거나, 프로토타입 체인을 통해 상속받은 **Symbol.iterator** 메서드를 호출하면 이터레이터를 반환한다.
  - 이러한 규약이 이터러블 프로토콜이며, 이를 준수하는 객체를 이터러블이라고 한다.
  - **for...of** 문으로 순회할 수 있고 spread, destructuring할 수 있다.
- `이터레이터 프로토콜`
  - ex. `[1,2,3][Symbol.iterator]()`
  - 이터러블의 Symbol.iterator 메서드를 호출하면 이터레이터를 반환한다.
  - next 메서드를 가지며, value와 done 프로퍼티를 갖는 객체를 반환한다.
  - 이러한 규약이 이터레이터 프로토콜이며, **이터레이터 프로토콜을 준수하는 객체를 이터레이터라고 한다.**
  - 이터레이터는 이터러블의 요소를 탐색하기 위한 포인터 역할을 한다.
- 사용자 정의 이터러블

  - 아래 같은 무한 이터러블은 지연평가(lazy evaluation)를 통해 데이터를 생성한다.
  - **for...of** 나 destructuring할당 등이 실행되기 전까지 데이터를 생성하지 않는다.
  - 순회의 경우 next 메서드가 호출되기 전까지는 데이터를 생성하지 않는다.
  - 즉, 데이터가 필요한 순간 데이터를 생성한다.

    ```ts
    // 피보나치 수열 구현
    // 1. Symbol.iterator 메서드 및 next 소유하도록 구현 -> 이터러블 프로토콜
    // 2. next 메서드는 value, done을 갖는 객체를 반환 -> 이터레이터 프로토콜
    // 3. 둘을 동시에 충족하면 이터러블이면서 이터레이터로 만들 수 있다.
    const fibonacci = function (max) {
      let [pre, cur] = [0, 1];

      return {
        [Symbol.iterator]() {
          return this;
        },
        next() {
          [pre, cur] = [cur, pre + cur];

          return {
            value: cur,
          };
        },
      };
    };

    // 사용예시 1
    for (const n of fibonacci()) {
      if (n > 10000) {
        break;
      }

      console.log(n);
    }

    // 사용예시 2
    const [n1, n2, n3] = fibonacci();
    console.log(n1, n2, n3);
    ```