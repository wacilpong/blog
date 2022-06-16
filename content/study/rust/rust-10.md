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
