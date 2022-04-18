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
- 위 코드는 컴파일되지 않는다. _cannot assign twice to immutable variable_
- _`help: consider making this binding mutable: mut x`라는 친절한 팁과 함께..._
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

- 하나의 타입으로 여러 값을 그룹화한 타입이다.
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

- 배열의 각 요소는 모두 같은 타입이어야 한다.
- 배열은 고정된 크기이며, 데이터를 힙(heap)이 아닌 스택(stack) 메모리에 할당할 때 유용하다.
- _동적으로 변하는 데이터는 벡터(vector)로 관리하며 [Chapter 8](https://doc.rust-lang.org/book/ch08-01-vectors.html)에서 자세히 다룸_
- 배열타입을 지정하는 방법은 `[타입;원소개수]`이다.
- 유효하지 않은 요소에 접근할 때 `thread 'main' panicked at...`처럼 panic을 발생시킨다.
- **rust는 컴파일에서는 문제가 없지만 런타임 에러를 내서 엉뚱한 메모리에 대한 접근을 막는다.**

<br />
<hr />

## 함수

```rust
fn main() {
    println!("Hello, world!");

    another_function();

    // statement
    let y = 6;

    // expressions
    let y2 = {
        let x = 3;
        x + 1
    };
}

fn another_function() {
    println!("Another function.");
}

// arrow function
fn five() -> i32 {
    5
}
```

- rust에서 함수, 변수의 네이밍 컨벤션은 snake_case이다.
- rust에서 함수는 어딘가에 선언되기만 하면 사용할 수 있다.
- 화살표 함수는 js에서와 마찬가지로 `return` 키워드를 생략할 수 있다.
- 함수의 인자(parameter)와 인수(argument) 용어를 실제로는 섞어서 사용하기도 한다.
- `문(statements)`은 뭔가 액션을 수행하지만 값을 반환하지는 않는다.
- `식(expressions)`은 값을 반환하기 위해 평가한다.
  - expressions은 끝에 세미콜론(`;`)이 붙지 않는다.
  - 뒤에 세미콜론을 붙이면 statement로 전환되며 값을 반환하지 않는다.

<br />
<hr />

## Control Flow

### (1) if

```rust
// Handling Multiple Conditions
fn main() {
    let number = 6;

    if number % 4 == 0 {
        println!("number is divisible by 4");
    } else if number % 3 == 0 {
        println!("number is divisible by 3");
    } else if number % 2 == 0 {
        println!("number is divisible by 2");
    } else {
        println!("number is not divisible by 4, 3, or 2");
    }
}

// Using in a let Statement
fn main() {
    let condition = true;
    let number = if condition { 5 } else { 6 };

    println!("The value of number is: {}", number);
}

```

- if문에서 값을 반환하여 표현식처럼 사용할 수 있다.
- if-else 타입이 다르면 컴파일되지 않는다. _ex. if는 숫자이고 else는 문자열을 반환_

<br />

### (2) loop, while, for

```rust
fn main() {
    // loop
    let mut counter = 0;
    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("The result is {}", result);

    // while
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;

    while index < 5 {
        println!("the value is: {}", a[index]);

        index += 1;
    }

    // for
    for element in a {
        println!("the value is: {}", element);
    }

    for number in (1..4).rev() {
        println!("{}!", number);
    }
}
```

- loop는 영원히 반복되므로 반드시 탈출 조건이 필요하다.
- loop에서 `break`뒤에 값을 붙이면 반환할 수 있다.
- while은 특정 조건에 따라 반복할 때 사용한다.
- for는 특정 컬렉션을 순회하면서 반복할 때 사용한다.
