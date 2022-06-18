---
title: "After reading Rust book chapter 10"
date: "2022-06-15"
tags: ["rust"]
draft: false
og_description: "Generic Types, Traits, and Lifetimes"
---

## Removing Duplication by Extracting a Function

```rust
// (1)
fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let mut largest = number_list[0];

    for number in number_list {
        if number > largest {
            largest = number;
        }
    }

    println!("The largest number is {}", largest);
}
```

```rust
// (2)
fn largest(list: &[i32]) -> i32 {
  let mut largest = list[0];

  for &item in list {
      if item > largest {
          largest = item;
      }
  }

  largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("The largest number is {}", result);

    let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

    let result = largest(&number_list);
    println!("The largest number is {}", result);
}
```

- (1)은 확장성을 고려한(ex. 여러 리스트 순회해서 대상 숫자를 찾는 등) 함수를 (2)처럼 추출할 수 있다.
- 코드 변경 과정은 다음과 같다.
  - 중복된 코드를 판단한다.
  - 중복된 코드를 함수로 추출하고 함수 시그니처에 입력과 반환 타입을 명시한다.
  - 중복된 코드를 함수 호출로 교체한다.
- 결국 제네릭 타입 없이 중복을 제거하는 방법을 활용해 제네릭 함수로도 추출할 수 있다.
- 제네릭 타입으로 바꿀 중복 코드를 찾는 방법은, 함수로 추출해야 할 중복 코드를 찾는 방법과 같다.

<br />
<hr />

## 제네릭 데이터 타입

#### 함수에서의 사용

```rust
// (1)
fn largest_i32(list: &[i32]) -> i32 {...}
fn largest_char(list: &[char]) -> char {...}

// (2)
fn largest<T>(list: &[T]) -> T {...}
```

- (1)처럼 매개변수/반환타입만 다르고 함수 본문은 같다면 (2)처럼 제네릭 함수로 추출할 수 있다.
- (2)는 largest 함수가 어떤 타입 T를 일반화한 함수라는 의미이다.

<br />

#### 구조체에서의 사용

```rust
// (1) 타입 T를 일반화한 구조체
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer = Point { x: 5, y: 10 };
    let float = Point { x: 1.0, y: 4.0 };
}
```

```rust
// (2) 다중 제네릭 타입 구조체
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let both_integer = Point { x: 5, y: 10 };
    let both_float = Point { x: 1.0, y: 4.0 };
    let integer_and_float = Point { x: 5, y: 4.0 };
}
```

- 제네릭 타입 매개변수는 얼마든지 선언할 수 있지만, 너무 많으면 가독성이 떨어진다.
- **즉, 제네릭 타입이 많아진다는 것은 코드를 더 작은 부분으로 재구성해야함을 뜻한다.**

<br />

#### 열거자에서의 사용

```rust
// (1)
enum Option<T> {
    Some(T),
    None,
}

// (2)
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

- (2)처럼 코드에서 여러 개의 구조체나 열거자가 오직 저장하는 값의 타입만 다를 때 유용하다.

<br />

#### 메서드에서의 사용

```rust
// (1)
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
```

```rust
// (2)
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

```rust
struct Point<X1, Y1> {
    x: X1,
    y: Y1,
}

impl<X1, Y1> Point<X1, Y1> {
    fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c' };

    let p3 = p1.mixup(p2);

    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

- (1)처럼 impl 키워드 다음에 제네릭을 지정하면 러스트는 Point에 지정된 타입이 구체화된 타입이 아닌 제네릭 타입이라는 점을 인식한다.
- (2)처럼 특정 타입의 인스턴스에만 적용할 메서드를 구현할 수도 있는데, 이때는 impl 키워드 뒤에 타입을 명시할 필요가 없다.
- (3)처럼 **구조체 정의에 사용된 제네릭 타입이 내부 메서드 시그니처에서 사용한 타입과 무조건 같을 필요는 없다.**
  - mixup 함수는 `X1, Y1` 타입으로 일반화된 구조체 안에서 정의되었으나,
  - 전혀 다른 `X2, Y2` 타입의 Point 구조체를 매개변수로 사용할 수도 있다.

<br />

#### 제네릭의 성능

```rust
// (1)
let integer = Some(5);
let float = Some(5.0);

// (2)
num Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

