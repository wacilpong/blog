---
title: "After reading Rust book chapter 11"
date: "2022-06-24"
tags: ["rust"]
draft: false
og_description: "Writing Automated Tests"
---

- 러스트의 타입 시스템은 모든 종류의 incorrectness를 잡을 수 없다.
- 2를 더한 값을 반환하는 add_two 함수가 있을 때, 러스트는 이 함수가 의도한대로 동작하는지 알 수 없다.
- 따라서 테스팅 과정이 필요하다.

<br />

## How to Write Tests

- Set up any needed data or state.
- Run the code you want to test.
- Assert the results are what you expect.

<br />

### The Anatomy of a Test Function

```rust
// (1) success
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
```

```rust
// (2) Fail
#[cfg(test)]
mod tests {
    #[test]
    fn exploration() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn another() {
        panic!("Make this test fail");
    }
}
```

- `#[test]`가 붙는 함수는 테스트 함수를 의미한다.
- 각각의 테스트는 새로운 스레드에서 수행된다.
- 테스트 코드가 수행되던 스레드가 죽으면 메인 스레드는 실패로 표시한다.
- (2)의 경우 ok 대신 `tests::another...FAILED`이 뜬다.

<br />

### Checking Results with the `assert!` Macro

```rust
// (1)
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

```rust
// (1-1)
impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width < other.width && self.height > other.height
    }
}
```

```rust
// (2)
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn larger_can_hold_smaller() {
        let larger = Rectangle {
            width: 8,
            height: 7,
        };
        let smaller = Rectangle {
            width: 5,
            height: 1,
        };

        assert!(larger.can_hold(&smaller));
    }
}
```

- `super::*`
  - tests 모듈은` 내부 모듈이므로 외부 모듈의 테스트에 해당하는 코드(1)를 스코프로 가져와야 한다.
  - 이제 외부 모듈에서 정의한 모든 항목을 해당 테스트 모듈에서 사용할 수 있다.
- `assert!` 매크로는 불리언 값을 반환한다.
- (1), (2) 테스트의 assert! 표현식은 true를 반환하고 테스트는 pass한다.
- (1-1)로 테스트해보면 부등호가 바뀌었기 때문에 제대로 동작하지 않고, 테스트는 실패한다.

<br />

### Testing Equality with the assert_eq! and assert_ne! Macros

- `assert_eq!`는 전달된 두 인자 값이 같아야 성공이며, `assert_ne!`는 그 반대이다.
- 두 매크로는 디버그 형식을 이용해 전달된 인수를 출력한다.
  - 매크로에 전달된 값들은 `PartialEq`와 `Debug` 트레이트를 구현해야 한다.
  - Primitive Types와 표준 라이브러리가 제공하는 타입들은 두 트레이트를 구현하고 있다.
  - 직접 선언한 구조체와 열거자는 개발자가 직접 두 트레이트를 구현해야 한다.
    _`#[derive(PartialEq, Debug)]` 어노테이션 추가_

<br />

### Adding Custom Failure Messages

```rust
pub fn greeting(name: &str) -> String {
    String::from("안녕하세요!")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greeting_contains_name() {
        let result = greeting("캐롤");
        assert!(
					result.contains("캐롤"),
					"Greeting 함수의 결과에 이름이 포함되어 있지 않음. 결과값: '{}'", result
				);
    }

}
```

```rust
running 1 test
test tests::greeting_contains_name ... FAILED

failures:

---- tests::greeting_contains_name stdout ----
thread 'tests::greeting_contains_name' panicked at 'Greeting 함수의 결과에 이름이 포함되어 있지 않음. 결과값: '안녕하세요!'', src/lib.rs:12:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    tests::greeting_contains_name

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

- assert!, assert_eq!, assert_ne! 매크로는 실패 메세지를 사용자 정의로 추가할 수 있다.
- 위 코드는 assert! 매크로에서의 사용자 정의 실패 매세지이다.

<br />

### Checking for Panics with should_panic

```rust
pub struct Guess {
    value: u32
}

