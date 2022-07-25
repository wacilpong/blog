---
title: "After reading Rust book chapter 15"
date: "2022-07-22"
tags: ["rust"]
draft: false
og_description: "Smart Pointers"
---

- 포인터(pointer)는 메모리에 주소를 가지고 있는 변수를 일컫는 보편적인 개념이다.
- 러스트에서 가장 대중적인 포인터는 &기호를 사용한 참조, 변수가 가리키는 값을 대여한다.
- 스마트 포인터(smart pointer)는 포인터처럼 동작할 뿐만 아니라 추가 메타데이터를 포함한다.
  - **러스트에서 참조는 데이터를 대여할 수만 있지만, 스마트 포인터는 가리키는 데이터를 소유할 수 있다.**
  - ex. `String`, `Vec<T>` -> 두 타입은 메모리를 소유하며 데이터를 갱신할 수 있다.
  - 스마트 포인터는 주로 구조체를 이용해 구현한다.
  - `Deref`,`Drop` 트레이트를 구현해야 한다.

<br />
<hr />

## 1. Box<T>를 이용한 힙 메모리의 데이터 참조

- Box는 데이터를 힙 메모리에 저장하고, 데이터를 가리키는 포인터만 스택에 저장한다.
- Box를 주로 사용하는 예시:
  - 컴파일 타임에 크기를 알 수 없는 타입을 정확한 크기가 필요한 상황에 사용할 때
  - 데이터 크기가 커서 데이터를 복제하지 않고 소유권만 이전하고 싶을 때
  - 특정 타입이 아닌 특정 트레이트를 구현하는 타입의 값을 소유할 때

<br />

### 1-1. 힙 메모리에 박스 데이터 저장하기

```rust
fn main() {
    let b = Box::new(5);
    println!("b = {}", b);
}
```

- 변수 b에는 힙 메모리에 할당된 5라는 값을 가리키는 Box를 대입한다.
- 소유된 값과 마찬가지로 b는 main 함수 끝에 도달해서 박스가 스코프를 벗어나면 메모리 해제된다.
- 즉, 스택에 저장된 박스와 힙에 저장된 박스가 가리키는 데이터의 메모리가 모두 해제된다.

<br />

### 1-2. 박스와 재귀 타입 활용하기

- 컴파일 타임에 크기를 알 수 없는 타입 중 하나는 재귀 타입(recursive type)이다.
- 재귀 타입이란 같은 타입의 다른 값을 자신의 일부에 포함하는 값이다.
- 값을 중첩하면 이론적으로는 무한할 수 있어서 러스트는 재귀 타입 값에 필요한 공간을 판단할 수 없다.

<br />

#### (1) 리스트 생성자 (cons list, construction list)

- 콘스 리스트는 리스프(Lisp) 언어에 도입된 데이터 구조다.
- 하나의 값과 값의 쌍으로 구성된 두 인수를 이용해 새로운 쌍을 생성한다.
- 함수형 프로그래밍에서 은어적으로, `x를 y에 콘스한다`고 하는데 원소 x를 y 리스트의 첫 부분에 추가해서 새로운 리스트를 생성한다는 의미이다.
- 러스트는 콘스 리스트보다는 보편적으로 Vec<T>를 더 많이 사용한다.
- 하지만 콘스 리스트를 이해하면 박스를 이용해 어렵지 않게 재귀 데이터 타입을 다룰 수 있다.

<br />

```rust
enum List {
    Cons(i32, List),
    Nil,
}
```

```rust
use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Cons(2, Cons(3, Nil)));
}
```

- `Nil`은 재귀의 기본 상태(base case)를 뜻하며, null과는 다르다.
- List는 i32 값의 콘스 리스트인 enum이다.
- List enum을 이용해 1, 2, 3을 리스트에 저장한다.
- 위 코드는 에러를 발생시킨다.
  _error[E0072]: recursive type `List` has infinite size_
  - **선언한 List가 재귀 타입이므로 러스트는 어느 정도의 메모리 공간이 필요한지 알 수 없다.**

<br />

#### (2) 비재귀 타입의 크기를 계산하는 방법

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

- 러스트는 Message 값을 저장하는 데 필요한 공간을 결정하기 위해 모든 열거값을 확인한다.
- 이때 Message 값에 필요한 공간은 가장 큰 열거값을 저장하는 데 필요한 공간이다.
- 이와는 달리 위의 List 같은 재귀 타입은 아래의 일들이 일어난다.
  - (1) 컴파일러는 Cons 열거값을 먼저 확인한다.
  - (2) 이 열거값은 i32 타입과 List 타입의 값을 저장한다.
  - (3) 따라서 Cons는 i32 타입 크기에 List 타입 크기를 더한 공간이 필요하다.
  - (4) List는 필요 공간을 확인하기 위해 다시 Cons 열거값을 확인한다.
  - 위 과정이 무한반복된다.

