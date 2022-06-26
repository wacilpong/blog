---
title: "After reading Rust book chapter 11"
date: "2022-06-24"
tags: ["rust"]
draft: true
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
  - tests 모듈은 내부 모듈이므로 외부 모듈의 테스트에 해당하는 코드(1)를 스코프로 가져와야 한다.
  - 이제 외부 모듈에서 정의한 모든 항목을 해당 테스트 모듈에서 사용할 수 있다.
- `assert!` 매크로는 불리언 값을 반환한다.
- (1), (2) 테스트의 assert! 표현식은 true를 반환하고 테스트는 pass한다.
- (1-1)로 테스트해보면 부등호가 바뀌었기 때문에 제대로 동작하지 않고, 테스트는 실패한다.

<br />

### Testing Equality with the assert_eq! and assert_ne! Macros
