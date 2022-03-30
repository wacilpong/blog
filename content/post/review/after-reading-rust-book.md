---
title: "After reading Rust book"
date: "2022-03-25"
tags: ["review"]
draft: false
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
- 설치:
  ```sh
  $ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  $ rustc --version
  ```
  - `rustup`(OS에 상관없이 손쉽게 rust를 설치하게 해주는 도구)
- **Hello world 찍어보기**
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
- **`Cargo`: rust 빌드시스템이자 패키지 매니저 dependency**
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

## 2. Guessing game 만들어보기

- 입출력 붙이기

  ```rust
  use std::io;

  fn main() {
      println!("Guess the number!");
      println!("Please input your guess.");

      let mut guess = String::new();

      io::stdin()
          .read_line(&mut guess)
          .expect("Failed to read line");

      println!("You guessed: {}", guess);
  }
  ```

  - io는 [prelude: rust standard library](https://doc.rust-lang.org/std/prelude/index.html)에 있다.
  - rust에서 모든 변수는 불변(immutable)한 것이 기본이다.
  - rust에서 변수를 가변적으로 사용하려면 변수명 앞에 `mut`를 선언한다.
  - `::`는 뒤의 함수가 앞쪽에 연관되어 있음을 의미하는 문법이다.
  - `String::new()`는 스트링 타입의 인스턴스를 생성하며, new는 여러 타입을 생성할 수 있는 보편적인 이름의 함수이다.
  - `&`은 해당 argument가 reference임을 의미하며, 참조는 기본적으로 불변하다.
  - 따라서 해당 예제에서는 **가변적이어야 하므로 &guest가 아닌 &mut guess이다.**
  - read*line 메서드는 `io::Result` 타입을 반환하기도 하는데, enum으로 Ok와 Err값이 있다. expect 메서드를 통해 Result타입에 대응하고 에러인 경우 프로그램을 종료시킨다. \*에러에 대한 복구방법은 9장에서 다룸*
  - println! 메서드의 `{}`는 값을 대입할 공간 역할을 하며 여러개도 가능하다.

- crate: Rust Package Registry 써보기
  - Cargo.toml `[dependencies]` 하위에 [rand](https://crates.io/crates/rand)를 명시한다.
  - 이때 cargo는 dependencies에 리스팅된 crate들을 다운받는데, rand가 의존하는 다른 crate들까지 가져온다.
  - `Cargo.lock` 파일을 통해 의존성들에 특정 버전을 고정시킬 수 있다.
  - `cargo update` 명령어를 통해 lock파일을 무시하고 의존성의 마이너 버전상 가장 최신으로 업데이트한다.
- 1 ~ 100 랜덤숫자 부여하기

  ```rust
  use std::io;
  use rand::Rng;

  fn main() {
      println!("Guess the number!");

      let secret_number = rand::thread_rng().gen_range(1..101);

      println!("The secret number is: {}", secret_number);

      println!("Please input your guess.");

      let mut guess = String::new();

      io::stdin()
          .read_line(&mut guess)
          .expect("Failed to read line");

      println!("You guessed: {}", guess);
  }
  ```

  - Rng는 Random number generator이다.
  - `start..end`에서 end는 초과를 의미하므로, 1..=100라고 써도 같다.
  - 참고로 `cargo doc --open` 명령어를 통해 패키지와 사용된 의존성에 관한 문서를 확인할 수 있다.