- 러스트에서는 제네릭을 사용한다고 해서 구체화된 타입을 사용할 때보다 성능이 떨어지지 않는다.
- 러스트는 컴파일 시점에 제네릭 사용 코드를 `단일화(monomorphzation)`하기 때문이다.
- 단일화란 컴파일 시점에 제네릭 코드를 실제로 사용하는 구체화된 타입으로 변환하는 과정이다.
- (2)는 (1)의 Option<T>을 사용하는 코드의 monomorphized된 버전이다.
- **이처럼 제네릭 코드를 특정 타입을 사용하는 코드로 컴파일하므로 런타임 비용이 들지 않는다.**

<br />
<hr />

## 트레이트(trait): Defining Shared Behavior

- 트레이트는 공유 가능한 동작을 추상화하여 정의하는 방법이다.
- 트레이트에 제네릭을 결합해 모든 타입에 특정 동작을 공유할 수도 있다.
- 약간 차이점이 있지만 다른 언어에서의 `인터페이스(interface)`와 유사하다.

<br />

### 트레이트 선언하기

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}
```

- 트레이트는 어떤 목적에 필요한 일련의 행위를 정의하고, 여러 타입에 적용할 메서드 시그니처를 그룹화한다.
- Tweet 구조체 인스턴스의 데이터를 요약해 보여주는 라이브러리를 개발한다고 가정해보자.
  - 각 타입으로부터 요약 데이터를 추출해야 하므로 summarize 메서드를 호출해야 한다.
  - 위 예제 코드는 해당 동작을 표현하는 트레이트이다.
- 트레이트 내 메서드 시그니처는 구현 코드 대신 세미콜론을 붙인다.
- **따라서 이 트레이트를 구현하는 각 타입은 반드시 이 메서드 본문을 구현해야 한다.**
- 하나의 트레이트에 여러 개의 메서드를 정의할 수도 있다.

<br />

### 타입에 트레이트 구현하기

```rust
// (1)
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

```rust
// (2)
use aggregator::{Summary, Tweet};

fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    };

    println!("1 new tweet: {}", tweet.summarize());
}
```

- (1)처럼 `impl ~ for` 키워드를 덧붙인다는 점을 제외하면 보통 메서드를 구현하는 방법과 유사하다.
- (2)처럼 보통의 메서드처럼 각 타입의 인스턴스에 대해 해당 메서드를 호출할 수 있다.
- 각 타입과 Summary 트레이트를 lib.rs 하나에 정의해 모두 같은 범위에 있다고 보자.
  - lib.rs 파일을 aggregator라는 라이브러리 안에 생성했다고 보자.
  - 이때 별개 라이브러리 범위에 정의된 구조체에 Summary 트레이트를 구현하고 싶다면?
  - aggregator::Summary처럼 가져와야 하므로 `pub`키워드를 추가해줘야 한다.
- **외부 타입에 외부 트레이트를 구현할 수는 없다.**
  - aggregator 크레이트 안에서 `Vec<T>`타입에 `Display` 트레이트를 구현할 수 없다.
  - 둘다 표준 라이브러리에 정의된 타입이고, aggregator 크레이트의 로컬 타입이 아니기 때문이다.
  - 이는 `통일성(coherence)` 혹은 `고아규칙(orphan rule)`이라고 부르는 프로그램의 특성이다.
  - **이 규칙이 없다면 두 크레이트가 같은 타입에 같은 트레이트를 구현하게 될 수가 있고, 이때 러스트는 어떤 타입 구현을 사용해야 할 지 알 수 없게 된다.**

<br />

### 트레이트 기본 구현 (Default Implementations)

```rust
// (1)
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}
```

```rust
// (2)
impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}
```

```rust
// (3)
let tweet = Tweet {
    username: String::from("horse_ebooks"),
    content: String::from(
        "of course, as you probably already know, people",
    ),
    reply: false,
    retweet: false,
};

println!("1 new tweet: {}", tweet.summarize());
```

- 때로는 트레이트에 일부 혹은 전체 메서드의 기본 동작을 구현하는 편이 유용할 때가 있다.
- 기본 구현은 (1)처럼 **같은 트레이트의 다른 메서드를 호출할 수도 있다.**
- 이 트레이트는 (2)처럼 **기본 구현이 없는 summarize_author 메서드만 정의하면 된다.**
- 이때 같은 메서드를 오버라이딩하면서 기본 구현 코드를 호출할 수는 없다.

<br />

