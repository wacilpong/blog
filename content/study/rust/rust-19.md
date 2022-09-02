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

### 19.2.4 Supertraits: 한 트레이트에서 다른 트레이트 기능을 요청

```sh
**********
*        *
* (1, 3) *
*        *
**********
```

```rust
use std::fmt;

// 이 트레이트는 Display 트레이트의 기능을 요구함을 명시
trait OutlinePrint: fmt::Display {
    fn outline_print(&self) {
        // 따라서 Display를 구현하는 타입에 자동으로 구현되는
        // to_string 함수를 사용할 수 있다.
        let output = self.to_string();
        let len = output.len();
        println!("{}", "*".repeat(len + 4));
        println!("*{}*", " ".repeat(len + 2));
        println!("* {} *", output);
        println!("*{}*", " ".repeat(len + 2));
        println!("{}", "*".repeat(len + 4));
    }
}
```

- 값을 애스터리스크(\*)로 꾸며 출력하는 메서드가 있는 OutlinePrint 트레이트를 정의해보자.
- 이때 OutlinePrint는 Display 트레이트의 기능에 의존한다.
- 트레이트 선언부에 `OutlinePrint: Display`처럼 명시해주면 된다.

<br />

```rust
struct Point {
    x: i32,
    y: i32,
}

// (1)
impl OutlinePrint for Point {}

// (2)
use std::fmt;

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}
```

- (1)처럼 Display 트레이트를 구현하지 않는 타입을 OutlinePrint에 구현하려고 하면 에러를 낸다.
  - _error[E0277]: `Point` doesn't implement `std::fmt::Display`_
  - 해결하려면 Point 구조체에 Display 트레이트를 구현해야 한다.
- (2)는 성공적으로 컴파일된다.

<br />

### 19.2.5 뉴타입 패턴으로 외부 타입에 외부 트레이트 구현

- 뉴타입 패턴은 튜플 구조체에 새로운 타입을 생성하는 것이다.
- 튜플은 하나의 필드를 포함하고 트레이트를 구현하고자 하는 타입의 wrapper로 동작한다.
- 그러면 이 wrapper는 크레이트의 로컬 타입이므로 원하는 트레이트를 구현할 수 있다.
- 예를 들어 Vec<T> 타입에 Display 트레이트를 직접 구현할 수 없다.
  - 둘다 크레이트 외부에 정의되어있기 때문이다.
  - 규칙: 어떤 타입에 트레이트를 구현하려면 그 타입/트레이트 중 하나가 로컬이어야 한다.

<br />

```rust
use std::fmt;

struct Wrapper(Vec<String>);

impl fmt::Display for Wrapper {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "[{}]", self.0.join(", "))
    }
}

fn main() {
    let w = Wrapper(vec![String::from("hello"), String::from("world")]);
    println!("w = {}", w);
    // w = [hello, world] 출력
}
```

- Wrapper는 Vec<T>를 감싸는 튜플 구조체이며 self.0으로 저장된 값에 접근한다.
- 단점

  - Wrapper가 새로운 타입이어서 내부에 저장된 값이 제공하는 메서드는 없다.
  - 새 타입이 내부 타입과 완전히 같은 메서드를 제공하게 하려면 Deref 트레이트를 구현해야 한다.

    ```rust
    // 참고
    // 튜플의 첫번째 아이템을 반환하는 deref 메서드를 가짐
    use std::ops::Deref;

    impl<T> Deref for MyBox<T> {
        type Target = T;

        fn deref(&self) -> &Self::Target {
            &self.0
        }
    }
    ```

<br />
<hr />

## 19.3 Advanced Types

### 19.3.1 뉴타입을 이용한 타입안전성과 추상화

```rust
// (1)
struct Millimeters(u32);
struct Meters(u32);

// (2)
struct People(HashMap<i32, String>)
```

- (1)은 u32 타입을 감싸는 뉴타입으로, 값을 명확히 구분하고 단위를 표시한다.
- (2)처럼 People 타입을 사용하는 코드는 오직 사람 이름을 추가하는 메서드처럼 공개 API만 다루게 된다.
  - 뉴타입 패턴은 내부 타입이 제공하는 API와 다른 API를 노출하므로 제한된 기능만 사용하게 한다.
  - 이름이 i32 타입과 관련있다는 사실을 알 필요 없듯, 뉴타입 패턴은 내부 구현 자체도 숨긴다.

<br />

### 19.3.2 타입 별칭으로 동질의 타입 생성

```rust
type Kilometers = i32;
```

- 타입에 다른 이름을 부여하려면 type 키워드를 사용한다.

<br />

```rust
Box<dyn Fn() + Send + 'static>
```

```rust
// AS-IS
fn main() {
    let f: Box<dyn Fn() + Send + 'static> = Box::new(|| println!("hi"));

    fn takes_long_type(f: Box<dyn Fn() + Send + 'static>) {
        // --snip--
    }

    fn returns_long_type() -> Box<dyn Fn() + Send + 'static> {
        // --snip--
        Box::new(|| ())
    }
}

// TO-DO
fn main() {
    type Thunk = Box<dyn Fn() + Send + 'static>;

    let f: Thunk = Box::new(|| println!("hi"));

    fn takes_long_type(f: Thunk) {
        // --snip--
    }

    fn returns_long_type() -> Thunk {
        // --snip--
        Box::new(|| ())
    }
}
```

