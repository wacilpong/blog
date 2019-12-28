---
title: "Hoisting about function"
date: "2019-12-04"
tags: ["javascript"]
draft: false
---

### First of all, what is execution context ?

자바스크립트는 실행하는 코드가 기억하고 있는 환경이 존재하는데, 이 환경정보가 바로 실행 컨텍스트다. 이 컨텍스트를 구성할 수 있는 방법은 전역 혹은 함수실행 정도가 있겠다.

자바스크립트 엔진은 컨텍스트가 실행될 때마다 변수부(VariableEnvironment) 객체와 어휘부(LexicalEnvironment) 객체를 저장한다. 간단히 말하면 변수부는 정적부의 특정부분이라고 할 수 있다. 둘 모두 현재 컨텍스트 내부의 식별자(변수명)와 외부 환경정보들을 기억하고 있다. 그러나 변수부는 최초 시점의 스냅샷일 뿐이고 어휘부는 컨텍스트가 실행(execution)될 때마다 변경사항이 반영된다.

이때 관련된 식별자 정보들을 기록하는 부분이 `environmentRecord`이다. 자바스크립트 엔진은 이러한 정보들을 모두 기록한 후에 코드를 실행시키는데, 코드가 실제로 실행되기 전에 먼저 해당 컨텍스트의 모든 식별자를 알고 있게 된다. 여기서 호이스팅이라는 개념이 나오게 된 것이다. 즉, [호이스팅 mdn문서](https://developer.mozilla.org/en-US/docs/Glossary/Hoisting)의 `JavaScript only hoists declarations, not initializations.`설명은 자바스크립트 엔진의 이러한 방식으로 인해 가능한 셈이다.
<br /><br />

There is execution context that is the sort of environment, executed code knows. The ways of creating execution context are such as global context or function call.

Javascript engine records VariableEnvironment and LexicalEnvironment object whenever context executed. That is, they already know about identifiers (like variables) and outer environment in context. But VariableEnvironment is just initialized snapshot, LexicalEnvironment is created for every execution context.

Both records identifier information in `environmentRecord`. Javascript engine records all these and then execute the code. So it actually already knows all identifiers before code is really execetued in case of that context. At this time, we can start the discussion about `hoisting`. The description about hoisting in mdn doc, `JavaScript only hoists declarations, not initializations.`, can be, becuase of this javascript engine's proccess.
<br /><br /><hr>

### Simple example of Hoisting

```javascript
function test() {
  console.log(x); // undefined
  var x = 1;
  console.log(x); // 1
}
```

<br />

### But, how about functions ?

함수는 크게 두 가지 표현방식이 있다. (1) 변수에 할당할 때, (2) 함수를 선언하고 선언된 함수명이 곧 변수명일 때.
<br />

We can express function, (1) assign the function in variable, (2) initialize the function and function name is also the variable name.

```javascript
function a () { ... };  // (1)
var b = function () { ... };  (2)
```

<br />
여기서 (1)은 별도의 변수 없이 a라는 식별자로 함수를 바로 선언해서 할당했으므로 아래는 에러가 나지 않는다.
```javascript
console.log(a()); // true
function a () { return true }
```

<br />
하지만 별도의 변수 b에 익명함수를 선언했으므로, 자바스크립트 엔진은 변수명들을 먼저 기록한다고 했으니 아래는 에러가 날 것이다.

```javascript
console.log(b()); // Uncaught TypeError: b is not a function
var b = function() {
  return true;
};
```
