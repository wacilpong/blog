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

- `drop` 을 강제로 조기에 호출해야할 경우가 있다.
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

<br />
<hr />

## 4. Rc<T>, 참조 카운터 스마트 포인터

- 하나의 값을 여러 변수가 소유하는 때는 값에 대한 해제가 어렵다.
  - ex) 그래프에서 여러 엣지가 같은 노드를 가리킬 때
  - 이 노드는 자신을 가리키는 엣지가 모두 사라질 때까지 해제할 수 없다.
- 러스트는 다중 소유권을 위해 참조 카운터(reference counting) `Rc<T>` 타입을 지원한다.
- Rc<T> 타입은 프로그램의 여러 부분에서 데이터를 읽을 수 있게 힙 메모리에 저장할 때 사용한다.

<br />

### 4-1. Rc<T> 타입을 이용해 데이터 공유하기

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
    let b = Cons(3, Box::new(a));
    let c = Cons(4, Box::new(a));
}
```

```rust
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
error[E0382]: use of moved value: `a`
  --> src/main.rs:11:30
   |
9  |     let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
   |         - move occurs because `a` has type `List`, which does not implement the `Copy` trait
10 |     let b = Cons(3, Box::new(a));
   |                              - value moved here
11 |     let c = Cons(4, Box::new(a));
   |                              ^ value used here after move