- 타입 별칭을 쓰는 이유는 중복을 줄이기 위함이다.
- 위 타입을 사용하는 곳에 일일이 작성해야 한다면 힘들고 에러 발생하기도 쉽다.
- Thunk라는 의미 있는 이름으로 별칭을 만들어 중복을 제거하고 코드 의도도 명확히 표현할 수 있다.

<br />

```rust
// (1)
type Result<T> = std::result::Result<T, std::io::Error>;

// (2)
pub trait Write {
    fn write(&mut self, buf: &[u8]) -> Result<usize>;
    fn flush(&mut self) -> Result<()>;

    fn write_all(&mut self, buf: &[u8]) -> Result<()>;
    fn write_fmt(&mut self, fmt: fmt::Arguments) -> Result<()>;
}
```

- (1)처럼 std::io 모듈에서도 타입 별칭을 사용하며, 완전 식별자 별칭이므로 E타입을 생략할 수 있다.
- (2)처럼 Result<T, E>에서 std::io::Error 타입을 생략해서 함수 시그니처를 작성할 수 있다.

<br />

### 19.3.3 절대 반환하지 않는 never 타입

```rust
fn bar() -> ! {
    // --snip--
}
```

- `!` 타입은 아무 값도 없는 빈 타입처럼 동작하며, 러스트 개발팀은 이를 never 타입이라고 부른다.
- 함수가 값을 반환하지 않을 때 반환 타입 자리에 사용하기 때문이다.

<br />

#### (1) continue

```rust
// (1) O
let guess: u32 = match guess.trim().parse() {
    Ok(num) => num,
    Err(_) => continue,
};

// (2) X
let guess = match guess.trim().parse() {
        Ok(_) => 5,
        Err(_) => "hello",
    };
```

- match 표현식의 가지는 반드시 같은 타입을 반환해야 한다.
- 그러면 continue는 어떤 값을 반환할까? 바로 ! 값이다.
- 따라서 러스트는 (1)에서 !는 절대 값을 가질 수 없으므로 guess 변수 타입을 u32로 결정한다.

<br />

#### (2) panic! 매크로

```rust
impl<T> Option<T> {
    pub fn unwrap(self) -> T {
        match self {
            Some(val) => val,
            None => panic!("called `Option::unwrap()` on a `None` value"),
        }
    }
}
```

- unwrap 함수는 Option<T> 타입으로부터 값을 반환하거나 panic! 매크로를 호출시킨다.
- 러스트는 val 변수가 T 타입이고, panic! 매크로가 ! 타입임을 파악해 문제없이 동작한다.

<br />

#### (3) loop

```rust
print!("forever ");

loop {
    print!("and ever ");
}
```

- 위 코드의 루프는 절대 끝나지 않으므로 이 표현식의 값은 !이다.
- 그러나 break문을 추가하면 루프가 종료되므로, 그 경우에는 !가 아니다.

<br />

### 19.3.4 동적 크기 타입과 Sized 트레이트

```rust
// 컴파일되지 않는다.
let s1: str = "Hello there!";
let s2: str = "How's it going?";
```

- 때에 따라 런타임에서 그 크기를 알 수 있는 값을 사용해야 한다.
- str 타입은 그 자체로 동적 크기 타입(dynamically sized types)이다.
- 실제로 코드를 실행하기 전까지는 문자열이 얼마나 긴지 미리 알 수 없기 때문이다.
- 따라서 str 타입의 변수를 생성할 수도 없고 인자로 받을 수도 없다.
- 두 변수를 &str 타입으로 선언하면 되며, 슬라이스는 시작 위치와 길이를 저장하고 있기 때문이다.
- &str 타입의 크기는 항상 정해져 있으므로 길이와 관계없이 문자열을 참조할 수 있다.
  - &str은 str의 주소와 길이 두 값을 갖는다.
  - 러스트의 동적 크기 타입은 대부분 이렇게 동작한다.
  - 즉, 동적인 정보의 크기를 메타데이터에 추가로 저장한다.

<br />

#### Sized 트레이트

```rust
// (1)
fn generic<T>(t: T) {
    // --snip--
}

// (2)
fn generic<T: Sized>(t: T) {
    // --snip--
}

// (3)
fn generic<T: ?Sized>(t: &T) {
    // --snip--
}
```

- 러스트는 컴파일에 타입 크기를 알 수 있는지 결정하는 Sized 트레이트를 제공한다.
- 이 트레이트는 컴파일에 크기가 알려진 모든 타입에 자동으로 구현된다.
- 따라서 (1)은 실제로는 (2)처럼 작성된 것으로 취급된다.
- 제네릭 함수는 컴파일에 크기가 알려진 타입만 사용할 수 있으나, (3) 문법으로 완화할 수 있다.
- `?Sized` 트레이트 경계는 'T는 Sized 트레이트를 구현할 수도 있고 아닐 수도 있다'로 읽는다.
- 이 문법은 Sized 트레이트에만 적용할 수 있고, 구현하지 않을 수도 있으므로 &T로 바꿔야 한다.

<br />

## 19.4 Advanced Functions and Closures
