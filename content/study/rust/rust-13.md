---
title: "After reading Rust book chapter 13"
date: "2022-07-04"
tags: ["rust"]
draft: false
og_description: "Functional Language Features: Iterators and Closures"
---

## 클로저(Closures): 주변 환경을 캡처하는 익명함수

- **러스트의 클로저는 변수에 저장하거나 다른 함수에 인자로 전달하는 익명함수다.**
- 일반 함수와 달리 클로저는 자신이 정의된 스코프 내의 값들을 캡처한다.

<br />

### (1) 클로저를 이용한 environment 캡처

```rust
// 예시: 무료 셔츠 나눔
#[derive(Debug, PartialEq, Copy, Clone)]
enum ShirtColor {
    Red,
    Blue,
}

struct Inventory {
    shirts: Vec<ShirtColor>,
}

impl Inventory {
    // 선호하는 색상이 있다면 -> 그 색상 셔츠 나눔
    // 없다면 -> 회사에서 가장 많이 팔리는 셔츠 나눔
    fn giveaway(&self, user_preference: Option<ShirtColor>) -> ShirtColor {
        user_preference.unwrap_or_else(|| self.most_stocked())
    }

    fn most_stocked(&self) -> ShirtColor {
        let mut num_red = 0;
        let mut num_blue = 0;

        for color in &self.shirts {
            match color {
                ShirtColor::Red => num_red += 1,
                ShirtColor::Blue => num_blue += 1,
            }
        }
        if num_red > num_blue {
            ShirtColor::Red
        } else {
            ShirtColor::Blue
        }
    }
}

fn main() {
    // 파랑 재고가 더 많은 스토어 생성
    let store = Inventory {
        shirts: vec![ShirtColor::Blue, ShirtColor::Red, ShirtColor::Blue],
    };

    // 선호 색상 빨강
    let user_pref1 = Some(ShirtColor::Red);
    let giveaway1 = store.giveaway(user_pref1);
    println!(
        "The user with preference {:?} gets {:?}",
        user_pref1, giveaway1
    );

    // 선호 색상 없음
    let user_pref2 = None;
    let giveaway2 = store.giveaway(user_pref2);
    println!(
        "The user with preference {:?} gets {:?}",
        user_pref2, giveaway2
    );
}
```

