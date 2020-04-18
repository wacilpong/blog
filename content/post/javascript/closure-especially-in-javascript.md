---
title: "Closure, especially in javascript"
date: "2020-04-18"
tags: ["javascript"]
draft: false
og_description: ""
---

클로저는 `고차함수(함수를 반환하는 함수)` 개념을 이용하여 스코프로 묶인 식별자를 바인딩하기 위한 일종의 기법이다. 클로저는 스코프 내의 실행 컨텍스트가 사라져도 이에 대해 접근할 수 있는 일종의 환경을 의미한다. 이 개념을 자바스크립트 언어를 통해 한번 알아보자.

<br />

```javascript
function test() {
  let a = 0;

  function innerTest() {
    a += 1;
    console.log(a);
  }

  return innerTest;
}

const callTest = test();

callTest(); // 1
```

test 함수의 실행을 callTest 식별자에 할당한 뒤 호출해보면 콘솔에 1이 찍힌다. 왜 그런지 순서대로 생각해보면 이렇다.

**1. test 함수는 innerTest 함수를 반환하는 고차함수이다.**
**2. innerTest의 스코프에는 a 식별자가 없으므로 스코프체이닝을 통해 자신의 상위에서 식별자 a를... 찾았다!**
**3. 식별자 a는 test 함수의 지역변수로써, 함수의 실행 컨텍스트가 종료되면 메모리에서 해제되어야 한다.**
**4. 그러나 변수 callTest에 test 함수의 리턴값, 즉 innerTest함수를 할당하여 호출하면 변수 a가 찍힌다.**

<br />

이처럼 클로저는 어떤 스코프의 식별자를 참조하는 내부 스코프가 외부에서 사용될 때 그 식별자가 사라지지 않는 현상이라고 할 수 있다. 물론 클로저를 구성할 수 있는 방법에는 함수를 return하는 것만 있는 것은 아니다. `addEventListner` 메소드처럼 콜백함수를 지정할 수 있을 때, 지역변수를 참조하는 내부함수를 콜백함수로 지정한다면 이 또한 클로저 환경이 만들어질 것이다.

<br />
<br />

Closure is a sort of technic to bind the variable in specific scope. Closure is a sort of the environment can access to excution context event it has disappear. Let's take a look this term in javascript.

**1. test is a higher-order function to return innerTest.**
**2. there is no a in innerTest scope, so it finds from outer through scope chaining.**
**3. a is a local variable in test, so it has to be free from memory.**
**4. but when call the callTest, variable a is logged console.**