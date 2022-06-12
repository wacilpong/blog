---
title: "After reading Rust book chapter 9"
date: "2022-06-12"
tags: ["rust"]
draft: false
og_description: "Error Handling"
---

- 에러 발생 가능성을 인지하고 개발자가 코드를 컴파일하기 전에 에러를 처리하도록 유도한다.
- 다른 언어에서는 에러 구분없이 exception으로 처리한다.
- 러스트는 recoverable 에러와 unrecoverable 에러로 구분한다.

<br />
<hr />

## 에러의 종류

#### **1. recoverable error**

```rust
enum Result<T, E> {
	Ok(T),
	Err(E),
}
```

- ex. 파일 열기를 시도했으나 존재하지 않는 파일일 때
- `Result<T, E>` 타입으로 표현한다.
- 이때 T는 작업이 성공한 경우 Ok값에 포함될 값의 타입, E는 Err값에 포함될 값의 타입이다.
- **Result enum은**
  - (1) 러스트의 타입 시스템을 통해 작업이 실패할 수도 있음을 알린다.
  - (2) 실패할 경우 프로그램을 회복할 기회를 제공한다.
  - (3) 작업이 성공한 경우와 실패한 경우 모두 처리하도록 유도할 수 있다.

<br />

#### **2. unrecoverable error**

- ex. 배열의 범위를 벗어나는 메모리에 대한 접근
- 항상 버그의 가능성을 내포하고 있는 에러를 의미한다.
- `panic! 매크로`: unrecoverable 에러가 발생한 프로그램의 실행을 종료한다.
- 프로그램이 제대로 처리할 수 없는 비정상적인 상태에 놓였다는 것을 알려준다.
- 유효하지 않거나 잘못된 값을 계속 사용하지 못하도록 프로세스를 종료한다.

<br />

## Unrecoverable Errors with `panic!` 매크로

```rust
// (1) panic! 매크로 직접 호출하기
fn main() {
    panic!("crash and burn");
}
```

```rust
// (2) panic! 발생하는 예:
// 벡터의 크기를 벗어난 인덱스로 값을 읽는 경우
fn main() {
  let v = vec![1,2,3];

  v[99];
}
```

- 패닉이 발생하면 프로그램은 스택을 풀어주거나 취소한다.
- **스택 풀어주기(unwind)**
  - 스택을 역순으로 순회하며 각 함수에 전달되었던 데이터를 정리한다.
  - 하지만 이를 위해 실행되는 작업의 양은 어마어마하다.
- **스택을 즉시 취소**
  - 스택을 정리하지 않고 애플리케이션을 종료한다.
  - 이 경우 사용하던 메모리는 그냥 운영체제가 정리하게 된다.
  - 릴리즈 모드에서 패닉을 취소하게 하려면 `Cargo.toml`에 아래처럼 작성한다.
    ```yml
    [profile.release]
    panic = 'abort'
    ```
- 러스트는 보안을 위해 존재하지 않는 인덱스의 값을 읽으려고 하면 실행을 중단한다.
- C언어에서는 버퍼 오버리드(buffer overread)가 사용된다.
  - 인덱스로 지정한 위치의 메모리가 벡터가 관리하는 메모리가 아니더라도 벡터에 저장된 값에 해당하는 위치의 메모리에 저장된 값을 리턴한다.
  - 이런 방법은 보안상의 취약점이 되기 쉬운데, 공격자가 인덱스를 조작해서 값을 읽을 수 있다.
- **panic! 역추적 활용**
  - 라이브러리에서 panic! 매크로가 호출되는 경우 역추적(backtrace)으로 문제를 찾을 수 있다.
  - 역추적이란 그 지점까지 호출된 모든 함수의 목록이다.
  - note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace.

<br />
<hr />

## Recoverable Errors with `Result` enum

#### match 표현식을 이용해 리턴된 Result 타입의 리턴값 처리

```rust
use std::fs::File;

fn main() {
  // f: Result<File, std::io::Error>
  let f = File::open("hello.txt");

  let f = match f {
      Ok(file) => file,
      Err(error) => {
          panic!("파일 열기 실패: {:?}", error);
      }
  };
}
```

- 변수 f: `File::open` 함수의 실행
  - 성공하면 파일의 핸들(파일을 읽거나 쓸 수 있음)을 저장한 Ok 열거값이 된다.
  - 실패하면 에러 정보를 담고 있는 Err 열거값이 된다.
- Result 열거자와 값이 prelude에 의해 자동으로 임포트된다.
- 파일이 없는 경우 에러 메시지는 다음과 같다.
  - _thread 'main' panicked at '파일 열기 실패: Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/main.rs:10:13_

<br />

