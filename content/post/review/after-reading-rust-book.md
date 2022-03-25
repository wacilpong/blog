---
title: "After reading Rust book"
date: "2022-03-25"
tags: ["review"]
draft: true
og_description: "러스트 언어를 공부해보자."
---

[rust-lang 가이드](https://doc.rust-lang.org/stable/book/)를 독파할 예정이다.

## 1. 시작!

- rust같은 low-level의 언어를 공부하면 아래와 같은 점들을 공부할 수 있다.
  - memory management: 메모리 관리 _ex. ownership_
  - data representation: 모델링 전에 데이터를 어떻게 표현할지
  - concurrency: 동시성 제어
- rust는 저수준 언어지만 사용자성에 있어서는 high-level이며, CLI apps, web servers 등에서 사용될 수 있다.
- rust 컴파일러는 동시성 처리에 관한 버그처럼 애매한 버그들을 잡아주는 문지기 역할을 한다.
- 유용한 툴: [Cargo](https://www.npmjs.com/package/cargo), [Rustfmt](https://github.com/rust-lang/rustfmt), [Rust IDE](https://rls.booyaa.wtf/)
