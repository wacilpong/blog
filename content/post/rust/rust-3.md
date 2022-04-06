---
title: "After reading Rust book chapter 3"
date: "2022-04-05"
tags: ["rust"]
draft: false
og_description: "Common Programming Concepts"
---

## Variables and Mutability

### (1) let

```rust
fn main() {
    let x = 5;
    println!("The value of x is: {}", x);
    x = 6;
    println!("The value of x is: {}", x);
}
```

- rust에서 모든 변수는 기본적으로 불변하며, 안전하고 쉬운 코드를 작성하기 위함이다.
- 위 코드는 `cannot assign twice to immutable variable`에러와 함께 컴파일되지 않는다. _`help: consider making this binding mutable: mut x`라는 친절한 팁과 함께..._
- rust는 컴파일러 차원에서 불변하다고 선언한 값은 변경할 수 없도록 보장하기 때문에 특정 변수의 값이 언제 어디서 바뀌는지 일일이 추적할 필요가 없다.
- 위 에러는 x 변수에 `mut` 키워드를 추가해 해결할 수 있다.
- 매번 복사하고 새로운 인스턴스를 반환해야할 때에는 가변형이 유용하다.

<br />

### (2) constants

```rust
const MAX_POINTS: u32 = 100_000;
```

- 변수와 달리 `mut` 키워드를 사용할 수 없다.
- **let에 값을 할당하면 묵시적으로 타이핑되던 것과 달리, 할당할 값의 타입을 반드시 지정해야 한다.**
- 함수 호출의 결과값이나 런타임 연산으로 받은 값을 사용할 수 없다.
- rust는 상수 이름에 대문자만 사용하며, 단어 사이에 밑줄을 추가한다.

<br />

## Shadowing

```rust
fn main() {
    let x = 5;

    let x = x + 1;

    {
        let x = x * 2;
        println!("The value of x in the inner scope is: {}", x);
    }

    println!("The value of x is: {}", x);
}
```

```rust
// O
let spaces = "   ";
let spaces = spaces.len();

// X (mismatched types)
let mut spaces = "   ";
spaces = spaces.len();
```

- 첫번째 코드의 x는 12이다.
- 두번째 코드처럼 shadowing을 통해 동일한 이름의 변수를 다른 타입으로 사용할 수 있다.

<br />
<hr />

## Data Types

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

: 문자열을 숫자 타입으로 변환할 때처럼 여러 타입을 사용해야 한다면 type annotation을 통해 타입을 명시한다.

<br />

### (1) 스칼라(Scarlar) 타입

- 하나의 값을 표현하는 타입이다.
- 정수(integers), 부동 소수점 숫자(floating-point numbers), 불리언(Booleans), 문자열(characters)

    <br />

  #### 정수, 부동 소수점

  ```rust
  fn main() {
      let x = 2.0; // f64
      let y: f32 = 3.0 // f32
  }

  ```

  - 부호가 있으면 i로, 없으면 u로 시작한다. _ex. `i32`, `u32`_
  - 부호가 없고 있음의 차이는 음수를 저장할 수 있는지 양수만 저장 가능한지 여부이다.
  - `isize`, `usize` 타입은 프로그램이 실행중인 컴퓨터 종류에 따라 크기가 달라진다.
  - **rust 정수의 기본타입인 i32\*가 대체로 가장 빠르며 64bit 플랫폼에서도 그렇다.**
  - rust는 디버그 모드로 컴파일하면 정수 오버플로 추가검사를 통해 [panic](https://doc.rust-lang.org/book/ch09-01-unrecoverable-errors-with-panic.html)을 발생시킨다.
  - 소수점 숫자 타입은 `f32`, `f64`가 있다.
  - 대부분 CPU에서 f64가 f32만큼 빠르면서 정확도가 높아, **rust는 f64를 기본타입으로 하고 있다.**
  - 숫자 사칙연산은 다른 언어들과 동일하다. [모든 연산자 목록](https://doc.rust-lang.org/book/appendix-02-operators.html)

    <br />

  #### 불리언, 문자

  ```rust
  fn main() {
      let t = true;
      let f: bool = false; // with explicit type annotation

      let c = 'z';
      let z = 'ℤ';
      let heart_eyed_cat = '😻';
  }
  ```

  - 불리언은 `bool`키워드로 선언한다.
  - 불리언의 크기는 1byte이다.
  - 문자는 `char`타입으로, 언어가 제공하는 가장 기본적인 알파벳이다.
  - 문자열 리터럴은 큰따옴표로 표현하지만, char 리터럴은 작은따옴표로 표현한다.
  - char 타입은 4byte 유니코드 스칼라값이어서 ASCII보다 더 많은 문자를 표현할 수 있다.

    <br />

### (2) 컴파운드(Compound) 타입

- 하나의 타입으로 여러 값을 글부화한 타입이다.
- 튜플(tuples), 배열(arrays)

<br />

#### 튜플

```rust
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
    let (x, y, z) = tup;

    println!("The value of y is: {}", y);
}
```

```rust
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

- 서로 다른 타입의 여러 값을 하나의 컴파운드 타입으로 묶을 때 적합하다.
- 튜플은 한번 정의하면 그 크기를 조정할 수 없다.
- 첫번째 코드처럼 선택적으로 타입 어노테이션을 적용할 수도 있다.
- 첫번째 코드처럼 **tup변수를 분해(destrucuring)해올 수도 있다.**
- 두번째 코드처럼 **마침표(.) 다음에 인덱스를 통해 각 요소를 참조해올 수도 있다.**
- 어떤 값도 없는 튜플(`()`)은 하나의 값만 있는 특수 타입이며 묵시적으로 [unit value](https://doc.rust-lang.org/std/primitive.unit.html)를 반환한다.
- **unit value는 void와 비슷하지만 반환값으로 사용할 수 있다는 차이가 있다.**
- _rust는 함수형 언어니까 void대신 '의미없는' 값을 반환하도록 구현했을 것임_
  ```rust
  // error: mismatched types: expected `()` but found `int`
  fn f() {
      1i32
  }
  ```

<br />

#### 배열

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];

    let b: [i32; 5] = [1, 2, 3, 4, 5];
}
```
