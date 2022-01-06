---
title: "After reading <Functional Reactive Programming>"
date: "2021-10-16"
tags: ["review"]
draft: true
og_description: "FRP를 읽고 내맘대로 정리해보았다."
---

by Stephen Blackheath, Anthony Jones

FRP를 읽고 내맘대로 정리해보았다.

##

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
