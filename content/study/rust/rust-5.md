---
title: "After reading Rust book chapter 5"
date: "2022-04-18"
tags: ["rust"]
draft: false
og_description: "Using Structs to Structure Related Data"
---

## 1. 구조체(Structs) 정의와 인스턴스 생성

```rust
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}
```

```rust
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let mut user2 = User {
        // same
    }

    user2.email = String::from("anotheremail@example.com");
}
```

- 구조체는 튜플과 비슷하나, 다음의 차이가 있다.
  - (1) 각 데이터에 이름을 부여해 의미를 더 명확하게 할 수 있다.
  - (2) **이름이 있으므로 인스턴스의 값을 읽거나 참조할 때 순서에 의존할 필요가 없다.**
- 구조체 안의 각 데이터를 필드(field)라고 한다.
- **구조체의 몇몇 필드만 가변적이라고 명시할 수 없고, 전체 인스턴스를 가변적으로 만들 수 있다.**

<br />

### 구조체 데이터의 ownership

```rust
struct User {
    active: bool,
    username: &str,
    email: &str,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        email: "someone@example.com",
        username: "someusername123",
        active: true,
        sign_in_count: 1,
    };
}
```

- User에서 `&str` 대신 String 타입을 사용하는 이유는 **구조체의 각 인스턴스가 데이터의 ownership을 갖게히여 유효한 스코프 내에 존재하는 동안은 데이터 또한 유효할 수 있도록 하기 위한 의도이다.**
- **구조체에서 다른 변수가 소유한 데이터의 참조를 저장하려면 수명(lifetimes)이 필요하다.**
- 수명은 구조체의 유효한 범위 안에서 구조체가 참조하는 데이터가 유효하다고 보장해준다.
- 따라서 위 코드는 에러를 낸다. _missing lifetime specifier_
  _`help: consider introducing a named lifetime parameter`라는 친절한 팁과 함께.._
  _수명에 관해서는 10장에서 자세히 다룸_

<br />

### 구조체에 관한 유용한 문법들

```rust
// (1) shorthand
fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}

// (2) update syntax
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let user2 = User {
        email: String::from("another@example.com"),
        ..user1
    };
}

// (3) tuple structs
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

fn main() {
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}

// (4) Unit-Like Structs
struct AlwaysEqual;

fn main() {
    let subject = AlwaysEqual;
}
```

- (1)의 구조체의 필드 초기화 단축 문법을 사용해 변수명을 일일이 입력할 필요가 없다.
- (2)의 구조체 갱신 문법은 `=`처럼 할당하는 것이므로 데이터가 이동된다.
  - **즉, 위 예시에서 user1은 user2로 이동되었기 때문에 더이상 사용할 수 없다.**
  - **만약 email, username 모두 새 문자열을 할당한다면 user1에는 `copy trait`를 가진 타입(불리언, 정수)만 존재하므로 user1은 user2가 생성되어도 여전히 유효할 것이다.**
- (3)은 튜플 구조체로, 알반 구조체처럼 각 필드에 이름을 부여하는 것이 불필요하지만 튜플 자체에는 이름을 부여해서 다른 튜플들과 구분해야할 때 유용하다.
  - black과 origin은 같은 타입들을 포함하고 있지만, 각각 다른 튜플 구조체의 인스턴스이므로 서로 다른 타입이다.
  - 이외에는 다른 튜플들과 똑같이 동작한다.
- (4)처럼 필드가 하나도 없는 구조체는 `()`과 유사하게 동작해서 유사 유닛 구조체라고 부른다.
  - 테스팅 목적으로 AlwaysEqual의 모든 인스턴스가 다른 타입의 모든 인스턴스와 동일하게 구현할 때 유용하다.
  - 즉, 어떤 타입의 trait를 구현하지만 타입에 저장할 데이터는 없을 때 유용하다.

<br />
<hr />

## 2. 사례: Rectangles 프로그램

```rust
// (1)
fn main() {
    let width1 = 30;
    let height1 = 50;

    println!(
        "The area of the rectangle is {} square pixels.",
        area(width1, height1)
    );
}

fn area(width: u32, height: u32) -> u32 {
    width * height
}
```

```rust
// (2)
fn main() {
    let rect1 = (30, 50);

    println!(
        "The area of the rectangle is {} square pixels.",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.width * rectangle.height
}
```

- 사각형의 면적을 구하는 프로그램으로, area 함수의 두 매개변수는 연관되어 있다.
- 그러나 프로그램 어디에도 두 매개변수의 관계를 표현하고 있지 않다.
- 튜플을 이용해 (2)처럼 하나의 매개변수만 전달하도록 리팩토링할 수 있다.
- 그러나 각 요소에 이름이 없어서 계산 과정에서 튜플의 인덱스로 접근하고 있다.
- 구조체를 이용해 (3)처럼 width, height라는 명확한 이름의 필드값으로 Rectangle 인스턴스를 계산할 수 있다.

<br />