<br />

#### (3) Box<T>로 재귀 타입의 크기 결정하기

```rust
// (1)
help: insert some indirection (e.g., a `Box`, `Rc`, or `&`) to make `List` representable
  |
2 |     Cons(i32, Box<List>),
  |
```

```rust
// (2)
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
}
```

- 러스트 컴파일러는 List 타입에 대한 에러를 내며 위와 같은 유용한 정보를 함께 제공한다.
- (1)의 메시지는 값을 직접 저장하지 말고, 가리키는 포인터를 통해 간접적으로 저장하라고 알려준다.
- Box<T>는 포인터이고, 포인터의 크기는 가리키는 데이터의 크기와는 무관하다.
- (2)의 Cons 열거값은 이제 i32 타입의 크기에 박스의 포인터 데이터를 저장할 공간만 있으면 된다.
- **List 값에 필요한 메모리 공간은 (i32 크기 + 박스의 포인터 데이터 크기)이다.**
- Box의 크기는 [usize](https://doc.rust-lang.org/std/primitive.usize.html)로, List enum의 크기는 더 이상 무한하지 않다.

<br />
<hr />

## 2. `Deref` 트레이트로 스마트 포인터를 참조처럼 취급하기

- 해당 트레이트를 구현하면
  - 역참조 연산자(\*)의 동작을 변경할 수 있다.
  - 참조를 사용하는 코드를 그대로 스마트 포인터에도 적용할 수 있다.
- 이를 위해 역참조 연산자가 참조를 어떻게 처리하는지부터 알아야 한다.

<br />

### 2-1. 역참조 연산자로 포인터가 가리키는 값 읽어오기

```rust
fn main() {
    let x = 5;
    let y = &x;

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

- 변수 x는 i32 값 5를 저장하고, y는 x의 참조를 저장한다.
- **변수 y를 검증하려면 역참조 연산자를 붙여서 가리키는 값의 참조를 따라가야 한다.**
- 따라서 \*y를 통해 y가 가리키는 값 5에 접근할 수 있다.
- 만약 `assert_eq!(5, y)`라고 작성하면 에러를 낸다.
  _error[E0277]: can't compare `{integer}` with `&{integer}`_
  - 숫자와 숫자에 대한 참조는 다른 타입이므로 둘을 비교할 수 없기 때문이다.

<br />

### 2-2. Box<T>를 참조처럼 사용하기

```rust
fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

- 참조 대신 박스를 사용할 수도 있으며, 이때도 역참조 연산자는 정상 동작한다.
- 박스 타입을 직접 구현하면서 박스가 어떻게 역참조 연산자를 지원하는지 알아보아야 한다.

<br />

### 2-3. 직접 구현하는 스마트 포인터

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

fn main() {}
```

- `Box<T>` 와 비슷한 동작은 갖는 스마트 포인터를 구현해보자.

<br />

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

fn main() {
    let x = 5;
    let y = MyBox::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}

// 실행결과
$ cargo run
   Compiling deref-example v0.1.0 (file:///projects/deref-example)
error[E0614]: type `MyBox<{integer}>` cannot be dereferenced
  --> src/main.rs:14:19
   |
14 |     assert_eq!(5, *y);
   |                   ^^

For more information about this error, try `rustc --explain E0614`.
error: could not compile `deref-example` due to previous error
```

- `MyBox` 구조체는 아직 `Deref` 트레이트를 구현하지 않았기 때문에, 역참조가 발생하면 오류가 난다.
- 실제로 Rust 컴파일러는 `*y`_ 를 `_(y.deref())` 로 변환하여 실행한다.

<br />

### 2-4. Deref 트레이트로 참조같은 타입 구현하기

```rust
use std::ops::Deref;

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

fn main() {
    let x = 5;
    let y = MyBox::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

- `Deref` 트레이트의 `deref()` 메서드를 구현하여 역참조 기능을 구현할 수 있다.
- `Deref` 트레이트는 표준 라이브러리에서 불러온다.
- `type Target = T;` 연관 타입이다. (Ch. 19)
- `deref()` 메서드는 `&Self::Target` 타입 (참조 타입)을 반환한다.
- `&self.0`는 튜플 구조체의 첫번째 아이템을 반환한다.

<br />

### 2-5. 함수와 메서드에서 묵시적 강제 역참조

```rust
use std::ops::Deref;

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &T {
        &self.0
    }
}

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

