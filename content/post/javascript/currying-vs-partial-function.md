---
title: "Partial function and currying in javascript"
date: "2020-02-09"
tags: ["javascript"]
draft: false
og_description: "부분함수는 어떤 함수의 arguments에서 일부를 고정하여 원래 함수를 반환하는 함수이다. 즉, 함수를 체이닝하기 때문에 함수를 재활용하는 데 활용할 수 있겠다."
---

## Partial Function

```javascript
const sum = (a, b) => a + b;
const sum10 = sum.bind(null, 10);

sum10(5); // 15
```

부분함수는 어떤 함수의 arguments에서 일부를 고정하여 원래 함수를 반환하는 함수이다. 즉, 함수를 체이닝하기 때문에 함수를 재활용하는 데 활용할 수 있겠다. 위 예시의 `sum10`은 `sum`함수에서 argument 하나를 10으로 고정하여, 무조건 10과 첫번째 parameter의 합이 반환되는 부분 함수이다.

---

## currying

```javascript
const sum = a => b => a + b;

sum(5)(2); // 7
```

커링은 여러 개의 arguments를 단일로 처리하는 함수를, 여러 번 call하는 프로세스 형태로 바꾸는 기법이다. 따라서 위 예시의 `sum`은 커링이 적용된 함수이다. 함수호출 특성상 모든 호출이 끝난 후에 함수실행이 종료되므로, 지연시켜서 실행해야 하거나 내부에서 어떠한 값을 memoization해야 하는 경우에 사용할 수 있겠다.

<br />

```javascript
const curry = func =>
  function _curry(...args) {
    if (args.length >= func.length) return func.apply(this, args);
    return (...args2) => _curry.apply(this, [...args, ...args2]);
  };
const log = (date, type, message) =>
  console.log(`${date.getHours()}:${date.getMinutes()}, ${type}, ${message}`);

curry(log)(new Date())("INFO", "roomy is studying now");
curry(log)(new Date())("INFO")("roomy is studying now");
curry(log)(new Date(), "INFO", "roomy is studying now");
```

위 예시의 `curry`함수는 함수를 받은 후에 해당 함수의 arguments를 다중 호출하여 넘길 수 있도록 바꾸어주는, 즉 받은 함수를 커리된 함수로 만들어주는 함수이다. 또한 다중 호출하지 않더라도 넘겨받는 함수의 고정된 arguments의 길이를 기억하고 있으므로 여러 인자를 넘겨도 동일한 효과를 낸다.

<br />

```javascript
const curryN = (func, ...args) =>
  function(...args2) {
    if (args2.length) return curryN(func, ...args, ...args2);
    return func(...args);
  };
const sumN = (...args) => args.reduce((acc, cur) => acc + cur, 0);
const sumFunction = curryN(sumN)(10)(10, 5)(5);

sumFunction(); // 30
```

만약 arguments가 얼마나 올지 모른다면,`curryN` 함수처럼 N개의 arguments를 만났을 때 처음에 넘어왔던 arguments들과 합치는 과정을 재귀로 반복하여 구현해볼 수 있다. 그리고 아무 값도 넘기지 않고 `커링이 적용된 func`를 호출할 때만 비로소 넘겨받은 `func`를 호출하도록 한다.