- giveaway 메서드는 unwrap_or_else를 통해 클로저를 사용하고 있다.
- [unwrap_or_else](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or_else)는 표준 라이브러리에 정의된 `Option<T>`의 메서드이다.
- **어떤 인자도 없이 T를 반환하는 클로저**를 인수로 받는다.
  - [`FnOnce`](https://doc.rust-lang.org/std/ops/trait.FnOnce.html) 트레이트가 구현되어야 하며, 한번만 호출되는 함수이다.
  - `|| self.most_stocked()` 클로저를 통해 참조를 self로 캡처하고 데이터를 패싱한다.
  - most_stocked가 캡처된 컨텍스트의 ShirtColor 타입의 값을 사용할 수 있는 이유다.
- 일반함수는 이런 경우에 해당 컨텍스트를 캡처할 수 없다.
- vertical pipe(`|`)로 클로저를 명시하며, [smalltalk](https://wiki.c2.com/?SmalltalkBlocksAndClosures)와 [ruby](https://www.geeksforgeeks.org/closures-in-ruby/)도 같은 문법이다.

<br />

### (2) 클로저의 타입 추론과 어노테이션

- 클로저는 일반함수처럼 매개변수와 반환값의 타입을 지정할 필요가 없다.
- 함수의 타입 어노테이션을 지정하는 이유는 호출할 대상에 노출되는 인터페이스이기 때문이다.
- 그러나 클로저는 변수에 저장되고 익명인데다 라이브러리 사용자에게 노출되지 않고 사용된다.
- 따라서 주로 짧고 상대적으로 좁은 컨텍스트에서 실행된다.
- **컴파일러는 변수의 타입을 추론하는 것과 같은 방법으로 클로저의 매개변수와 반환타입을 추론한다.**

<br />

#### 타입을 명시한 클로저

```rust
let expensive_closure = |num: u32| -> u32 {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    };
```

- 장황한 코드를 작성할 바에는 이렇게 클로저에도 타입 어노테이션을 추가할 수 있다.
- 함수와 비슷해보이지만 다르다.

<br />

#### 함수와 클로저

```rust
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

- v1, 함수의 정의이다.
- v2, 타입 어노테이션을 적용한 클로저이다.
- v3, 타입 어노테이션을 제거한 클로저이다.
- v4, 하나의 표현식으로만 구성되었으므로 괄호를 생략한 클로저이다.
- v3과 v4는 컴파일하려면 클로저 호출이 필요한데, 어떻게 사용되는지에 따라 타입이 추론되기 때문이다.

<br />

#### 다른 타입으로 하나의 클로저를 호출하면?

```rust
let example_closure = |x| x;

let s = example_closure(String::from("hello"));
let n = example_closure(5);
```

- 클로저는 모든 매개변수와 반환값에 대해 하나의 구체화된 타입만 사용한다.
- 따라서 **String 타입을 인자로 호출했다가 u32 타입을 넣었으므로 에러가 발생한다.**
  _error[E0308]: mismatched types_

<br />

### (3) 참조 캡처하기, 혹은 소유권 이동

#### borrow

```rust
// (1) immutable
fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let only_borrows = || println!("From closure: {:?}", list);

    println!("Before calling closure: {:?}", list);
    only_borrows();
    println!("After calling closure: {:?}", list);
}
```

```rust
// (2) mutable
fn main() {
    let mut list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let mut borrows_mutably = || list.push(7);

    // 에러: immutable borrow occurs here
    // println!("After calling closure: {:?}", list);
    borrows_mutably();
    println!("After calling closure: {:?}", list);
}
```

- list가 println으로 소유권이 이동되어 원칙상 이후에는 사용할 수가 없다.
- 클로저를 변수에 할당하여 함수처럼 호출할 수도 있다.
- (1)은 사용 후에도 출력하기 위해 현재 값들을 불변 차용하여 캡처하는 클로저를 정의한다.
- (2)는 list 값을 바꾸므로 가변 차용하여 클로저를 정의한다.
- (2)는 borrows_mutably 클로저 선언 후에 가변 차용이 끝나므로 이후 list는 불변값이다.

#### move

- 클로저가 환경에서 사용하는 값의 소유권을 강제로 가져오려면 매개변수 앞에 `move` 키워드를 붙인다.
- 클로저를 새 스레드에 전달하고 데이터를 이동시켜 새 스레드가 소유하도록 할 때 유용하다.
  _동시성에 대해 이야기하는 16장에서 자세히 다룰 것_

<br />

### (4) 클로저와 `Fn` Traits로부터 캡쳐한 값들 이동시키기

#### 클로저가 구현할 수 있는 트레이트

- 클로저에서는
  - 캡처된 값을 클로저 외부로 이동할 수 있다.
  - 캡처된 값을 변경할 수 있다.
  - 캡처된 값에 대해 아무것도 하지 않을 수도 있다.
- 클로저가 환경의 값을 캡처/처리하는 방식은 클로저가 구현하는 trait와 연관이 있다.
- 클로저의 trait들은 함수와 구조체가 사용할 수 있는 클로저의 종류를 지정하는 방법이다.
  - `FnOnce`:
    - 같은 범위에 선언된 변수를 사용할 수 있으며, 이 범위가 클로저의 environment이다.
    - 클로저는 캡처된 변수를 사용하려면 꼭 이 변수들의 소유권을 가져야 한다.
    - 이 트레이트는 한번만 호출된다, 즉 같은 값에 대한 소유권을 오직 한 번만 가진다.
  - `FnMut`
    - 환경에서 값을 가변 차용한다.
    - 환경에서 캡처한 값을 변경할 수 있고, N번 호출할 수 있다.
  - `Fn`
    - 환경에서 값을 불변 차용한다.
    - 환경을 변경하지 않고 N번 호출할 수 있어, 클로저를 여러 번 호출하는 경우 유용하다.
    - 환경에서 아무것도 캡처하지 않는 클로저는 이 트레이트를 구현한다.

<br />

#### 예시1: FnOnce

```rust
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T
    {
        match self {
            Some(x) => x,
            None => f(),
        }
    }
}
```

- Option<T>의 unwrap_or_else 메서드는 None 경우에 `FnOnce() -> T` 타입을 반환한다.
- 즉, 지정된 F는 최소한 한 번은 호출될 수 있어야 하고 인수를 사용하지 않고 T를 반환해야 한다.
- 모든 클로저는 `FnOnce`를 구현하므로 이 메서드는 가장 다양한 종류의 클로저를 허용하는 셈이다.
- 참고로 일반 함수는 세 가지 Fn 트레이트를 모두 구현할 수 있다.
  - 따라서 환경에서 값을 캡처할 필요가 없다면 함수를 사용해도 된다.
  - `Option<Vec<T>>`값이 None이면 `unwrap_or_else(Vec::new)`를 호출해 빈 벡터를 얻을 수 있다.

<br />

#### 예시2: FnMut

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle {
            width: 10,
            height: 1,
        },
        Rectangle {
            width: 3,
            height: 5,
        },
        Rectangle {
            width: 7,
            height: 12,
        },
    ];

    // (1) O
    list.sort_by_key(|r| r.width);
    println!("{:#?}", list);

    // (2) X
    let mut sort_operations = vec![];
    let value = String::from("by key called");

    list.sort_by_key(|r| {
        sort_operations.push(value);
        r.width
    });
    println!("{:#?}", list);

    // (3) O
    let mut num_sort_operations = 0;
    list.sort_by_key(|r| {
        num_sort_operations += 1;
        r.width
    });
    println!("{:#?}, sorted in {num_sort_operations} operations", list);
}
```