fn hello(name: &str) {
    println!("Hello, {}!", name);
}

fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&m);
}
```

- 강제 역참조(Deref coercion)란 `Deref` 트레이트를 구현하는 참조 타입을 다른 타입으로 변환하는 것이다.
- 위는 `&MyBox` → `&str` 변환하는 강제 역참조의 예시이다.
  - `Deref` 트레이트를 구현한 `MyBox`
  - `MyBox::deref()` 함수가 `String` 반환
  - `Deref` 트레이트를 구현한 `String`
  - `String::deref()` 함수가 `str` 반환
  - **&m → &String → &str**

<br />

#### [강제 역참조가 없었다면?]

```rust
fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&(*m)[..]);
}
```

- 가독성이 매우 떨어진다.

<br />

### 2-6. 강제 역참조와 가변성

- 불변참조에 `Deref` 트레이트를 사용했던 것처럼 가변참조에는 `DerefMut` 를 사용할 수 있다.
- Rust 는 3가지 경우에 대한 강제 역참조를 수행한다.
  - `T: Deref<Target = U>` 일 때, `&T` → `&U`
  - `T: DerefMut<Target = U>` 일 때, `&mut T` → `&mut U`
  - `T: Deref<Target = U>` 일 때, `&mut T` → `&U`
- 1, 2 번째는 불변/가변 참조끼리의 강제 역참조이다.
- 3번째는 **가변→불변**으로의 강제 역참조인데 이는 **단방향으로써 참조 규칙을 위반하지 않기 위해서**이다.

<br />

#### [다시 살펴보는 참조 규칙]

- 항상 하나의 가변참조, 혹은 다수의 불변 참조만 있어야 한다.
- 참조 변수는 항상 유효해야 한다.

<br />

## 3. Drop 트레이트로 클린업 코드 실행하기

- `Drop` 트레이트는 스마트 포인터가 **스코프 밖으로 나갈때** 클린업 작업을 실행한다.
- ex) 파일이나 네트워크 연결시에 후작업을 하여 메모리나 다른 리소스를 해제하여 프로세스 과부하가 발생하지 않게 한다.

<br />

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {
        data: String::from("my stuff"),
    };
    let d = CustomSmartPointer {
        data: String::from("other stuff"),
    };
    println!("CustomSmartPointers created.");
}

// 실행결과
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.60s
     Running `target/debug/drop-example`
CustomSmartPointers created.
Dropping CustomSmartPointer with data `other stuff`!
Dropping CustomSmartPointer with data `my stuff`!
```

- `Drop` 트레이트의 `drop` 메서드 내부에 클린업 로직을 구현했다.
- c, d 포인터가 스코프 밖으로 나갈때 d, c 순으로 drop 메서드를 호출한다.

<br />

### 3-1. `std::mem::drop` 으로 조기 해제하기

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {
        data: String::from("some data"),
    };
    println!("CustomSmartPointer created.");
    c.drop();
    println!("CustomSmartPointer dropped before the end of main.");
}

// 실행결과
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
error[E0040]: explicit use of destructor method
  --> src/main.rs:16:7
   |
16 |     c.drop();
   |     --^^^^--
   |     | |
   |     | explicit destructor calls not allowed
   |     help: consider using `drop` function: `drop(c)`

For more information about this error, try `rustc --explain E0040`.
error: could not compile `drop-example` due to previous error
```

- `drop` 을 강제적으로 조기에 호출해야할 경우가 있다.
  _ex) 스레드 락을 강제적으로 풀어야 할 때_
- 이때 drop 을 직접적으로 호출하려 하면 아래의 오류 같이 나타난다.
- 따라서 수동으로 해제를 하고 싶을때는 `std::mem::drop` 을 호출하면 된다.

<br />

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {
        data: String::from("some data"),
    };
    println!("CustomSmartPointer created.");
    drop(c);
    println!("CustomSmartPointer dropped before the end of main.");
}

// 실행결과
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
    Finished dev [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/drop-example`
CustomSmartPointer created.
Dropping CustomSmartPointer with data `some data`!
CustomSmartPointer dropped before the end of main.
```

- 기존 스코프와 마찬가지로 drop 된 포인터는 더이상 유효하지 않다.
- 따라서 만약에 실수로 사용될 시, 컴파일러 검사에서 걸리게 된다.
- JavaScript (혹은 Garbage Collector 를 사용하는 언어)는 `delete` 키워드로 객체의 속성을 삭제해도 클린업 실행시점을 예측 할 수가 없다.
  _GC 만의 로직으로 GC 가 실행될때 클린업이 되기 때문에_