### 트레이트 매개변수 (Traits as Parameters)

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```

- 위 코드의 item 매개변수는 지정된 트레이트를 구현하는 모든 타입을 허용한다.
- notify 함수의 본문에서는 Summary 트레이트에 정의된 메서드라면 무엇이든 호출할 수 있다.
- 이처럼 `impl Trait` 문법은 함수 정의가 간단한 경우에는 편리하다.

<br />

#### (1) Trait Bound Syntax

```rust
// (1)
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// (2)
pub fn notify<T: Summary>(item1: &T, item2: &T) {...}
```

- 트레이트 경계 문법은 (2)처럼 매개변수가 여러 개인 좀더 복잡한 경우 유용하다.
- 제네릭 타입에 콜론으로 지정할 수 있다.

<br />

#### (2) + 문법으로 여러 트레이트 경계 정의하기

```rust
// (1)
pub fn notify(item: &(impl Summary + Display)) {...}

// (2)
pub fn notify<T: Summary + Display>(item: &T) {...}
```

- 하나 이상의 트레이트 경계를 정의하는 것도 가능하다.
- 매개변수에 Summary와 Display 트레이트를 모두 구현해야 한다면 + 문법을 사용한다.

<br />

#### (3) where 이용해 트레이트 경계 정리하기

```rust
// (1)
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {...}

// (2)
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: Display + Clone,
          U: Clone + Debug
{...}
```

- (1)처럼 너무 많은 트레이트 경계를 사용하면 함수 시그니처 가독성이 떨어진다.
- (2)처럼 where clause를 이용해 함수 시그니처를 훨씬 간결하게 유지할 수 있다.

<br />

### 반환값에 트레이트 구현 값 사용하기

```rust
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    }
}
```

- 위 함수는 Summary 트레이트를 구현하는 어떤 타입이라도 반환할 수 있다.
- 이때 함수는 Tweet 타입을 반환하지만, 이 함수를 호출하는 코드는 실제 반환 타입을 알지 못한다.
- impl Trait 문법은 하나의 타입을 반환하는 경우에만 사용할 수 있다.
- 즉, Tweet이나 NewsArticle 둘중에 하나를 반환하려고 하면 컴파일러 에러가 뜬다.
- 컴파일러가 impl Trait 문법을 구현하는 방법의 제약 때문이다.
  _17장에서 더 자세히 다룰 것임_

<br />

#### 트레이트 경계 예제: largest 함수

```rust
// (1)
fn largest<T: PartialOrd>(list: &[T]) -> T {...}

// (2)
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("The largest number is {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("The largest char is {}", result);
}
```

```rust
// (3)
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            largest = &item;
        }
    }

    largest
}

...
```

- i32와 char처럼 크기가 이미 정해진 타입은 스택에 저장되므로 Copy 트레이트를 구현하고 있다.
- (1)은 list 매개변수에 Copy 트레이트를 구현하지 않는 타입의 값이 전달될 가능성이 생겼다.
  - _error[E0508]: cannot move out of type `[T]`, a non-copy slice_
  - 그 결과 list[0] 값을 largest 변수로 가져올 수 없어서 에러가 발생하는 것이다.
- 따라서 (2)처럼 타입 T 트레이트 경계에 Copy 트레이트를 추가해야 한다.
- Copy대신 Clone으로 선언해도 되며, largest 함수가 소유권을 가질 때 슬라이스의 각 값을 복제한다.
- clone 함수를 사용하면 결국 String처럼 힙 데이터를 사용하는 타입은 더 많은 힙 메모리가 필요하다.
  - 따라서 많은 양의 데이터 처리에는 속도가 떨어진다.
- (3)처럼 Copy나 Clone 트레이트 경계 없이(힙 메모리 할당 없이) 구현할 수도 있다.
  - 이때 `for item in list`에서 item은 &T를 의미한다.
  - `&item`은 참조를 destructuring한다는 의미여서 T를 의미하게 된다.
  - 따라서 largest는 &T타입이므로 & 키워드 없이 순회해야 한다.

<br />

#### 덮개 구현 (blanket implementations)

```rust
// (1)
impl<T: Display> ToString for T {
    // --snip--
}

// (2)
let s = 3.to_string();
```

- **타입이 원하는 트레이트를 구현하는 경우에만 다른 트레이트를 조건적으로 구현하게 할 수 있다.**
- 러스트 표준 라이브러리에서는 빈번하게 사용하는 기법이다.
- (1)처럼 표준 라이브러리는 Display 트레이트 구현 타입에 ToString 트레이트도 함께 구현한다.
- 따라서 (2)처럼 Display를 구현하는 모든 타입은 ToString 트레이트의 to_string 메서드를 호출할 수 있다.

<br />
<hr />

## 수명(Lifetimes)을 이용힌 참조 유효성 검사
