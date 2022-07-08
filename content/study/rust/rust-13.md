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
  - `|| self.most_stocked()` 클로저는 Inventory 인스턴스의 불변 참조를 캡처해 데이터를 패싱한다.
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
- (2)는 borrows_mutably 클로저 선언 후에 가변 차용이 끝난다.
- (2)는 즉, 클로저 선언과 호출 사이에 list 값에 대한 사용은 불변 차용이다.

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

### Iterator 생성하기

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

### Iterator 트레이트와 next 메서드

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // 기본 구현이 적용된 메서드는 생략
}
```

- 모든 반복자는 위 Iterator 트레이트를 구현해야 한다.
- next 메서드는 컬렉션에서 값을 가져와 Some에 저장해 반환하고 모두 순회하면 None을 반환한다.
- next 메서드는 Item 타입을 반환하고 있는데, 즉 Item은 반복자가 반환할 타입이다.
  _`type Item`과 `Self::Item`은 연관타입으로, 19장에서 자세히 다룸_

<br />

```rust
#[test]
fn iterator_demonstration() {
    let v1 = vec![1, 2, 3];

    let mut v1_iter = v1.iter();

    assert_eq!(v1_iter.next(), Some(&1));
    assert_eq!(v1_iter.next(), Some(&2));
    assert_eq!(v1_iter.next(), Some(&3));
    assert_eq!(v1_iter.next(), None);

    // let v1_iter = v1.iter();

    // for val in v1_iter {
    //     v1_iter.next()
    // }
}
```

- Iterator 트레이트는 next 메서드 하나만 정의하고 있는데, 이를 직접 호출해도 된다.
- 이때 next 메서드를 호출하면 이미 반환한 값을 추적하기 위해 반복자 내부 상태가 변경된다.
- **즉, v1_iter 변수는 반복자를 소비(consume)하므로 가변적으로 정의해야 한다.**
- **그러나 for 안에서는 루프가 v1_iter의 소유권을 가지고 가변 변수로 만들기 때문에 불변해도 된다.**
- 종류:
  - `iter`: 불변 참조를 순회하는 반복자를 생성
  - `into_iter`: v1에 대한 소유권을 가지고 소유한 값을 반환하는 반복자 생성
  - `iter_mut`: 가변 참조를 순회하는 반복자를 생성

<br />

### 반복자를 소비하는 메서드: `sum`

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn iterator_sum() {
        let v1 = vec![1, 2, 3];
        let v1_iter = v1.iter();
        let total: i32 = v1_iter.sum();

        assert_eq!(total, 6);
    }
}

```

- Iterator 트레이트를 구현하려면 next 메서드를 반드시 구현해야 한다.
- next를 호출하는 메서드는 내부에서 반복자를 소비하므로 `consuming adaptors`라고도 부른다.
- 예를 들어, sum 메서드는 반복자에 대한 소유권을 가지고 next 메서드를 게속 호출해 순회한다.
- sum 메서드를 호출한 후에는 v1_iter 변수의 소유권이 없으므로 더 이상 사용할 수 없다.

<br />

### 다른 반복자를 생성하는 메서드: `map`

```rust
fn main() {
    let v1: Vec<i32> = vec![1, 2, 3];

    // (1)
    v1.iter().map(|x| x + 1);

    // (2)
    let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();
    assert_eq!(v2, vec![2, 3, 4]);
}

```

- 반복자를 다른 종류의 반복자로 변경할 수 있는데, 이를 `iterator adaptors`라고 부른다.
- 모든 반복자는 지연 특성이 있어서 결과를 얻으려면 consuming adaptor 메서드를 호출해야 한다.
- 위 map 메서드의 클로저는 각 요소에 1을 더한 값을 반환해 새로운 반복자를 반환하고 있다.
- **Iterator 트레이트의 반복 로직을 재사용하면서 일부 동작을 바꾸기 위해 클로저를 사용한 좋은 예다.**
- **(1)은 반복자를 실제로 실행하지 않으므로 에러가 난다.**
  _warning: unused Map that must be used_
  _note: iterators are lazy and do nothing unless consumed_
- **(2)는 반복자를 실행한 결과값을 컬렉션에 담아 반환하는 collect 메서드를 사용했다.**

<br />

### 환경을 캡처하는 클로저 활용: `filter`

```rust
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

// shoes에 저장된 벡터와 shoe_size 매개변수의 소유권을 가지고
// 지정된 크기의 신발 리스트를 저장한 벡터를 반환함
fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    // into_iter로 벡터의 소유권을 가지는 반복자를 생성함
    // filter 인자로 shoe_size 변수를 캡처하는 클로저 전달
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn filters_by_size() {
        let shoes = vec![
            Shoe {
                size: 10,
                style: String::from("sneaker"),
            },
            Shoe {
                size: 13,
                style: String::from("sandal"),
            },
            Shoe {
                size: 10,
                style: String::from("boot"),
            },
        ];

        let in_my_size = shoes_in_size(shoes, 10);

        assert_eq!(
            in_my_size,
            vec![
                Shoe {
                    size: 10,
                    style: String::from("sneaker")
                },
                Shoe {
                    size: 10,
                    style: String::from("boot")
                },
            ]
        );
    }
}
```

