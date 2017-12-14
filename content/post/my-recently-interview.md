---
title: "My recently junior web developer interview"
date: 2017-12-11
tags: ["web-development", "interview"]
draft: false
---

# what kind of companies?
힙한 분위기를 느끼고 싶어서 스타트업만 건드렸다. 블록체인, 핀테크, 클라우드IDE, AI 등등 다양한 분야의 회사에 신입 개발자로 지원했다. 프론트엔드/백엔드 가릴 것 없이 넣었고, 주로 nodeJs 기반의 회사로 넣었다. 12월 4일부터 12월 8일까지 일주일 간 인터뷰만 보러 다녔다.

I apply to 7 different startups that developing web like blockchain, fintech, cloud IDE, traslating AI, medical AI. The most of them are based on nodeJs. I was an interviewee during 2017. 12. 04 ~ 2017. 12. 08.

# what questions I've got?
1. Thread vs Process
2. Javascript Hoisting
3. Javascript Closure
4. What determines `this` in Javascript?
5. Explain about design pattern
6. The inner logic of node.js
7. What happens when I type the URI in the web browser?
8. Design RDBMS architecture
9. Tell a plan for improving the one of website
10. Explain the mechanism and the scalability of NoSql
11. Objective oriented vs functional paradigm
12. Explain each of these local, session, cookies field
13. Why using API server, not a socket network? even with API is slower!
14. Explain RESTful
15. Coding test - string to integer, find the missing number, DP(Collatz, BFS)
16. Html vs Xhtml
17. Css flex

# Let's solve those questions!
## Thread vs Process
: 먼저, 어플리케이션, 프로세스, 스레드 간의 관계를 알 필요가 있다.<br>
First of all, we must know the relationship among the application, process and thread.

