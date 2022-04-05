---
title: "After reading Rust book chapter 3"
date: "2022-04-05"
tags: ["rust"]
draft: false
og_description: "Common Programming Concepts"
---

## Variables and Mutability

### let

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

### constants

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

### 스칼라(Scarlar) 타입

- 하나의 값을 표현하는 타입이다.
- 정수(integers), 부동 소수점 숫자(floating-point numbers), 불리언(Booleans), 문자열(characters)

### 컴파운드(Compound) 타입