For more information about this error, try `rustc --explain E0382`.
error: could not compile `cons-list` due to previous error
```

- Cons 열거값은 자신이 저장한 데이터를 소유하고 있다.
- 따라서 b 리스트를 생성할 때 a가 b로 이동하여 b가 a를 소유한다.
- 그래서 c 리스트를 생성하는 코드는 a가 이미 이동했으므로 동작하지 않는다.

<br />

```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    let b = Cons(3, Rc::clone(&a));
    let c = Cons(4, Rc::clone(&a));
}
```

- Box<T> 대신 Rc<T> 타입을 사용해 b를 생성할 때 a가 가지고 있는 Rc<List>를 복제한다.
- 이를 통해 참조의 개수가 2개로 늘어나 **a와 b가 Rc<List>의 데이터에 대한 소유권을 공유한다.**
- c를 생성할 때도 복제가 발생해 참조 개수가 3개로 늘어나게 된다.
- **즉, Rc::clone을 호출할 때마다 Rc<List> 데이터에 대한 참조 카운트가 증가한다.**
- **참조가 모두 사라질 때까지 데이터는 해제되지 않는다.**
- Rc::clone(&a) 대신 a.clone()을 호출해도 되나, 전자가 러스트의 관례다.
  - Rc::clone 함수는 대부분 타입이 지원하는 clone 메서드처럼 깊은 복사를 수행하지 않는다.

<br />

### 4-2. Rc<T>의 복제는 참조 카운트를 증가시킨다.

```rust
fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    println!("count after creating a = {}", Rc::strong_count(&a));
    let b = Cons(3, Rc::clone(&a));
    println!("count after creating b = {}", Rc::strong_count(&a));
    {
        let c = Cons(4, Rc::clone(&a));
        println!("count after creating c = {}", Rc::strong_count(&a));
    }
    println!("count after c goes out of scope = {}", Rc::strong_count(&a));
}
```

- 참조 카운트를 얻는 함수명이 `strong_count`인 이유는 `weak_count` 함수도 제공하기 때문이다.
- 위 코드는 clone 함수를 호출할 때마다 카운트가 1씩 증가한다.
- c가 스코프를 벗어나면 1 감소한다.
- Drop 트레이트는 Rc<T> 값이 스코프를 벗어나면 자동으로 참조 카운트를 감소한다.
- **Rc<T>는 불변 참조를 통해 프로그램의 여러 부분에서 공유하는 데이터의 값을 읽을 수 있게 한다.**

<br />
<hr />

## 5. RefCell<T> 타입과 내부 가변성 패턴

- 내부 가변성(Interior mutability)
  - 러스트가 데이터의 불변 참조를 이용해서 데이터를 가공할 수 있게 지원하는 디자인 패턴이다.
  - 즉, 불변 값 안에 저장된 값을 변경하는 패턴이다.
  - 데이터 구조 안에 unsafe 코드를 사용해 러스트의 규칙을 우회한다.
  - 컴파일러가 보장하지 못해도, 런타임에 대여 규칙 적용이 확실하다면 이 패턴을 활용하자.
  - 이때 unsafe 코드는 안전한 API로 감싸지게 되어, 밖에서는 여전히 불변하다.

<br />

### 5-1. RefCell<T> 타입으로 런타임에 대여 규칙 강제하기

- Rc<T>와 달리 자신이 보유한 데이터에 대한 단일 소유권을 표현한다.
- 참조와 Box<T> 타입은 대여 규칙의 불변성질이 컴파일 타임에 평가된다.
- 하지만 RefCell<T> 타입은 이 불변성질이 런타임에 적용된다.
- **따라서 참조는 규칙이 위반되면 컴파일 에러가 발생하지만, RefCell<T>는 패닉을 리턴하고 종료된다.**
- 대여 규칙을 컴파일 적용하면
  - 개발 과정에서 모든 분석이 이미 완료되었으므로 런타임 성능 손실이 없다.
  - 대부분 대여 규칙을 컴파일에 확인하는 것이 최선이므로 러스트에서 디폴트인 이유다.
- 대여 규칙을 런타임 적용하면
  - 컴파일타임 검사 때문에 할 수 없던 메모리 안전성 작업을 수행할 수 있다.
  - ex) 시스템 정지(halting) 문제 - 입력값을 넣었을 때 정지할지 말지
- Rc<T> 타입과 마찬가지로 RefCell<T>도 단일 스레드 환경에서만 사용해야 한다.

<br />

### 5-2. 내부 가변성: 불변 값에 대한 가변 대여

```rust
fn main() {
    let x = 5;
    let y = &mut x;
}
```

```rust
$ cargo run
   Compiling borrowing v0.1.0 (file:///projects/borrowing)
error[E0596]: cannot borrow `x` as mutable, as it is not declared as mutable
 --> src/main.rs:3:13
  |
2 |     let x = 5;
  |         - help: consider changing this to be mutable: `mut x`
3 |     let y = &mut x;
  |             ^^^^^^ cannot borrow as mutable

For more information about this error, try `rustc --explain E0596`.
error: could not compile `borrowing` due to previous error
```

- 대여 규칙에 따르면 위 코드는 컴파일되지 않는다.
- 때로는 값을 불변하게 유지하면서 값이 제공하는 메서드를 통해 값을 변경해야할 수도 있다.
- 이때 RefCell<T>를 사용하며, 이 타입은 대여 규칙을 우회하는 것이 아니다.

<br />

#### (1) 내부 가변성의 활용 예: Mock Objects

- 러스트에는 객체라는 개념이 없어, 표준 라이브러리로 mock 객체를 지원하지 않는다.
- 따라서 그러한 역할을 하는 구조체를 직접 정의하면 된다.

<br />

```rust
// 현재 값이 최대값에 얼마나 가까워지는지 추적하여
// 일정 수준이 되면 경고를 보내는 라이브러리
pub trait Messenger {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: Messenger> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &'a T, max: usize) -> LimitTracker<'a, T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;

        if percentage_of_max >= 1.0 {
            self.messenger.send("Error: You are over your quota!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Urgent warning: You've used up over 90% of your quota!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warning: You've used up over 75% of your quota!");
        }
    }
}
```

- Messenger 트레이트의 send 메서드는 mock 객체가 구현해야 할 인터페이스다.
- 테스트를 위해 원하는 메시지로 send 메서드가 호출되는지 확인할 mock 객체가 필요하다.

<br />

```rust
#[cfg(test)]
mod tests {
    use super::*;

    struct MockMessenger {
        sent_messages: Vec<String>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: vec![],
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            self.sent_messages.push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        let mock_messenger = MockMessenger::new();
        let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

        limit_tracker.set_value(80);

