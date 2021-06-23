---
title: "After reading <Effecttive Typescript>"
date: "2021-06-23"
tags: ["review"]
draft: true
og_description: "이펙티브 타입스크립트를 읽고 내맘대로 정리해보았다."
---

by Dan Vanderkam

- 모든 자바스크립트는 타입스크립트지만, 그 반대는 성립되지 않는다.
- js를 ts로 전환하는게 아니면 `noImplicitAny`를 설정하는 것이 좋다.
- "undefined is not an object"같은 런타임 오류 방지를 위해 `strictNullChecks`를 설정하는 것이 좋다.
- 타입스크립트 컴파일러는 두 가지 역할이 있으며, 이 둘은 완전히 독립적으로 수행된다.
  - 최신 ts/js를 브라우저에서 동작할 수 있게 구버전 js로 트랜스파일(transpile)한다.
  - 코드의 타입 오류를 체크한다.