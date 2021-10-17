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