- sort_by_key는 FnMut 구현이 필요한 슬라이스에 정의된 표준 라이브러리 메서드이다.
- 위 코드는 각 Rectangle의 width가 낮은 순서대로 정렬된다.
- sort_by_key는 클로저를 여러 번 호출해야 하므로 FnMut 클로저를 인자로 받는다.
- **(1)의 클로저는 어떤 값도 그 환경으로부터 바꾸지 않으므로 반복해서 호출 가능하다.**
- **(2)의 클로저는 FnOnce를 구현하고 있으므로 해당 메서드에서 사용 불가능하다.**
  - 문자열 value를 sort_operations로 푸시할 때 클로저는 값을 캡처한다.
  - 문자열 value의 소유권이 sort_operations로 벡터로 이동된다.
  - 따라서 클로저를 다시 호출하려고 하면 에러가 난다.
  - 즉, 이 클로저는 sort_by_key의 인자와 맞지 않다.
  - (3)은 클로저에서 환경 외부로 값의 소유권이 이동되지 않도록 변경했다.
  - (3)은 num_sort_operations에 대한 가변 참조만 캡처하므로 정상 동작한다.

<br />
<hr />

## Iterator를 이용한 일련의 요소 처리

#### Iterator 생성하기

```rust
fn main() {
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();

    for val in v1_iter {
        println!("Got: {}", val);
    }
}
```

- 반복자는 요소를 순회하며 마지막 요소에 도달하는 때를 판단한다.
- `지연(lazy)`: 반복자를 사용하는 메서드 호출 전까지는 아무 일도 일어나지 않는다.
- `Vec<T>`에 정의된 iter 메서드를 호출해 v1에 대한 반복자를 생성하는 것 자체는 의미가 없다.
- 즉, v1_iter를 for 루프에서 비로소 사용할 때 의미가 있다.

<br />

#### Iterator 트레이트와 next 메서드
