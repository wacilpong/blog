---
title: "After reading Rust book chapter 6"
date: "2022-04-26"
tags: ["rust"]
draft: false
og_description: "Enums and Pattern Matching"
---

## 1. 대수적 타입(Algebraic data type)

- 러스트의 `enum`은 함수형 언어들의 `대수자료형(algebraic data types)`에 가깝다.
- 정수론은 각종 숫자의 성질을 대상으로 하는 수학이다.
- 대수학은 숫자 대신 문자를 사용하여 방정식의 풀이 방법이나 대수적 구조를 연구한다.
  - 아래와 같은 과정으로 문제를 해결하는 것이 대수학의 목적이다.
  - ex. 10x = 5000, x = 500
- 대수적 타입은 다른 자료형의 값을 가지는 자료형이자, 부분으로 전체를 나타내는 타입이다.
  - 모든 IP 주소가 v4이거나 v6이지만, 동시에 두 형식을 지원할 수는 없다.
  - 따라서 IP 주소는 대수적 타입, 즉 러스트의 enum에 적합하다.
    ```rust
    enum IpAddrKind {
        V4,
        V6,
    }
    ```

<br />

## 2. 선언과 활용

```rust
// (1)
let four = IpAddrKind::V4;
let six = IpAddrKind::V6;

// (2)
fn route(ip_kind: IpAddrKind) {}

route(IpAddrKind::V4);
route(IpAddrKind::V6);
```

- (1)처럼 `::`으로 값을 할당하고 v4, v6를 같은 타입(IpAddrKind)으로 취급할 수 있다.
- (2)처럼 enum타입의 매개변수를 갖는 함수를 정의할 수도 있다.

<br />

```rust
// (1)
enum IpAddrKind {
    V4,
    V6,
}

struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

let home = IpAddr {
    kind: IpAddrKind::V4,
    address: String::from("127.0.0.1"),
};

let loopback = IpAddr {
    kind: IpAddrKind::V6,
    address: String::from("::1"),
};
```

```rust
// (2)
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));
let loopback = IpAddr::V6(String::from("::1"));
```

```rust
// (3)
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);
let loopback = IpAddr::V6(String::from("::1"));
```

- (1)처럼 enum을 구조체 안에서 사용해 데이터를 할당(저장)할 수 있다.
- (2)처럼 enum의 열거값(variants)에 직접 데이터를 지정할 수 있다.
- (3)처럼 **구조체와 달리 enum에 각 열거값의 타입이 다를 때도 처리할 수 있다.**
- enum 값에는 String, numeric types, struct, enum 등 어떤 타입이든 저장 할 수 있다.
- 위 `IpAddr`는 표준 라이브러리(`Enum std::net::IpAddr`)에 있다.
  - 유효 스코프에서 사용하지 않는 한 같은 이름으로 타입을 재정의할 수 있다.
  - _타입을 스코프로 가져오는 방법은 7장에서 다룸_

<br />

### Structs vs Enums

```rust
// (1)
// 각각의 다른 타입이 모두 Message 타입에 속하고 있다.
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

```rust
// (2)
// 각각의 다른 타입 구조체를 정의했기 때문에
// 여러 종류의 메시지를 매개변수로 받는 함수를 쉽게 정의할 수 없다.
struct QuitMessage; // unit struct
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String); // tuple struct
struct ChangeColorMessage(i32, i32, i32); // tuple struct
```

```rust
// (3)
// 구조체와 마찬가지로 enum도 impl블록에서 메서드를 정의할 수 있다.
// self로 이 메서드를 호출하는 enum의 값에 접근할 수 있다.
// 여기서 self는 Write("hello")이다.
impl Message {
    fn call(&self) {
        // method body
    }
}

let m = Message::Write(String::from("hello"));
m.call();
```

<br />

### Null 대신 Option enum을 사용할 때의 장점

```rust
// (1)
enum Option<T> {
    None,
    Some(T),
}
fn main() {
    let some_number = Some(5);
    let some_string = Some("a string");

    let absent_number: Option<i32> = None;
}

```

```rust
// (2)
fn main() {
    let x: i8 = 5;
    let y: Option<i8> = Some(5);

    let sum = x + y;
}
```

- 러스트에는 `null`이 없다.
- 대신, 표준 라이브러리가 제공하는 Option<T> enum을 통해 null의 경우를 처리한다.
- 프렐류드에 포함되어 있어서 굳이 스코프로 가져올 필요없이(`Option::` 문법없이) 직접 사용할 수 있다.
  _이때 T는 제네릭을 의미하며 10장에서 자세히 다룸_
- Some이 어떤 타입인지 위 코드처럼 명시해주어야 한다.
- 러스트 컴파일러는 None 값만 보고 해당 Some이 어떤 타입으로 쓰이고 있는지 유추할 수 없다.
- `Option<T> !== T`이다. 따라서 (2)는 에러를 낸다.
  - _cannot add Option<i8> to i8_
  - i8은 항상 유효한 반면, Option<i8>은 값이 없는 경우가 있어서 두 타입은 다르다.
  - **따라서 Option<T>가 아닌 모든 타입은 null이 아닐 것이라고 생각해도 된다.**
  - null값이 확산되는 것을 막고 러스트 코드의 안정성을 위해 의도적으로 디자인된 패턴이다.
- [Optopn<T>](https://doc.rust-lang.org/std/option/enum.Option.html)는 Some값으로부터 T를 알아내기 위한 다양한 메서드를 제공한다.

<br />

#### null의 문제점

- **null값의 문제는 이를 null이 아닌 값처럼 사용하려고 하면 에러가 발생한다는 점이다.**
- 대부분의 상태는 있을 수도 있고, 없을 수도 있는 값이기 때문에 너무 치명적이다.
- null값 창시자인 토니 호어는 객체지향 언어의 참조를 다룰 때 모든 참조를 완전히 안전하게 사용할 수 있도록 하는 의미에서 null 참조 개념의 유혹을 뿌리칠 수 없었고, 그렇게 구현했다. 그리고 이를 '엄청난 실수'라고 표현했다.

<br />

## 3. Match 흐름 제어 연산자

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}

fn main() {}
```