        assert_eq!(mock_messenger.sent_messages.len(), 1);
    }
}
```

- 이 테스트에서 send 메서드는 매개변수로 전달된 메시지를 sent_messages 리스트에 저장한다.
- LimitTracker에 최대값의 75%보다 큰 값을 지정해 테스트하고 있다.

<br />

```rust
$ cargo test
   Compiling limit-tracker v0.1.0 (file:///projects/limit-tracker)
error[E0596]: cannot borrow `self.sent_messages` as mutable, as it is behind a `&` reference
  --> src/lib.rs:58:13
   |
2  |     fn send(&self, msg: &str);
   |             ----- help: consider changing that to be a mutable reference: `&mut self`
...
58 |             self.sent_messages.push(String::from(message));
   |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `self` is a `&` reference, so the data it refers to cannot be borrowed as mutable

For more information about this error, try `rustc --explain E0596`.
error: could not compile `limit-tracker` due to previous error
warning: build failed, waiting for other jobs to finish...
error: build failed
```

- send 메서드는 self에 대한 가변 참조를 받기 때문에 MockMessenger 인스턴스를 변경할 수 없다.
- Messenger 트레이트의 send 메서드 시그니처를 변경해야 하므로 &mut self를 사용하기도 힘들다.
- 이 경우 내부 가변성이 필요하다.
- sent_messages 필드를 RefCell<T> 타입으로 선언해보자.

<br />

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::RefCell;

    struct MockMessenger {
        sent_messages: RefCell<Vec<String>>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: RefCell::new(vec![]),
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            self.sent_messages.borrow_mut().push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        // --snip--

        assert_eq!(mock_messenger.sent_messages.borrow().len(), 1);
    }
}
```

- sent_messages 필드는 이제 Vec<String>이 아니라 `RefCell<Vec<String>>` 타입이다.
- **RefCell 타입의 borrow 메서드를 호출해 벡터에 대한 불변 참조를 가져와 검증할 수 있다.**

<br />

#### (2) RefCell<T> 이용해 런타임에 대여 검사하기

```rust
// 같은 스코프에서 두 가변 참조를 생성함

impl Messenger for MockMessenger {
    fn send(&self, message: &str) {
        let mut one_borrow = self.sent_messages.borrow_mut();
        let mut two_borrow = self.sent_messages.borrow_mut();

        one_borrow.push(String::from(message));
        two_borrow.push(String::from(message));
    }
}
```

```rust
failures:
---- tests::it_sends_an_over_75_percent_warning_message stdout ----
thread 'main' panicked at 'already borrowed: BorrowMutError', src/lib.rs:60:53
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

- `borrow` 메서드는 스마트 포인터 타입 Ref<T>를 반환한다.
- `borrow_mut` 메서드는 스마트 포인터 타입 RefMut<T>를 반환한다.
- 모두 Deref 트레이트를 구현하므로 보통의 참조와 같은 방식으로 동작한다.
- RefCell<T>은 활성화된 Ref<T>, RefMut<T>의 스마트 포인트 개수를 추적한다.
- 컴파일타임 대여 규칙과 마찬가지로 어느 한 시점에 다수의 불변 대여나 하나의 가변 대여만 허용한다.
- 이 규칙을 위반하면 참조에서의 컴파일 에러와 달리 런타임 패닉을 발생한다.
- 따라서 위 테스트는 대여 규칙 위반 확인을 RefCell<T>에 의해 런타임에 실행하므로 실패한다.

<br />

- 대여 에러를 런타임에 확인하는 것은 코드상의 실수를 개발 과정에서 발견할 수 없다는 뜻이다.
- **런타임에서 대여에 대한 회수를 추적하므로 약간의 런타임 성능 손실이 발생할 수도 있다.**
- **하지만 RefCell<T>은 꼭 불변값을 사용해야 할 때도 자신을 변경하는 mock 객체를 작성할 수 있다.**
- **따라서 일반적인 참조보다 더 많은 기능이 필요하면 손실을 감수하고 RefCell<T> 타입을 쓰면 된다.**

<br />

### 5-3. Rc<T>와 RefCell<T> 조합해 가변 데이터에 다중 소유권 적용하기

```rust
#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

fn main() {
    let value = Rc::new(RefCell::new(5));

    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

    let b = Cons(Rc::new(RefCell::new(3)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(4)), Rc::clone(&a));

    *value.borrow_mut() += 10;

    println!("a after = {:?}", a);
    println!("b after = {:?}", b);
    println!("c after = {:?}", c);
}
```

- RC<T>는 데이터에 다중 소유권을 적용하지만, 그 데이터에 대한 불변 접근만 허용한다.
- **하지만 RC<T>에 RefCell<T>을 저장하면 다중 소유권이 적용된 데이터를 수정할 수도 있다.**
- 위 코드에서 value에서 a로 소유권을 넘기거나 value에서 값을 대여하고 있지 않다.
  - `clone`을 호출해 a와 value 모두 내부 값 5에 대한 소유권을 갖게 한다.
- `borrow_mut`를 호출할 때 Rc<T>를 내부 RefCell<T> 값으로 자동 역참조한다.
- 이제 a, b, c는 모두 15가 출력된다.
- **RefCell<T>로 외부에서는 불변인 List 값을 생성하지만 borrow 메서드로 데이터를 수정할 수 있다.**
- **trade-off: 런타임에 실행되는 대여 규칙은 데이터 경합을 방지하나(구조의 유연성), 속도를 희생한다.**

<br />
<hr />

## 6. 순환참조는 메모리 누수를 일으킨다.

- 아무리 러스트가 메모리 안전성을 보장해도 실수로 메모리를 해제하지 않으면 메모리 누수가 일어난다.
- 러스트가 컴파일의 데이터 경합을 완전히 막지 않듯이 메모리 누수도 마찬가지다.
  - Rc<T>, RefCell<T>가 메모리 누수를 허용하는 것처럼
  - 서로가 서로를 참조하는 참조를 생성할 수 있다.
  - 그렇게 되면 서로에 대한 참조 카운트가 0이 되지 않으므로 이 값들은 절대 해제되지 않는다.

<br />

### 6-1. 순환참조 생성하기

```rust
use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug)]
enum List {
    Cons(i32, RefCell<Rc<List>>),
    Nil,
}