### 트레이트(trait)로 유용한 기능 추가하기

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {}", rect1);
}
```

- Rectangle 구조체를 디버깅하기 위해 println! 매크로를 찍은 위 코드는 에러를 낸다.
  _Rectangle doesn't implement std::fmt::Display_
  _help: the trait std::fmt::Display is not implemented for Rectangle_
  _note: in format strings you may be able to use `{:?}` (or {:#?} for pretty-print) instead_
- println! 매크로는 다양한 포맷의 문자열을 출력할 수 있고, 중괄호는 `Display` 포맷을 출력하라는 의미이다.
- i32와 같은 원시 타입들은 1을 숫자 1로 보여주는 것처럼, 자신을 표현할 방법이 하나다.
- 반면 구조체는 값들을 쉼표로 구분할지, 중괄호까지 보여줄지 등 불명확하다.
- 따라서 러스트는 구조체가 Display 크레이트를 구현하지 않도록 두었다.

<br />

```rust
...
println!("rect1 is {:?}", rect1);
```

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {:?}", rect1);
}
```

- 에러의 친절한 팁대로 구현해도 에러를 낸다.
  _error[E0277]: Rectangle doesn't implement Debug_
  _help: the trait Debug is not implemented for Rectangle_
  _note: add #[derive(Debug)] to Rectangle or manually impl Debug for Rectangle_
- 중괄호 안의 `:?` 연산자를 지정하면 매크로는 Debug 포맷으로 출력한다.
- 러스트는 디버깅 정보를 출력하는 기능만 제공할 뿐, 구조체에 직접 이를 구현해주어야 한다.
- `#[derive(Debug)]`를 구조체 선언 전에 추가해주어 Debug포맷을 출력할 수 있다.
- {:?} 대신 `{:#}`을 이용하면 중괄호가 정돈된 형태로 출력할 수 있다.

<br />

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

```sh
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 1.24s
     Running `{mydirpath}/rectangles/target/debug/rectangles main.rs`
[src/main.rs:10] 30 * scale = 60
[src/main.rs:14] &rect1 = Rectangle {
    width: 60,
    height: 50,
}
}
```

- [dbg!](https://doc.rust-lang.org/std/macro.dbg.html) 매크로를 통해 파일과 라인에 결과값을 함께 출력할 수 있다.
- 이를 통해 표현식의 결과값을 처리하고 ownership을 반환할 수 있다.
- 따라서 dbg! 매크로는 표현식의 값에 대한 ownership을 반환하므로 `30 * scale`라는 표현식에 써도 된다.
- [`derive` 어노테이션을 통해 더 다양한 사용자 정의 타입을 위한 트레이트](https://doc.rust-lang.org/book/appendix-03-derivable-traits.html)를 제공한다.
- area 함수는 사각형의 면적을 구하므로 Rectangle 구조체에 대해서만 사용하게 만드는 것이 더 효율적이다.
- 이때 area 함수를 Rectangle 타입의 메서드로 만들 수 있다.

<br />
<hr />

## 3. 메서드(Method)

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        rect1.area()
    );
}
```

- area 메서드 시그니처를 보면 `&Rectangle`이 아닌, `&self`를 사용하고 있다.
- Rectangle 구조체 컨텍스트 안에 존재하므로 러스트는 이미 self가 Rectangle 타입이라는 것을 안다.
- &self는 `self: &Self`을 줄인 말이다.
- 메서드가 Self타입 인스턴스를 사용해야 하므로(빌려와야 하므로) &를 붙인다.
- 메서드는 self의 ownership을 갖거나, 이 예제처럼 self의 불변 인스턴스를 빌리거나, 매개변수들처럼 self의 가변 인스턴스를 빌려올 수 있다.
- 위 코드에서는 구조체의 데이터를 읽을 뿐 값을 쓰지 않기 때문에 굳이 ownership을 가질 필요가 없는데, 만약 메서드를 호출한 인스턴스의 값을 변경하고자 한다면 `&mut self`로 선언해야 한다. 이는 self를 다른 인스턴스로 교체하고 호출자가 더 이상 예전 인스턴스를 사용하지 못하도록 할 때 활용하는 기법이다.

<br />

```rust
impl Rectangle {
    fn width(&self) -> bool {
        self.width > 0
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    if rect1.width() {
        println!("The rectangle has a nonzero width; it is {}", rect1.width);
    }
}
```

- 어떤 목적으로든 구조체에 존재하는 같은 이름의 메서드를 만들 수 있다.
- 종종 필드의 값만 반환하고 다른 작업은 수행할 필요없을 때 사용한다.
  - _마치 getter_
  - getter는 메서드는 public하지만 필드는 private으로 만들 수 있다.
  - 따라서 public API의 일부로 해당 필드에 대해 읽기 전용으로 만들 수 있다.

<br />

### 특징

```rust
// (1)
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

```rust
// (2)
impl Rectangle {
    fn square(size: u32) -> Rectangle {
        Rectangle {
            width: size,
            height: size,
        }
    }
}
```

```rust
// (3)
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

- (1)처럼 메서드에 여러 매개변수를 전달하려면 self 이후에 원하는 만큼 추가하면 된다.
- (2)처럼 self 매개변수를 굳이 사용하지 않는 다른 함수도 정의할 수 있다,
  - 구조체 인스턴스를 직접 전달받지 않으므로 메서드가 아니라 `연관 함수(associated function`이다.
  - 구조체의 새로운 인스턴스를 반환하는 생성자(constructor)를 구현할 때 자주 사용한다.
  - 연관 함수를 호출하려면 구조체 이름에 `::` 문법을 사용한다.
  - ex. `String::from`
  - ex. `let sq = Rectangle::square(3);`
- (3)처럼 여러 개의 impl 블록을 선언하는 것도 가능하며, 제네릭(generic)과 트레이트(trait)에서 유용하게 활용될 수 있다. _이는 10장에서 자세히 다룸_