- `match` 키워드 다음에 표현식(expression)을 쓰는데, boolean만 되는 if와 달리 모든 타입이 가능하다.
- 각각의 가지(arms)는 `=>`를 기준으로 패턴과 실행할 코드부분으로 나뉘어진다.
- 표현식의 값이 패턴과 일치하면 그 연관된 코드부분이 실행되고 값을 반환한다.
- 실행할 코드부분이 짧으면 통상 중괄호를 사용하지 않는다. _마치 한줄 화살표 함수처럼_

<br />

### 값을 바인딩하는 패턴

```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}

value_in_cents(Coin::Quarter(UsState::Alaska));
```

- Quarter동전이 미국의 어느 주에서 발행됐는지 알기 위해 UsState값을 바인딩할 수 있다.
- 함수를 호출하면 match 표현식의 coin 변수는 `Coin::Quarter(UsState::Alaska)`값이다.
- 이때 match의 각 가지들과 비교하면 `Coin::Quarter(state)`와 일치하게 된다.
- 그리고 state 변수에는 `UsState::Alaska`값이 바인딩된다.

<br />

### enum(Option<T>)과 match의 조합

```rust
fn main() {
    fn plus_one(x: Option<i32>) -> Option<i32> {
        match x {
            None => None,
            Some(i) => Some(i + 1),
        }
    }

    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
}
```

- 이처럼 함수의 x인자에 값이 있으면 1을 더하고, 없으면 아무것도 안할 때 **enum + match 조합으로 쉽게 구현할 수 있다.**
- 러스트에서는 match 표현식을 작성하고, enum 열거값에 명시한 데이터를 변수에 바인딩하여 연관코드를 실행하는 패턴을 자주 볼 수 있다.
  _러스타시안들에게 꾸준히 사랑받는 기능이라고 함. 올ㅋ_

<br />

### match는 표현식에 지정한 경우의 수를 모두 처리해야 한다.

```rust
fn main() {
    fn plus_one(x: Option<i32>) -> Option<i32> {
        match x {
            Some(i) => Some(i + 1),
        }
    }

    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
}
```

- x는 Option<T>타입이지만 None에 대한 패턴이 없으므로 에러를 낸다.
  _non-exhaustive patterns: `None` not covered_
  _help: ensure that all possible cases are being handled, ..._
  _note: the matched value is of type `Option<i32>`_
- **즉, 러스트의 패턴 매칭은 완벽해야 한다. Matches in Rust are exhaustive.**

<br />

### catch-all 패턴과 Placeholder `_`

```rust
fn main() {
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other),
        // _ => reroll(),
        // _ => (),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
    fn move_player(num_spaces: u8) {}
    fn reroll() {}
}
```

- 예제처럼 주사위 숫자의 모든 경우를 처리하는 대신 catch-all 패턴을 쓸 수 있다.
- 여기서는 3과 7외의 숫자를 other라고 명명하고, 바인딩된 숫자를 변수로 이용한다.
- catch-all 패턴은 match가 모든 경우의 수를 처리해야 한다는 규칙을 충족한다.
- **match 패턴은 순서대로 평가되므로 `other`를 마지막 가지로 두어야 한다.**

<hr />

- catch-all 패턴에서 어떤 값도 사용하고 싶지 않을 때는 `_`를 사용한다.
- `_`는 모든 값과 일치하지만 값이 바인딩되지는 않는 특수한 패턴이다.
- 이 또한 지정한 경우 외의 모든 값을 무시하기 때문에 match의 완전성에도 충족한다.
- 유닛 값(unit value, `()`)을 활용해 어떤 코드도 실행하지 않게 할 수 있다.

<br />

## 4. if let 흐름 제어

```rust
// AS-IS
fn main() {
    let config_max = Some(3u8);
    match config_max {
        Some(max) => println!("The maximum is configured to be {}", max),
        _ => (),
    }
}
```

```rust
// TO-BE
fn main() {
    let config_max = Some(3u8);
    if let Some(max) = config_max {
        println!("The maximum is configured to be {}", max);
    }
}

fn main() {
    let coin = Coin::Penny;
    let mut count = 0;
    if let Coin::Quarter(state) = coin {
        println!("State quarter from {:?}!", state);
    } else {
        count += 1;
    }
}

```

- 예제에서 아무 처리도 하지 않는 경우 `_ => ()`가 성가신 보일러플레이트 같다.
- 즉, match는 단 한 가지 경우만 처리할 때 사용하기에는 다소 장황하다.
- `if let` 문법은 한 경우만 처리하고 나머지는 무시하고 싶을 때 유용하다.
- **주어진 값에 한 패턴만 검사하고 나머지는 무시하는 match의 syntax sugar라고 볼 수 있다.**
- **else를 활용해 match의 \_ 패턴에 연관된 코드 또한 처리할 수 있다. (`If let ~ else`)**