impl List {
    fn tail(&self) -> Option<&RefCell<Rc<List>>> {
        match self {
            Cons(_, item) => Some(item),
            Nil => None,
        }
    }
}

fn main() {
    let a = Rc::new(Cons(5, RefCell::new(Rc::new(Nil))));

    println!("a initial rc count = {}", Rc::strong_count(&a));
    println!("a next item = {:?}", a.tail());

    let b = Rc::new(Cons(10, RefCell::new(Rc::clone(&a))));

    println!("a rc count after b creation = {}", Rc::strong_count(&a));
    println!("b initial rc count = {}", Rc::strong_count(&b));
    println!("b next item = {:?}", b.tail());

    if let Some(link) = a.tail() {
        *link.borrow_mut() = Rc::clone(&b);
    }

    println!("b rc count after changing a = {}", Rc::strong_count(&b));
    println!("a rc count after changing a = {}", Rc::strong_count(&a));

    // 순환참조가 생성된 것을 확인하려면 아래 코드 주석을 해제한다.
    // 하지만 그러면 스택 오버플로가 발생한다.
    // println!("a next item = {:?}", a.tail());
}
```

- List 열거자는 Cons 열거값이 가리키는 List값을 수정할 수 있도록 선언되었다.
- `tail` 메서드는 Cons 열거값이 저장된 두 번째 원소에 쉽게 접근하기 위해 선언되었다.
- 이때 b가 a를 가리키도록 생성하고 a가 다시 b를 가리키도록 하면 순환참조가 생성된다.
  - `a.tail`을 호출해 RefCell<Rc<List>>에 대한 참조를 얻어 link 변수에 저장한다.
  - `borrow_mut`을 호출해 Rc<List> 안에 저장된 Nil을 b에 저장된 Rc<List> 값으로 변경한다.

<br />

```rust
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
    Finished dev [unoptimized + debuginfo] target(s) in 0.53s
     Running `target/debug/cons-list`
a initial rc count = 1
a next item = Some(RefCell { value: Nil })
a rc count after b creation = 2
b initial rc count = 1
b next item = Some(RefCell { value: Cons(5, RefCell { value: Nil }) })
b rc count after changing a = 2
a rc count after changing a = 2
```

- a가 b를 가리키도록 변경하면 두 리스트의 Rc<List>에 대한 참조 카운트는 2가 된다.
- main 함수 마지막에 b를 해제하면 Rc<List> 참조 카운트는 1로 감소한다.
- 여전히 a가 b였던 Rc<List>를 참조하고 있으므로 Rc<List>가 저장되었던 힙 메모리는 해제되지 않는다.
- **따라서 마지막 주석을 해제하면 a가 가리키는 b가 가리키는 a를 출력하려고 하므로 스택 오버플로가 발생한다.**
- 이때 러스트는 순환참조를 생성하는 순간 프로그램을 중단시킨다.

<br />

### 6-2. 순환참조 방지: Rc<T> 대신 Weak<T> 활용하기

- `Rc::clone`은 Rc<T> 인스턴스의 string_count 값을 증가시키고, 이 값이 0인 인스턴스만 해제한다.
- `Rc::downgrade` 메서드는 Rc<T> 인스턴스의 weak_count 값을 증가시키고, 0이 아니어도 해제된다.
- 강한 참조는 Rc<T> 인스턴스에 대한 소유권을 공유하지만, 약한 참조는 소유권 관계를 표현하지 않는다.
- Weak<T> 참조는 언제든 해제될 수 있어서 반드시 가리키는 값이 유효한지 확인해야 한다.
- Weak<T>의 `upgrade` 메서드는 Option<T>를 반환한다.
  - **참조하는 값이 해제되지 않았으면 Some<Rc<T>>를 반환하고, 해제되었으면 None을 반환한다.**
  - 결과적으로 유효하지 않은 포인터를 잘못 사용하는 상황은 일어나지 않는다.

<br />

#### (1) 트리 데이터 구조: 자식 노드를 갖는 노드

```rust
use std::cell::RefCell;
use std::rc::Rc;

