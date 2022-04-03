---
title: "After reading Rust book capter 1"
date: "2022-03-25"
tags: ["rust"]
draft: false
og_description: "After reading Rust book capter 1"
---

## 시작!

- rust같은 low-level의 언어를 공부하면 아래와 같은 점들을 공부할 수 있다.
  - **memory management**: 메모리 관리 _ex. ownership_
  - **data representation**: 모델링 전에 데이터를 어떻게 표현할지?
  - **concurrency**: 동시성 제어
- rust는 저수준 언어지만 사용자성에 있어서는 high-level, CLI apps나 web servers 등에서 사용될 수 있다.
- rust 컴파일러는 동시성 처리에 관한 버그처럼 애매한 버그들을 잡아주는 문지기 역할을 한다.

<br />

## 유용한 툴

- [Cargo](https://www.npmjs.com/package/cargo), [Rustfmt](https://github.com/rust-lang/rustfmt), [Rust IDE](https://rls.booyaa.wtf/)
- 설치:
  ```sh
  $ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  $ rustc --version
  ```
  - `rustup`(OS에 상관없이 손쉽게 rust를 설치하게 해주는 도구)

<br />

## Hello World!

```rust
// main.rs
fn main() {
  println!("Hello, world!");
}
```

```sh
$ rustc main.rs
$ ./main
```

- `main()` 함수는 언제나 모든 rust 프로그램을 실행할 때 동작하는 첫번째 코드다!
- rust 스타일에서 들여쓰기는 tab이 아닌 space이다.
- `!`로 함수를 호출하면 rust macro를 의미한다. _매크로는 19장에서 다룸_
- `rustc`는 컴파일러 명령어이다.
- **rust는 ahead-of-time compiled 언어**이므로, 기계어와 무관하게 중간언어 형태로 컴파일한 후에 프로그램을 실행하는 주체가 rust를 설치하고 있지 않아도 실행할 수 있게 한다.

<br />

## `Cargo`: rust 빌드시스템이자 패키지 매니저 dependency

```sh
$ cargo new hello_cargo
$ cd hello_cargo
```

```sh
$ cargo build
$ cargo run
$ cargo check
$ cargo build --release
```

- cargo는 rust를 설치하면 자동으로 설치된다.
- 설정 파일은 `.toml (Tom’s Obvious, Minimal Language)` 포맷이다.
- carge check는 build 명령어와 달리 실행가능한 상태로 배포하는 과정이 없기 때문에 더 빠르므로, 단순히 컴파일이 잘 되는지 체크할 때 유용하다.
- 빌드버전의 프로그램은 target/debug 디렉토리에 저장된다.
- release 옵션으로 배포버전 빌드하면 target/release 디렉토리에 저장된다.
