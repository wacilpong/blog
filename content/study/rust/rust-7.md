---
title: "After reading Rust book chapter 7"
date: "2022-05-10"
tags: ["rust"]
draft: false
og_description: "Managing Growing Projects with Packages, Crates, and Modules"
---

- 기능들을 그룹화하고 구현을 캡슐화하는 과정을 통해 코드의 차원을 높일 수 있다.
- 코드의 어떤 부분을 다른 코드를 위해 공개/비공개할지 정해야 한다.
- 이는 스코프(scope)와 관련이 있다.
  - 스코프는 일종의 중첩된 컨텍스트다.
  - 특정 스코프 내에 사용된 중복될 수 없다.
  - 개발자와 컴파일러는 특정 지점의 특정 이름이 변수, 함수, 구조체 등 무엇을 의미하는지 알아야 하므로 스코프가 필요하다.
- 따라서 러스트는 코드의 구조를 관리하기 위한 모듈시스템을 제공한다.
  - `Packages`: 크레이트를 빌드, 테스트, 공유할 수 있는 cargo feature
  - `Crates`: 라이브러리나 실행 파일을 생성하는 모듈들의 트리
  - `Modules and use`: 스코프, 경로에 대한 접근성을 제어할 수 있게 해줌
  - `Paths`: 구조체, 함수, 모듈 등의 이름을 짓는 방식

<br />
<hr />

## Packages and Crates

- 크레이트(Crates)는 하나의 바이너리 혹은 라이브러리다.
  - `crate root`는 러스트 컴파일러가 컴파일을 시작해서 크레이트의 루트 모듈을 만들어 내는 소스 파일이다.
- 패키지(Packages)는 일련의 기능을 제공하는 하나 이상의 크레이트를 의미한다.
  - 패키지는 `Cargo.toml`파일을 통해 그 크레이트를 빌드하는 방법을 명시한다.
  - Cargo.toml에 `src/main.rs`, `src/lib.rs` 파일이 서술되어 있지 않다.
  - **이는 규칙이다: 두 파일은 바이너리/라이브러리 크레이트의 crate root이며, 그 패키지와 같은 이름이다.**
  - **cargo는 라이브러리나 바이너리를 빌드할 때 rustc 컴파일러에게 crate root 파일을 전달한다.**
- 크레이트는 관련 기능들을 하나의 스코프로 묶어서, 그 기능을 여러 프로젝트에서 공유하기 수월해진다.
  _ex. 난수 생성에 사용하는 `rand` 크레이트_
- rand 크레이트에 Rng라는 이름의 트레이트를 제공하지만, 개발자가 그 이름으로 어떤 구조체를 만들어도 된다.
  - 크레이트의 기능은 자신의 스코프 안에 구현되어 있기 때문이다.
  - Rng 트레이트는 `rand::Rng`로 접근하기 떄문이다.
  - 따라서 같은 이름이 있더라도 rand를 의존성으로 추가해도 상관없다.

<br />

## 모듈을 이용한 스코프와 접근성(Privacy) 제어

```rust
// src/lib.rs
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}
        fn serve_order() {}
        fn take_payment() {}
    }
}
```
