---
title: "After reading Rust book chapter 5"
date: "2022-04-18"
tags: ["rust"]
draft: false
og_description: "Using Structs to Structure Related Data"
---

## 구조체(Structs) 정의와 인스턴스 생성

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
