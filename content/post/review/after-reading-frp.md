---
title: "After reading <Functional Reactive Programming>"
date: "2022-01-13"
tags: ["review"]
draft: false
og_description: "FRP를 읽고 내맘대로 정리해보았다."
---

by Stephen Blackheath, Anthony Jones

FRP를 읽고 내맘대로 정리해보았다. java 소듐 라이브러리가 주 예제이고, 뒤로 갈수록 소듐 얘기가 너무 많아서 어려워서 날림 읽었지만 rx기반 지식을 나름대로 알 수 있어서 좋았다.

## 기본 개념

> 숲에 있는 나무가 쓰러졌는데 근처의 아무도 그 소리를 듣지 못했다. 과연 그 나무는 소리를 낸 것일까?

- 이것을 실제 세계와 연관 짓는다면 답을 알 수 없지만, FRP에서의 답은 `false`이다.
- FRP는 반응형 프로그래밍을 달성하기 위해 함수형 프로그래밍의 규칙을 따르도록 강제하는 방법론이다.
- 셀(cell)은 시간에 따라 변화하는 값이고, 스트림(stream)은 이벤트의 흐름을 표현한다.
- 옛날 프로그래밍 교과서는 f와 같이 아무 의미가 없는 함수명을 짓지 말라고 가르친다.
- 그러나 함수형 프로그래밍에서 특정 문제와 연관되지 않은 코드는 항상 일반화하기를 바란다.
- 아래는 Rule이라는 클래스명이 다른 함수들의 이름보다 더 목적을 명확히 설명해준다.
  ```java
  class Rule {
    public Rule(Lambda2<Calendar, Calendar, Boolean> f) {
      this.f = f;
    }
    public final Lambda2<Calendar, Calendar, Boolean> f;
    public Cell<Boolean> reify(Cell<Calendar> dep, Cell<Calendar> ret) {
      return dep.lift(ret, f);
    }
    public Rule and(Rule other) {
      return new Rule((d, r) -> this.f.apply(d, r) && other.f.apply(d, r));
    }
  }
  ```
- 스트림을 내보내면 이벤트나 메시지가 프로그램의 한 부분에서 다른 부분으로 전달되고, 그 메시지에는 값이 들어있는데 이를 종종 `페이로드(payload)`라고 부른다.
- `snapshot`의 기본 연산은 스트림 이벤트가 emit된 시점의 셀 값을 캡처한다.
  - 이후 제공받은 함수로 스트림 이벤트의 값과 셀의 값을 합친다.
  - snapshot은 트랜잭션을 시작한 시점의 값을 본다.
  - rxjs에도 유사하게 소스 옵저버블을 다른 옵저버블과 결합해 소스가 emit될 때만 각각의 최신 값을 합쳐주는 withLatestFrom 메서드가 있다.
- 스트림(Stream)으로 모델링하기 적합: _마우스 클릭과 터치스크린 이벤트, 서버와 연결되거나 끊김, 브라우저에서 웹사이트 북마크함 등..._
- 셀(Cell)로 모델링하기 적합: _시간, 온도, GPS좌표, 마우스 포인터의 위치 등..._
- FRP는 상당수의 버그가 만들어지는 일 자체를 방지하지만, 여전히 몇 가지 버그가 있을 수 있다.
  - 호출하는 쪽에서 모듈의 출력값을 사용하는 것을 까먹는 경우가 있다. **일반적으로 어떤 만들어진 값을 사용하지 않는다면 그것은 버그다!**
  - 타입이 동일한 값을 실수로 혼용하는 경우가 있다. FRP코드에는 지역변수가 많은 경우가 자주 있다. 이때는 혼동을 야기할 수 있는 값을 단독으로 담는 컨테이너를 사용하자. 그렇게 하면 값의 의미를 타입에 반영할 수 있다.
- FRP에서는 스트림의 이벤트가 상태 변경을 일으키는 유일한 방법이며, 직접적으로 만들어낼 수 있는 스트림 타입은 아무 이벤트도 발생시키지 않는 never 스트림뿐이다. 따라서 상태를 변경하는 요인은 FRP 시스템의 외부에서 들어올 수밖에 없다. **코드가 오직 (외부)입력에만 반응할 수 있기 때문에 이를 일컬어 반응형 프로그래밍이라고 한다.**
- FRP는 현재 실행 시점에서 구성되기 때문에 JIT(Just In Time) 컴파일러나 실행 시점 최적화에 적합하다.

<br />

#### 조작

- 어떤 이벤트 하나를 새로운 트랜잭션에 넣는 것을 **이벤트를 미룬다(deferring)** 고 말한다.
- 특정 조건에 따라 다른 스트림으로 뻗어나갈 때 사용할 수 있다.
  ```ts
  // rxjs
  defer(() => (liked ? dislikeObservable : likeObservable)).subscribe();
  ```

<br />

#### 참고: 이벤트 처리의 여섯 가지 재앙

> FRP는 이 모든 것들을 해결할 수 있는 방법이다.