![program](http://2.bp.blogspot.com/-iztLs3xTqWU/Wi4sBc3soxI/AAAAAAAABy8/GtHdXcPMizwow61EPnRnkucGj-qzv7QZwCK4BGAYYCw/s1600/processvsthread.png)

(1) ***Process*** 는 단일스레드와 시작되며, 이를 `primary thread`라고도 한다. 그리고 추후 스레드를 더 생성할 수 있다. 프로세스는 이처럼 적어도 하나의 스레드가 반드시 필요하다.

Process starts with a single thread(`primary thread`), and can create more later. So process has at least one thread.

(2) ***Thread*** 는 computer system에서 프로세서가 시간을 할당하는 최소 실행 단위이다. 이는 다음 실행될 명령어 주소를 가진 프로그램 카운터, 중앙처리장치(CPU)에 빠르게 접근할 수 있는 레지스터들, 고유한 ID를 가진다. 하지만 스레드는 그 자체만으로 프로그램이 아니고, 프로그램 안에서 동작할 수 있다. 모든 스레드는 각자의 메모리를 가지며 시스템 자원에도 접근할 수 있다.

Thread is the smallest unit of execution to which processor allocates time. It consists `program counter, a stack, set of registers`, id. But thread itself is not a program. it can runs within a program. All threads can access to their own memory and system resources.

## Javascript Hoisting
> 일반적으로 호이스팅을 변수가 스코프 맨 위로 올려지는 것으로 말하곤 한다. 하지만 물리적으로 작성한 코드가 스코프 상단으로 옮겨지는 것은 아니다. 자바스크립트는 초기화가 아니라 선언만 상단부로 끌어올려 컨텍스트에 적용한다. 이러한 개념을 호이스팅이라고 한다.

> Javascript only hoists declarations, not initializations. It’s not physically moved to the top of code. This is a term, hoisting.

```
// It gives no error
n = 1;
n + 1;
let n;

// 'b' is undefined in log
let a = 1, b;
console.log(a + " " + b);
b = 2;
```

<br><br>
## Javascript Closure
> 클로저는 `free variables`(어떤 함수의 로컬변수나 매개변수가 아닌 변수를 참조할 때 부르는 변수, 스코프와 연관있는 상대적 개념이므로 global과는 다름)를 참조할 수 있는 함수들로 구성된 일종의 환경이라고 보면 된다. 그러니까, 클로저 환경(범위) 안에 선언된 함수는 그 환경을 기억할 수 있다는 개념이다.

> It is a term like a sort of environment, consists of functions that refer to `free variables`(is a relative to a scope, refers to variables used in a function that are not local variables nor parameters of that function). In other words, the function defined in the closure is able to remember the environment in which it was created.

```
function whoPennywise() {
  function _who() {
    console.log(job);
  }
  let job = "the dancing clown!";

  return _who;
}

let sayItDo = whoPennywise();
sayItDo();  // "the dancing clown!"
```

위에서 **job** 변수는 **_who** 함수와 같은 스코프에 선언되어 참조되고 있다. 따라서 **whoPennywais** 함수는 클로저 환경을 구성하고 있다. 마찬가지로 **sayItDo** 변수는 **whoPennywise** 함수를 참조해 사용했으므로 클로저 환경을 구성한다. 따라서 sayItDo를 실행하면 "the dancing clown!"이 찍힌다. 이때 whoPennywais 함수를 그대로 실행하려고 하면 콘솔에 아무것도 찍히지 않는다. 실행하는 스코프가 클로저 환경이 아니게 되기 때문에 해당 함수객체를 참조하는 셈이 된다.

**job**  variable is referd to **who** function in the same scope. So **whoPennywise** function has an environment called closure. Likewise **sayItDo** variable refers to **whoPennywise** and execute itself, so it is also closure. And then "the dancing clown" wrote in log. At this point, there is nothing in log when execute whoPennywise function as it is, because that scope would not be closure.

```
function foo(a) {
  let b = 3;

  function _bar() {
    return _booq(a + b);
  }

  function _booq(c) {
    return c*2;
  }

  return _bar;
}

let foo2 = foo(2);
let foo5 = foo(5);
console.log(foo2());  // 10
console.log(foo5());  // 16
```

그렇다면 클로저 환경에서는 함수실행이 어떻게 처리되는 지 알아야 하는데, 알다시피 자바스크립트는 단일 스레드 환경이다. 즉, **foo** 함수를 실행하라고 명령을 날리면 한 번의 실행만 한다. 함수 안에 함수가 있다고 해서 여러 번 실행되는 게 아니라는 것이다. 이것이 가능한 이유는 보통 브라우저는 스택을 이용해 실행단위를 처리하기 때문이다. 그래서 **foo** -> **_bar** -> **_booq** 함수 순으로 참조하면서 스택에 차곡차곡 쌓아 리턴(pop)하므로 **_booq** 함수의 리턴값을 최종적으로 가져올 수 있다.

And we have to know the process of executing functions in closure, as you all know, javascript is `single threaded`. That is, one command like executing **foo** function, can be processed at a time. The reason that possible, typically the browser maintain execution context with a stack, the data structure. So, It saves a value in stack and return(pop) with **foo** -> **_bar** -> **_booq** ordering, and finally get the **_booq** function's return value.

<br><br>
## **`this`** in Javascript
> 함수에서의 `this` 키워드는 strict mode와 일반모드에서 다르게 적용된다. 일반적으로 함수가 어떻게 호출하는지에 따라 this의 내용이 달라진다. 전역에서는 모드에 상관없이 전역객체를 참조한다. 즉, 웹브라우저 전역에서의 `this`는 window객체가 된다.

> Function's `this` keyword behaves a bit differently between stric mode and non-stric mode. In most cases, the value of `this` is determined by how a function is called. In global, it refers to global object no matter of mode. That is, `this` in global web-browser is the window object.

```
function test1() {
  return this;
}

function test2() {
  'use strict';
  return this;
}

let obj = { a: 5, b: 2 };
function test3() {
  return this.a + this.b;
}

// All true
console.log(this === window);
console.log(test1() === window);
console.log(test2() === undefined);
console.log(test2().call(this) === window);
console.log(test3().call(obj) === 7);

```

그렇다면 함수가 호출되는 방법에 따라 달라지는 `this`를 알 필요가 있다. test2 함수처럼 strict mode인 함수에서의 this값은 실행될 때 할당되어 유지된다. 따라서 test2 함수는 실행할 때 아무것도 정의하지 않았으므로 undefined을 리턴한다. 이때 자바스크립트의 Function.prototype에서 상속되는 call(), apply() 함수를 이용하면 특정 객체와 `this`를 연결할 수 있다. 그래서 test2에 전역의 this(window)를 보내 함수를 실행시키면 window를 리턴하게 된다. 마찬가지로 test3 함수에 obj라는 특정 객체를 보내 실행시키면 함수 내부에서 해당 객체를 `this`로 참조할 수 있게 된다.

Then how `this` can be different when call the function? The return value of the function in strict mode like test2 function will be assigned in execution. So test2 function returns undefined, because nothing was defined in execution. At this point, It is possible to connect specific object to `this` with call() and apply(), that inherited from Function.prototype in javascript. Thus, test2 function with `call(this)` will return window. Likewise, `this` keyword in test3 function can refers to the `obj`(object) with `call(obj)`.


```
let me = { name: 'roomy' };

function myName() {
  return this.name;
}

me.callName = myName;
console.log(me.callName()); // roomy
```

또한 `this`는 객체에서의 호출되는 방법에 따라 바뀔 수 있다. 객체(me) 내부에 함수(myName)를 정의하고 프로퍼티(callName)로 부르면 해당 객체 환경을 `this`로 참조하는 것을 볼 수 있다. 즉, `this`의 동작방식은 함수가 정의된 방법이나 위치가 아닌 호출방식에 영향을 받는다.

Also targets of `this` can be changing according to the method of calling `this` in object. It refers to the object's environment after defining `myName` function in `me` object that called with `callName` property. That is, `this` behavior is not at all affected by how or where the function was defined. Like upper example, It matters only that the function was invoked from `callName` member of `me`.
