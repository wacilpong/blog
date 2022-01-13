---
title: "After reading <Functional Reactive Programming>"
date: "2022-01-13"
tags: ["review"]
draft: false
og_description: "FRP를 읽고 내맘대로 정리해보았다."
---

by Stephen Blackheath, Anthony Jones

FRP를 읽고 내맘대로 정리해보았다.

## -

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

<br />

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
    const slected = sSelected.startWith("cat");
    ```
