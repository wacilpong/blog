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

### 19.4.1 함수 포인터

```rust
fn add_one(x: i32) -> i32 {
    x + 1
}

// 매개변수 f는 i32 타입을 받아 i32 타입을 반환하는 함수
fn do_twice(f: fn(i32) -> i32, arg: i32) -> i32 {
    f(arg) + f(arg)
}

fn main() {
    let answer = do_twice(add_one, 5);

    println!("The answer is: {}", answer);
}
```

- 함수를 다른 함수의 인자로 전달하기 위해 함수 포인터를 사용한다.
- 이때 함수는 Fn 트레이트가 아닌 fn 타입으로 강제된다.

<br />

```rust
// 인자로 클로저를 받는 map
let list_of_numbers = vec![1, 2, 3];
let list_of_strings: Vec<String> = list_of_numbers.iter().map(|i| i.to_string()).collect();
```

```rust
// 인자로 함수를 받는 map
// to_string 이름의 함수가 여러 곳에 있으므로 뿌리를 명시
// 여기서는 ToString 트레이트의 메서드를 사용했다.
let list_of_numbers = vec![1, 2, 3];
let list_of_strings: Vec<String> = list_of_numbers.iter().map(ToString::to_string).collect();
```

- 함수 포인터는 클로저의 트레이트 Fn, FnMut, FnOnce를 모두 구현하므로 클로저를 요구하는 함수 인자로도 전달 가능하다.
- 인자로 클로저를 받든 함수를 받든 모두 완전히 같은 코드로 컴파일된다.

<br />

### 19.4.2 클로저 반환하기

```rust
fn returns_closure() -> dyn Fn(i32) -> i32 {
    |x| x + 1
}
```

```sh
$ cargo build
   Compiling functions-example v0.1.0 (file:///projects/functions-example)
error[E0746]: return type cannot have an unboxed trait object
 --> src/lib.rs:1:25
  |
1 | fn returns_closure() -> dyn Fn(i32) -> i32 {
  |                         ^^^^^^^^^^^ doesn't have a size known at compile-time
  |
  = note: for information on `impl Trait`, see <https://doc.rust-lang.org/book/ch10-02-traits.html#returning-types-that-implement-traits>
help: use `impl Fn(i32) -> i32` as the return type, as all return paths are of type `[closure@src/lib.rs:2:5: 2:14]`, which implements `Fn(i32) -> i32`
  |
1 | fn returns_closure() -> impl Fn(i32) -> i32 {
  |                         ~~~~~~~~~~~~~~~~~~~

For more information about this error, try `rustc --explain E0746`.
error: could not compile `functions-example` due to previous error
```

- 클로저는 트레이트로 표현하므로 직접 반환할 수는 없다.
- 러스트는 클로저에 얼마나 메모리를 할당해야 하는지 알 수 없어 컴파일되지 않는다.
- 이때는 트레이트 객체를 이용해 해결할 수 있다.
  ```rust
  fn returns_closure() -> Box<dyn Fn(i32) -> i32> {
      Box::new(|x| x + 1)
  }
  ```

<br />
<hr />

## 19.5 Macros

- 러스트에서 매크로는 `macro_rules!`로 정의하는 매크로와 아래 3가지 매크로를 의미한다.
  - #[derive] 매크로는 구조체와 열거자에 적용된 특성을 상속한다.
  - 특성형 매크로는 어떤 아이템에도 적용할 수 있는 사용자 정의 특성을 정의한다.
  - 함수형 매크로는 함수 호출처럼 보이지만 인자로 전달된 토큰에 적용된다.

<br />

### 19.5.1 매크로와 함수의 차이점

- 매크로는 기본적으로 다른 코드를 작성하는 코드로서 메타프로그래밍(metaprogramming)이다.
- 메타프로그래밍은 개발자가 작성하고 관리해야 하는 코드 양을 줄여준다.
- 함수는 필요한 매개변수 개수와 타입을 선언해야 하지만, 매크로는 매개변수 개수가 가변적이다.
  - println!("안녕")
  - println!("안녕 {}", name)
- 함수는 런타임에 호출되므로 컴파일에 트레이트를 구현할 수 없지만, 매크로는 가능하다.
  - 매크로는 컴파일러가 코드의 의미를 해석하기 전에 확장되기 때문이다.
  - 따라서 주어진 타입의 트레이트를 구현하는 등의 작업을 수행할 수 있다.
- 함수는 어느 곳에든 선언/호출할 수 있지만, 매크로는 꼭 스코프 내에 있어야 한다.

<br />

### 19.5.2 선언적 매크로(declarative macros)

- 러스트에서 일반적으로 사용하는 형태의 매크로이며, match 표현식과 비슷하게 구현할 수 있다.
- 매크로 역시 값을 관련된 코드를 실행하는 패턴과 비교한다.
- 예를 들어, vec! 매크로에 값을 전달해 새로운 벡터를 생성할 수 있다.
  - `let v: Vec<u32> = vec![1, 2, 3];`
  - 함수로는 값의 개수나 타입을 미리 알 수 없으므로 불가능하다.

<br />

```rust
  // vec! 매크로의 간소화된 코드
  #[macro_export]
  macro_rules! vec {
        // $x:expr는 전달되는 표현식이며
        // $x라는 이름을 부여함
      ($( $x:expr ),*) => {
          {
              let mut temp_vec = Vec::new();
              $(
                    // $x 표현식이 일치할 때마다 생성
                    temp_vec.push($x);
              )*
              temp_vec
          }
      };
  }
```