- **filter 메서드는 인자에 반복자로부터 각 요소를 가져와 불리언값을 반환하는 클로저를 전달한다.**
- 클로저가 true를 반환하면 filter가 생성하는 반복자에 추가되고, false이면 추가되지 않는다.
- 위 코드에서 클로저는 환경에서 shoe_size 매개변수를 캡처하고 값을 각 Shoe의 size와 비교한다.

<br />
<hr />

## 12장의 I/O 프로젝트 개선

### 기존 Config::new의 clone이 필요한 이유?

```rust
// minigrep
// src/lib.rs
impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        let ignore_case = env::var("IGNORE_CASE").is_ok();

        Ok(Config {
            query,
            filename,
            ignore_case,
        })
    }
}
```

- clone 메서드가 필요한 이유는 new 함수에 String의 슬라이스인 args 변수 소유권이 없기 때문이다.
- 따라서 Config 인스턴스가 복제된 값을 소유해 반환하도록 해야 했다.
- 이제 슬라이스를 대여하는 대신 인자로 전달된 반복자의 소유권을 갖도록 수정할 수 있다.
- 그러면 새로운 메모리 할당을 수행하는 대신, 반복자로부터 String값을 Config 인스턴스로 이동할 수 있다.

<br />

### 리팩터링: 반환된 반복자를 직접 사용하기

```rust
// AS-IS
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    ...
}
```

```rust
// TO-BE
fn main() {
    let config = Config::new(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    ...
}

impl Config {
    pub fn new(
        mut args: impl Iterator<Item = String>,
    ) -> Result<Config, &'static str> {...}
}
```

- `env::args`는 반복자를 반환하는 함수다.
- 반복자의 값을 벡터로 합쳐 Config::new 슬라이스로 전달하는 대신, 반환한 반복자를 직접 전달시킨다.
- Config::new의 args가 반복자 타입이도록 함수 시그니처도 변경한다.
  - **표준 라이브러리에 따르면 env::args 힘수의 반환 타입은 `std::env::Args`이다.**
  - **그리고 해당 타입은 Iterator 트레이트를 구현하고 String 값을 반환해야 한다.**
  - 따라서 args는 ` &[String]` 대신 `impl Iterator<Item = String>` 타입을 가진다.
  - 이때 impl trait 문법은 args가 Iterator 트레이트를 구현하면서 String 요소를 반환하는 어떤 타입도 가능하다는 뜻이다.
  - 이때 args의 소유권을 가지고 반복자를 순회해야 하므로 args는 가변적이어야 한다.

<br />

### 리팩터링: 인덱스 대신 Iterator 트레이트 메서드 활용

```rust
// AS-IS
impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        ...
    }
}
```

```rust
// TO-BE
impl Config {
    pub fn new(
        mut args: impl Iterator<Item = String>,
    ) -> Result<Config, &'static str> {
        // env::args 함수의 첫번째 반환값은 프로그램 이름임
        // 따라서 단순히 next 호출함
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a query string"),
        };

        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a file name"),
        };

        ...
    }
}
```

- 이제 args는 Iterator 트레이트를 구현하므로 next 메서드를 호출할 수 있다.
- 각 값들에 대한 성공/실패 여부 동작을 위해 match 표현식을 사용한다.

<br />

### 리팩터링: Iterator adaptors를 사용해 깔끔한 코드 작성

```rust
// AS-IS
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
            results.push(line);
        }
    }

    results
}
```

```rust
// TO-BE
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    contents
        .lines()
        .filter(|line| line.contains(query))
        .collect()
}
```

- 반복자 어댑터 메서드들을 활용하면 코드가 더 직관적이고 중간값을 저장하는 변수도 필요없게 된다.
- 함수형 프로그래밍은 가변 상태를 최소화하므로 코드를 간결하게 유지할 수 있다.
- 루프를 실행하면서 새로운 벡터를 생성하는 대신, 루프의 목적을 고수준의 메서드로 퉁칠 수 있다.

<br />

### 리팩터링: minigrep 최종 코드

```rust
// main.rs
use std::env;
use std::process;

use minigrep::Config;

fn main() {
    let config = Config::new(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    if let Err(e) = minigrep::run(config) {
        eprintln!("애플리케이션 에러: {}", e);

        process::exit(1);
    }
}
```

```rust
// lib.rs
use std::fs;
use std::error::Error;
use std::env;

pub struct Config {
  pub query: String,
  pub filename: String,
  pub ignore_case: bool,
}

impl Config {
    pub fn new(
        mut args: impl Iterator<Item = String>,
    ) -> Result<Config, &'static str> {
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a query string"),
        };

        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a file name"),
        };

        let ignore_case = env::var("IGNORE_CASE").is_ok();

        Ok(Config {
            query,
            filename,
            ignore_case,
        })
    }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
  let contents = fs::read_to_string(config.filename)?;

  let results = if config.ignore_case {
      search_case_insensitive(&config.query, &contents)
  } else {
      search(&config.query, &contents)
  };

  for line in results {
      println!("{}", line);
  }

  Ok(())
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    contents
        .lines()
        .filter(|line| line.contains(query))
        .collect()
}

pub fn search_case_insensitive<'a>(
  query: &str,
  contents: &'a str,
) -> Vec<&'a str> {
  let query = query.to_lowercase();

  contents
        .lines()
        .filter(|line| line.to_lowercase().contains(&query))
        .collect()

}
```

<br />
<hr />

## 성능 비교: Loops vs Iterators
