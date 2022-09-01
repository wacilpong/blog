---
title: "After reading Rust book chapter 19"
date: "2022-09-01"
tags: ["rust"]
draft: false
og_description: "Advanced Features"
---

## 19.2 Advanced Traits

### 19.2.1 연관 타입으로 트레이트 정의에 자리지정자 타입 선언

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;
}
```

- 자리지정자 타입(placeholder type)으로 트레이트의 메서드 시그니처를 정의할 수 있다.
- `Item`은 연관 타입으로써, Iterator 트레이트의 자리지정자 타입이다.
- Iterator 트레이트를 구현하는 타입은 Item 타입을 대체할 실제 타입을 지정해야 한다.

<br />

```rust
// (1)
// Item 타입을 u32 타입으로 대체
impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        // --snip--

// (2)
// 제네릭으로 선언한 가상의 Iterator
pub trait Iterator<T> {
    fn next(&mut self) -> Option<T>;
}
```

- 연관 타입은 제네릭과 유사하지만, 제네릭은 처리할 타입을 명시하지 않아도 함수를 선언할 수 있다.
- (1)문법은 (2)처럼 제네릭으로 표현할 수 있지만 왜 그렇게 하지 않았을까?
  - 제네릭 타입 매개변수를, 필요한 타입으로 교체해서 여러 번 구현해야 하기 때문이다.
  - 즉, (1)은 Counter 구조체의 next 메서드를 호출할 떄마다 u32를 지정할 필요가 없다.

<br />

### 19.2.2 기본 제네릭 타입 매개변수와 연산자 오버로딩

- `자리지정자 타입 = 실제 타입` 문법으로 제네릭의 기본 타입을 지정할 수 있다.
- 연산자를 오버로딩(overloading)할 때 유용하다.
- 러스트는 사용자 정의 연산자나 연산자 오버로딩을 지원하지 않는다.
- 하지만 `std::ops` 모듈에 있는 연산자와 관련 트레이트를 구현해 오버로딩할 수 있다.

<br />

```rust
// Add 트레이트를 구현하여
// Point 인스턴스에 대한 + 연산자 오버로딩
use std::ops::Add;

#[derive(Debug, Copy, Clone, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

impl Add for Point {
    type Output = Point;

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn main() {
    assert_eq!(
        Point { x: 1, y: 0 } + Point { x: 2, y: 3 },
        Point { x: 3, y: 3 }
    );
}
```

```rust
trait Add<Rhs=Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}
```

- Add 트레이트는 하나의 연관 타입과 하나의 메서드를 정의한다.
- Rhs에 타입을 지정하지 않으면 Self(Add 트레이트를 구현하는 타입 자체)을 가리키게 된다.
- 따라서 위 예시의 Rhs의 기본 타입은 Point 인스턴스가 된다.

<br />

```rust
// Millimeters + Meters 연산을 수행하는
// Add 트레이트를 Millimeters 구조체에 정의
use std::ops::Add;

struct Millimeters(u32);
struct Meters(u32);

impl Add<Meters> for Millimeters {
    type Output = Millimeters;

    fn add(self, other: Meters) -> Millimeters {
        Millimeters(self.0 + (other.0 * 1000))
    }
}
```

- 이때는 Meters를 더해야 하므로 Rhs 타입 매개변수에 기본 타입으로 지정해야 한다.

<br />

### 19.2.3 불명확성 제거를 위한 완전 식별자 문법: 같은 이름 메서드 호출

```rust
trait Pilot {
    fn fly(&self);
}

trait Wizard {
    fn fly(&self);
}

struct Human;

impl Pilot for Human {
    fn fly(&self) {
        println!("This is your captain speaking.");
    }
}

impl Wizard for Human {
    fn fly(&self) {
        println!("Up!");
    }
}

impl Human {
    fn fly(&self) {
        println!("*waving arms furiously*");
    }
}
```

```rust
// (1)
// *waving arms furiously*
fn main() {
  let person = Human;

    person.fly();
}

// (2)
fn main() {
    let person = Human;
    Pilot::fly(&person);
    Wizard::fly(&person);
    person.fly();
}
```

- 러스트는 각 트레이트에 선언된 같은 이름의 메서드 선언을 허용한다.
- 같은 이름의 메서드를 호출할 때, 러스트 컴파일러는 기본적으로 타입에 직접 구현된 메서드를 호출한다.
- 따라서 (1)은 Human 구조체에 직접 선언한 fly 메서드가 호출된다.
- (2)는 명시적으로 호출하고 있으므로 러스트는 각 트레이트의 메서드를 호출한다.

<br />

```rust
trait Animal {
    fn baby_name() -> String;
}

struct Dog;

impl Dog {
    fn baby_name() -> String {
        String::from("Spot")
    }
}

impl Animal for Dog {
    fn baby_name() -> String {
        String::from("puppy")
    }
}

// (1)
// Spot 출력
fn main() {
    println!("A baby dog is called a {}", Dog::baby_name());
}

// (2)
// Error!
fn main() {
    println!("A baby dog is called a {}", Animal::baby_name());
}

// (3)
// puppy 출력
fn main() {
    println!("A baby dog is called a {}", <Dog as Animal>::baby_name());
}
```

- 트레이트를 구현하는 두 타입이 같은 스코프에 있으면 러스트는 어떤 타입 메서드를 호출할지 알 수 없다.
- (1)은 Dog 구조체가 구현하는 Animal 트레이트가 아닌, Dog 구조체의 메서드가 호출된다.
- (2)는 러스트가 Animal::baby_name가 어떤 함수인지 판단할 수 없어 컴파일 에러가 난다.
  - _error[E0283]: type annotations needed_
  - 연관 함수는 self 매개변수를 포함하지 않기 때문이다.
- (3)은 완전 식별자 문법으로 Dog 구조체가 구현하는 Animal 트레이트의 메서드를 호출한다.
- **완전 식별자 문법: `<타입명 as 트레이트명>::함수(메서드일때_수신자, 다음_매개변수, ...);`**
- 이는 러스트가 어떤 메서드를 호출해야 하는지 스스로 판단할 수 없을 때만 사용한다.

<br />