- `macro_rules!`를 통해 매크로를 선언한다.
- `#[macro_export]`은 매크로를 선언한 크레이트를 가져올 때 매크로도 범위로 가져오기 위함이다.
- 본문은 match 표현식과 비슷한데, 하나의 가지 코드로만 구성되었다. `($( $x:expr ),*) =>`
- 해당 가지가 이 매크로의 유일한 패턴이므로 해당 매크로를 사용하는 코드는 꼭 이 패턴에 맞아야 한다.
- 이때 매크로의 패턴은 값이 아니라 러스트 코드 구조와 일치해야 한다.
  - 전체 패턴은 괄호와 달러 기호로 시작한다. `($(전달된 표현식))`
  - 쉼표 다음의 `*`는 앞에 패턴과 일치하는 코드가 있을 수도, 없을 수도 있다는 뜻이다.
  - 예를 들어, `vec![1, 2, 3]`은 표현식이 3개이므로 $x 패텬이 3번 일치하게 된다.
    ```rust
    // vec![1, 2, 3]를 호출하면 생성되는 코드
    {
        let mut temp_vec = Vec::new();
        temp_vec.push(1);
        temp_vec.push(2);
        temp_vec.push(3);
        temp_vec
    }
    ```

<br />

### 19.5.3 절차적 매크로(procedural macros)

```rust
use proc_macro;

#[some_attribute]
pub fn some_name(input: TokenStream) -> TokenStream {
}
```

- 전달되는 러스트 코드를 다른 코드로 대체하는 선언적 매크로와는 달리 그대로 반환한다.
- 절차적 매크로를 생성할 때는 각자의 크레이트 안에 정의해야 한다.

<br />

#### (1) Custom derive Macro 매크로

```rust
use hello_macro::HelloMacro;
use hello_macro_derive::HelloMacro;

#[derive(HelloMacro)]
struct Pancakes;

fn main() {
    Pancakes::hello_macro();
}
```

- HelloMacro 트레이트를 모든 타입에 구현하지 않고, 어노테이션으로 기본 구현되도록 하는 예제이다.

<br />

```rust
// hello_macro/src/lib.rs
pub trait HelloMacro {
    fn hello_macro();
}
```

```rust
// hello_macro/hello_macro_derive/Cargo.toml
[lib]
proc-macro = true

[dependencies]
syn = "0.14.4"
quote = "0.6.3"

// hello_macro/hello_macro_derive/src/lib.rs
use proc_macro::TokenStream;
use quote::quote;
use syn;

#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
    // 러스트 코드를 파싱해 트리 구성
    let ast = syn::parse(input).unwrap();

    // 트레이트 구현체 빌드
    impl_hello_macro(&ast)
}

fn impl_hello_macro(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let gen = quote! {
        impl HelloMacro for #name {
            fn hello_macro() {
                println!("Hello, Macro! My name is {}!", stringify!(#name));
            }
        }
    };
    gen.into()
}
```

- ast.ident 필드로부터 인스턴스를 얻어오며, name 변수에 대입된다.
  - 위 예제에서는 구조체 이름인 `Pancakes`가 저장된다.
- quote! 매크로는 반환할 러스트 코드를 정의한다.
- stringify! 매크로는 러스트에 내장된 매크로이며, 표현식을 문자열 리터럴로 변환한다.

<br />

```rust
// pancakes/Cargo.toml
[dependencies]
hello-macro = {path = "../hello-macro"}
hello-macro-derive = {path = "../hello-macro/hello-macro-derive"}

// pancakes/src/main.rs
use hello_macro::HelloMacro;
use hello_macro_derive::HelloMacro;

#[derive(HelloMacro)]
struct Pancakes;

fn main() {
    Pancakes::hello_macro();
}
```

- `cargo run`으로 실행하면 구조체 이름인 Pancakes가 대입되어 출력된다.
- 절차적 매크로 덕분에 pancakes 크레이트는 HelloMacro 트레이트를 구현하지 않아도 된다.
- #[derive(HelloMacro)] 어노테이션을 통해 트레이트의 기본 구현을 적용할 수 있게 된다.

<br />

#### (2) Attribute-like 매크로

```rust
// (1)
#[route(GET, "/")]
fn index() {

// (2)
#[proc_macro_attribute]
pub fn route(attr: TokenStream, item: TokenStream) -> TokenStream {
```

- derive를 위한 코드가 아니라, 새로운 어트리뷰트를 생성하는 매크로다.
- derive로 상속하는 것보다 유연해서 구조체나 열거자 뿐만 아니라 함수에도 적용할 수 있다.
- 예를 들어 (1)처럼 route 특성을 새롭게 구현할 수 있다.
- route는 (2)처럼 어트리뷰트 자체와 그것을 적용시킬 아이템의 본문을 매개변수로 받는다.
- 결국 동작 자체는 사용자 정의 상속 매크로와 완전히 같다.
- `proc-macro` 크레이트 타입과 함께 크레이트를 생성한 후 원하는 코드를 생성하는 함수를 구현하면 된다.

<br />

#### (3) Function-like 매크로

```rust
// (1)
let sql = sql!(SELECT * FROM posts WHERE id=1);

// (2)
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
```

- 함수 호출과 유사하지만, macro_rules! 매크로처럼 함수보다는 유연하다.
- 예를 들어, 개수가 정해지지 않은 인자를 정의할 수도 있다.
- (1) 매크로는 SQL 구문을 분석해 문법적으로 올바른지 확인하는 매크로다.
- (2)처럼 토큰을 전달받아 원하는 코드를 생성해 반환한다.
- 결국 사용자 정의 상속 매크로의 함수 시그니처와 유사하다.