// Node는
// 1. 자식 노드에 대한 소유권을 가져야 함
// 2. 저장할 변수가 트리의 각 노드에 접근하게 소유권을 변수와 공유해야 함
// 3. 각 노드는 다른 노드의 자식 노드를 변경할 수 있어야 함
// => RefCell<Vec<Rc<Node>>>
#[derive(Debug)]
struct Node {
    value: i32,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        children: RefCell::new(vec![]),
    });

    let branch = Rc::new(Node {
        value: 5,
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });
}
```

- leaf 안에 저장된 Node는, leaf와 branch 두 인스턴스가 공유하게 된다.
- branch.children을 통해 branch를 통해 leaf에 접근할 수 있다.
- 그러나 leaf는 branch 인스턴스에 대한 참조가 없으므로 접근할 수 없다.
- 따라서 leaf 인스턴스가 branch 인스턴스를 부모 노드로 인식하게 만들어야 한다.

<br />

#### (2) 부모 노드의 참조를 자식 노드에 추가하기

```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

// parent 필드가 Rc<T> 타입이라면:
// 1.leaf.parent는 branch를 가리킴
// 2. branch.children은 leaf를 가리킴
// => 순환참조 발생
#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());

    let branch = Rc::new(Node {
        value: 5,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });

    *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
}
```

- 부모 노드가 해제되면 자식 노드도 함께 해제되도록 부모 노드는 자식 노드를 소유해야 한다.
- **자식 노드 하나가 해제되어도 부모 노드는 존재해야 하며, 이 경우가 바로 약한 참조에 해당한다.**
- 따라서 위 코드의 Node는 부모 노드를 참조할 수 있지만 소유하지는 않는다.
- `upgrade` 메서드로 leaf 인스턴스의 부모에 대한 참조를 가져오면 None 값이 반환된다.
- leaf를 branch의 자식 노드로 대입한 후에는 이제 Some 값이 반환된다.
  ```rust
  leaf parent = Some(Node { value: 5, parent: RefCell { value: (Weak) },
  children: RefCell { value: [Node { value: 3, parent: RefCell { value: (Weak) },
  children: RefCell { value: [] } }] } })
  ```

<br />

#### (3) strong_count와 weak_count 값 확인하기

```rust
fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    // leaf strong = 1, weak = 0
    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    );

    {
        let branch = Rc::new(Node {
            value: 5,
            parent: RefCell::new(Weak::new()),
            children: RefCell::new(vec![Rc::clone(&leaf)]),
        });

        *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

        // branch strong = 1, weak = 1
        // leaf.parent 필드가 Weak<Node> 타입을 이용해
        // branch 인스턴스를 가리키고 있기 때문임
        println!(
            "branch strong = {}, weak = {}",
            Rc::strong_count(&branch),
            Rc::weak_count(&branch),
        );

        // leaf strong = 2, weak = 0
        // branch가 leaf 인스턴스에 저장된 Rc<Node> 복제본을
        // branch.children 필드에 저장하고 있어서임
        println!(
            "leaf strong = {}, weak = {}",
            Rc::strong_count(&leaf),
            Rc::weak_count(&leaf),
        );
    }

    // leaf parent = None
    // branch 인스턴스의 스코프가 끝나므로 Node가 해제되기 때문임
    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());

    // leaf strong = 1, weak = 0
    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    );
}
```

- 참조의 수와 값의 해제를 관리하는 모든 코드는 Rc<T>와 Weak<T>에 구현되어 있다.
- 둘은 모두 Drop 트레이트를 구현하고 있다.
- **부모와 자식의 관계를 Weak<T> 참조로 표현하면 순환참조 걱정 없이 부모-자식 노드를 참조시킬 수 있다.**