#### match 표현식으로 여러 종류의 에러 처리하기

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
  // f: Result<File, std::io::Error>
  let f = File::open("hello.txt");

  /**
    * 파일 열기 시도 실패 시
    * => error.kind가 NotFound 인지 확인
    * => 파일 생성 => 파일 생성 성공 / 실패 따른 처리
    */
  let f = match f {
      Ok(file) => file,
      Err(ref error) => match error.kind() {
          ErrorKind::NotFound => match File::create("hello.txt") {
              Ok(fc) => fc,
              Err(e) => panic!("파일을 생성하지 못했습니다: {:?}", e),
          },
          other_error => panic!("파일을 열지 못했습니다: {:?}", other_error),
      },
  };
}
```

- Err 열거값(Result::Err)에 저장된 타입은 표준 라이브러리 구조체인 io::Error
- `kind` 메서드: io::ErrorKind enum 타입을 반환한다.
- io::ErrorKind enum은 `ErrorKind::NotFound`처럼 다양한 종류의 오류를 표현한다.
- [ref keyword](https://doc.rust-lang.org/std/keyword.ref.html): 패턴 매칭 중에 참조로 바인딩되고, move가 아니라 borrow된다.

<br />

#### Result::unwrap()

```rust
use std::fs::File;

fn main() {
  let f = File::open("hello.txt").unwrap();
}
```

- match 표현식과 같은 동작을 하는 shortcut 메서드이다.
- Result 타입의 값이 Ok이면 저장된 값을 반환하고, Err라면 panic! 매크로를 호출한다.
- 에러메시지
  - _thread 'main' panicked at 'called Result::unwrap() on an Err value: Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/main.rs:4:37_

<br />

#### Result::expect()

```rust
use std::fs::File;

fn main() {
  let f = File::open("hello.txt").expect("파일을 열 수 없습니다.");
}
```

- panic! 매크로에 에러 메시지를 전달한다.
- 에러 메시지와 함께 panic! 매크로를 호출한다.
- 에러메시지:
  - _thread 'main' panicked at '파일을 열 수 없습니다.: Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/main.rs:4:37_

<br />
<hr />

## 에러 전파하기

#### **1. return Err(e)**

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn main() {
  fn read_username_from_file() -> Result<String, io::Error> {
      let f = File::open("hello.txt");
      let mut f = match f {
          Ok(file) => file,
          Err(e) => return Err(e), // 함수 실행 조기 중단, 에러값을 호출자에 리턴
      };
      let mut s = String::new();
      // read_to_string: 파일의 내용을 변수에 기록, Result 타입 리턴
    match f.read_to_string(&mut s) {
          Ok(_) => Ok(s),
          Err(e) => Err(e), // 함수의 마지막 표현식이므로 return 키워드 명시 X
      }
  }
}
```

- return 키워드로 함수를 조기 중단하고 에러값을 반환한다.

<br />

#### **2. ? 연산자**

```rust
fn read_username_from_file() -> Result<String, io::Error> {
		// ok, err값을 다르게 처리하면서 에러발생시 에러를 반환하고 종료
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
}
```

- match 표현식과 비슷하다.
- 에러가 발생하면 조기에 return 가능하다. (return Error)
- Result 값이 Ok면 Ok값에 저장된 값을 반환, 프로그램이 계속 실행된다.
- Err이면 Err값이 전체 함수의 반환값이 되고 호출자로 에러가 전파된다.

<br />
<hr />

## 언제 panic! 매크로를 사용하는가?

- 실패할 가능성이 있는 함수는 대체로 Result 타입 리턴을 권장한다.
- 호출자가 회복을 시도하거나 회복할 수 없다면 panic! 매크로를 호출한다.
- **실패할 가능성이 없어도 Result값을 모두 처리하는 게 낫다.**
  - Err 값이 반환될 리 없다고 확신하는 상황이어도, unwrap 메서드를 호출하자.
    ```rust
    use std::net::IpAddr;
    let home: IpAddr = "127.0.0.1".parse().unwrap();
    ```
- 1에서 100 사이의 값인지 검사하기 위한 커스텀 타입 예시

  ```rust
  // 구조체 정의
  pub struct Guess {
      value: i32,
  }

  impl Guess {
      // new 연관 함수 구현
      pub fn new(value: i32) -> Guess {
          if value < 1 || value > 100 {
              panic!("Guess value must be between 1 and 100, got {}.", value);
          }

          Guess { value }
      }

      // 자신의 값을 대여해 u32 타입의 값 리턴
      // getter: 구조체의 필드에서 값을 가져와 리턴
      pub fn value(&self) -> i32 {
          self.value
      }
  }
  ```

  - 라이브러리 코드에서 패닉을 발생시킬 때 유효성 검사를 반드시 거치도록 할 수 있다.
  - 모듈 외부 코드가 `Guess:new` 함수를 이용해 인스턴스를 생성하게 함으로써 유효성 체크를 거친다.