1. **예측 불가능한 순서**: _일반적인 UI조작 생각하면 될듯_
2. **첫 번째 이벤트 소실**: _초기화 순서나 처리 순서 때문에 처음 이벤트 캐치못할 때_
3. **지저분한 상태**: _말해 뭐해~_
4. **스레드 문제**: _js는 해당안됨_
5. **콜백 누수**: _어떤 이벤트 소스에 리스너 등록하고 removeListener 호출 까먹었을 때_
6. **의도치 않은 재귀**: _로컬 상태 갱신과 리스너 실행 순서가 반대로 되었을 때_

<br />
<hr />

## 환원주의를 통한 엔지니어링에 대한 접근

```s
1. 복잡한 문제를 가지고 시작한다.
2. 문제를 더 작은 부분으로 나눈다.
3. 각 부분을 해결한다.
4. 해결한 것을 서로 조합해서 전체에 대한 해법을 만든다.
```

- 4번에서 합성성의 오류가 발생할 수 있다.
- 즉 각 독립적인 부분이 참이어도, 전체를 조합하면 거짓일 수 있다.
- FRP는 이벤트 전파를 제공하면서 합성성을 보장한다.
- FRP/함수형 프로그래밍은 합성성(compositionality)을 강제한다.
  - 합성성은 복잡도를 효율적으로 처리해주는 아이디어들, 어떻게 합성할지에 대한 규칙이기도 하다.
  - 이벤트 프로그래밍의 기반에는 이벤트가 발생하면 리스너를 호출하지만,
  - FRP에서는 이벤트를 값의 흐름(스트림)으로 본다.
  - 따라서 각종 콤비네이터(combinator, 고차함수)를 사용해서 값을 어떻게 변환할지 기술한다.
  - _ex) rxjs의 다양한 오퍼레이터들을 생각해보자! combineLatest, mergeMap..._

<br />

## 웹에서의 FRP, feat. rxjs (드디어!)

- `Observable`이라는 인터페이스를 중심으로 하며, 소듐의 Stream에 대응한다.
  - 옵저버블은 값의 시퀀스를 표현한다.
  - 값을 얻으려면 옵저버블을 구독해야 한다.
  - cold observable: 구독 시 즉시 값을 emit한다.
  - hot observable: 이벤트가 발생할 때마다 값을 emit한다.
- `BehaviorSubject`가 소듐의 Cell과 대응한다.
  - 다만, 현재 값이라는 개념을 포함한다.
  - cold 옵저버블로 시작하고 구독하면 현재 값이 콜백에 즉시 전달되고
  - 이후 hot 옵저버블로 바뀌고 상태가 바뀔 때마다 콜백을 통해 갱신된 값을 받는다.
  - startWith()로 줄여쓸 수도 있다.
    ```js
    // ASIS
    const selected = new Rx.BehaviorSubject("cat");
    sSelected.subscribe(selected);
    ```
    ```js
    // TOBE
    const selected = sSelected.startWith("cat");
    ```

<br />

## rxjs로 프로미스 구현하기

- 대부분의 언어에서 I/O 오류는 예외 메커니즘을 통해 처리되지만, FRP는 오직 값만 다룰 수 있기 때문에 일반적인 FRP 코드는 결코 예외를 던지지 않는다.
- Rx를 기반으로 하는 시스템에서는 오류 처리 기능이 내장되어 있다.
- 일반적인 예외는 아니고 내부적으로 그런 오류들은 실제로 그냥 값일 뿐이다.
- I/O 요청마다 별도의 상태를 추적하고 싶을 때 프로미스(promise)를 쓴다.
- **프로미스(promise)는 현재 사용할 수 있거나 미래에 사용할 수 있는 값을 모델링한다.**
- 아래 예시에서 image변수가 초기값이 null인 프라미스로 표현된 값이다. _옛날 js코드이긴 함_
  ```js
  function imagePromise(url) {
    var sLoaded = Rx.Observable.create(function (observer) {
      var img = new Image();
      img.onload = function () {
        observer.onNext(img);
      };
      img.src = url;
    }).publish();
    sLoaded.connect();
    var image = new Rx.BehaviorSubject(null);
    var subscr1 = sLoaded.subscribe(image);
    return {
      image,
      dispose: function () {
        subscr1.dispose();
      },
    };
  }
  ```

<br />

## TMI, 그런데 유우머를 곁들인...

- 마스터 요다의 언어 습관은 우리 같은 범상한 인간과는 다르다. 요다를 따라서 변수와 상수를 비교할 수 있는데, `if (42 == $value) {...}` 처럼 작성하는 것을 요다 조건문이라고 부르기도 한다.
- 컴퓨터 과학에서 퓨처(future), 프로미스(promise), 딜레이(delay), 디퍼드(deferred)는 프로그램 실행을 동기화하려고 쓰는 구조체다. 프록시 역할을 하는 객체로 설명되며 값의 연산이 아직 이루어지지 않은 상태이므로 결과는 미리 알 수 없다.
- 정적 타입 언어로 작성된 FRP코드에서는 수많은 검사를 공짜로 할 수 있다! FRP는 타입 주도 개발과 궁합이 잘 맞는다.
- 오늘 할 리팩터링을 내일로 미루다간 프랑켄슈타인 박사의 괴물을 마주할 것이다. 흠냐!

<br />