impl Guess {
    pub fn new(value: u32) -> Guess {
        if value < 1 {
            panic!("반드시 100보다 작거나 같은 값을 사용해야 합니다. 지정된 값: {}", value)
        } else if value > 100 {
            panic!("반드시 1보다 크거나 같은 값을 사용해야 합니다. 지정된 값: {}", value);
        }

        Guess {
            value
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic(expected="반드시 100보다 작거나 같은 값을 사용해야 합니다.")]
    fn greater_than_100() {
        Guess::new(200);
    }
}
```

```rust
running 1 test
test tests::greater_than_100 - should panic ... FAILED

failures:

---- tests::greater_than_100 stdout ----
thread 'tests::greater_than_100' panicked at '반드시 1보다 크거나 같은 값을 사용해야 합니다. 지정된 값: 200', src/lib.rs:10:13
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
note: panic did not contain expected string
      panic message: `"반드시 1보다 크거나 같은 값을 사용해야 합니다. 지정된 값: 200"`,
 expected substring: `"반드시 100보다 작거나 같은 값을 사용해야 합니다."`

failures:
    tests::greater_than_100

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

- `should_panic`은 패닉이 발생하면 테스트 성공, 패닉이 발생하지 않으면 테스트 실패이다.
- 위 코드는 개발자 의도대로 패닉은 발생했지만, 의도한 문자열과 다른 메세지 결과가 출력된다.
- expected로 패닉 메세지를 지정할 수 있기 때문이다.
- should_panic을 통해 버그가 발생한 위치를 파악하기 쉽다.

<br />

### Using Result<T, E> in Tests

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("two plus two does not equal four"))
        }
    }
}
```

<br />
<hr />

## Controlling How Tests Are Run

- `cargo test`
  - 테스트 모드의 코드를 컴파일하고, 결과 테스트 바이너리를 실행한다.
  - 기본 동작은 모든 테스트를 병렬로 실행한다.
  - 테스트가 실행되는 동안 출력 결과를 모아 테스트 결과 한 곳에 보여준다.
  - 옵션
    - cargo test 명령에 적용되는 옵션
      (`cargo test —help` 옵션을 통해 옵션 확인)
    - 결과 테스트 바이너리의 생성에 적용되는 옵션: 구분자 — 다음에 나열됨
      (`cargo test —- —help` 옵션을 통해 옵션 확인)

<br />

### 테스트를 병렬/직렬로 실행하기

- thread를 이용해 병렬 실행한다.
  - 테스트를 더 빨리 실행해서 코드 결과를 빠르게 받을 수 있는 장점!
  - 병렬 테스트 시 공유되는 변수, 디렉토리가 다른 thread에 의해 방해 받을 수 있는 단점
- 테스트를 직렬로 실행하기: `cargo test -- —-test-threads=1`

<br />

### 함수의 결과 보여주기

- 기본: 테스트 라이브러리에서는 테스트 성공 시 표준 출력에 아무것도 출력하지 않는다. ex) println!
  - 테스트 실행기가 테스트 성공 시 println!의 출력은 가로챈다.
- 성공한 테스트의 출력값도 확인하기: `cargo test -- --nocapture`
- `—-nocapture` 플래그 실행 결과

  ```bash
  # ▶︎ 테스트가 병렬로 실행되어 문자열 출력 순서가 뒤섞임
  running 2 tests
  입력값: 8
  입력값: 4
  thread 'tests::this_test_will_fail' panicked at 'assertion failed: `(left == right)`
    left: `5`,
   right: `10`', src/lib.rs:19:9
  note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
  test tests::this_test_will_pass ... ok
  test tests::this_test_will_fail ... FAILED

  failures:

  failures:
      tests::this_test_will_fail

  test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
  ```

  ```bash
  # ▶︎ -—nocapture -—test-threads=1 실행 결과
  running 2 tests
  test tests::this_test_will_fail ... 입력값: 8
  thread 'main' panicked at 'assertion failed: `(left == right)`
    left: `5`,
   right: `10`', src/lib.rs:19:9
  note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
  FAILED
  test tests::this_test_will_pass ... 입력값: 4
  ok

  failures:

  failures:
      tests::this_test_will_fail

  test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
  ```

<br />

### 이름을 이용해 테스트 일부만 실행하기

- 하나의 테스트만 실행하기: `cargo test {테스트 함수 이름}`
- 여러 테스트 실행하기: `cargo test {테스트 이름의 일부 지정}`
- 지정된 이름에 일치하는 모든 테스트를 실행한다.

<br />

### 명시적으로 요청하지 않은 테스트 제외하기

- 특정 테스트만 제외하고 테스트를 실행하고 싶을 때: `#[test]` 다음에 `#[ignore]` 특성을 추가함
- 제외된 테스트만을 실행하고 싶을 때: `cargo test —- -—ignored`

<br />
<hr />

## Test Organization

<br />

### 단위 테스트 (unit test)

- 하나의 모듈을 독립적으로 테스트함, private 함수 테스트 가능, 라이브러리를 별개로 테스트하는 방법
- 코드가 의도적으로 동작하는지 빠르게 판단
- `#[cfg(test)]` 특성
  - cargo test 명령을 실행할 때만 코드를 컴파일하고 실행하라는 의미
  - cargo build 에서는 테스트 모듈의 코드가 컴파일되지 않음.
  - 통합 테스트는 다른 디렉터리에 작성하므로 해당 특성 필요하지 않지만,
    단위 테스트에서는 같은 파일에 작성하므로 테스트 코드가 컴파일 결과에 포함되지 않도록 해당 특성 지정 필요함.
  - cfg: configuration 설정의 약자
  - cargo는 cfg 특성을 이용해 cargo test 명령을 실행할 때만 테스트 코드를 컴파일함.
- private 함수의 테스트
  - 러스트에서는 private 함수의 테스트를 허용함
  - 테스트 함수 내에서 private 함수 접근 가능

### 통합 테스트 (integration test)

- 다른 모듈과 함께 라이브러리를 테스트하는 방법, public 함수만 테스트 가능
- 라이브러리가 올바르게 동작하는 지 확인하는 목적이므로 coverage가 중요함
- tests 디렉토리

  - 최상위 레벨에 생성
  - 각 파일은 별개의 크레이트로 컴파일됨
  - 통합 테스트 실행 결과

  ```bash
  # ▶︎ 단위 테스트 결과
  running 1 test
  test tests::internal ... ok

  test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

  # ▶︎ 통합 테스트 시작
       Running tests/integration_test.rs (target/debug/deps/integration_test-66e2bf000b052bec)

  running 1 test
  test it_adds_two ... ok
  # ▶︎ 통합 테스트 각 테스트 함수 결과
  test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
  # ▶︎ 통합 테스트 전체 결과
     Doc-tests adder

  running 0 tests

  test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
  ```

  - 특정 통합 테스트만 실행하기: `cargo test -—test {통합 테스트 파일명}`

- 통합 테스트의 서브 모듈
  - tests 하위에 서브 디렉토리를 추가하면 해당 위치의 파일들은 별개의 크레이트로 컴파일되지 않는다.
  - 별도의 테스트 섹션으로 작성하지 않고, 테스트에 공유되어야 하는 코드들을 작성해야할 때 유용하게 사용함. ex) `common::setup()`
- 바이너리 크레이트의 단위 테스트
