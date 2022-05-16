---
title: "After reading Rust book chapter 7"
date: "2022-05-10"
tags: ["rust"]
draft: false
og_description: "Managing Growing Projects with Packages, Crates, and Modules"
---

- 기능들을 그룹화하고 구현을 캡슐화하는 과정을 통해 코드의 차원을 높일 수 있다.
- 코드의 어떤 부분을 다른 코드를 위해 공개/비공개할지 정해야 한다.
- 이는 스코프(scope)와 관련이 있다.
  - 스코프는 일종의 중첩된 컨텍스트다.
  - 특정 스코프 내에 사용된 중복될 수 없다.
  - 개발자와 컴파일러는 특정 지점의 특정 이름이 변수, 함수, 구조체 등 무엇을 의미하는지 알아야 하므로 스코프가 필요하다.
- 따라서 러스트는 코드의 구조를 관리하기 위한 모듈시스템을 제공한다.
  - `Packages`: 크레이트를 빌드, 테스트, 공유할 수 있는 cargo feature
  - `Crates`: 라이브러리나 실행 파일을 생성하는 모듈들의 트리
  - `Modules and use`: 스코프, 경로에 대한 접근성을 제어할 수 있게 해줌
  - `Paths`: 구조체, 함수, 모듈 등의 이름을 짓는 방식

<br />
<hr />

## Packages and Crates

- 크레이트(Crates)는 하나의 바이너리 혹은 라이브러리다.
  - `crate root`: 러스트 컴파일러가 컴파일을 시작해서 크레이트의 루트 모듈을 만들어 내는 소스 파일
- 패키지(Packages)는 일련의 기능을 제공하는 하나 이상의 크레이트를 의미한다.
  - 그러나 라이브러리 크레이트는 최대 1개만 가질 수 있다. -> _lib.rs 엔트리!_
  - 패키지는 `Cargo.toml`파일을 통해 그 크레이트를 빌드하는 방법을 명시한다.
  - Cargo.toml에 `src/main.rs`, `src/lib.rs` 파일이 서술되어 있지 않다.
  - **이는 규칙이다: 두 파일은 바이너리/라이브러리 크레이트의 crate root이며, 그 패키지와 같은 이름이다.**
  - **cargo는 라이브러리나 바이너리를 빌드할 때 rustc 컴파일러에게 crate root 파일을 전달한다.**
- 크레이트는 관련 기능들을 하나의 스코프로 묶어서, 그 기능을 여러 프로젝트에서 공유하기 수월해진다.
  _ex. 난수 생성에 사용하는 `rand` 크레이트_
- rand 크레이트에 Rng라는 이름의 트레이트를 제공하지만, 개발자가 그 이름으로 어떤 구조체를 만들어도 된다.
  - 크레이트의 기능은 자신의 스코프 안에 구현되어 있기 때문이다.
  - Rng 트레이트는 `rand::Rng`로 접근하기 떄문이다.
  - 따라서 같은 이름이 있더라도 rand를 의존성으로 추가해도 상관없다.

<br />

## 모듈을 이용한 스코프와 접근성(Privacy) 제어

```rust
// (1)
// cargo new --lib restaurant
// src/lib.rs
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}
        fn serve_order() {}
        fn take_payment() {}
    }
}
```

```rust
// (2)
crate
└── front_of_house
   ├── hosting
   │   ├── add_to_waitlist
   │   └── seat_at_table
   └── serving
       ├── take_order
       ├── serve_order
       └── take_payment

```

- **모듈은 코드의 특정 아이템을 외부의 코드에서 사용할 수 있게 공개할지 결정한다.**
- 이때 아이템의 공개 및 비공개 여부를 접근성(privacy)이라고 한다.
- `mod` 키워드로 모듈을 정의할 수 있다.
- 모듈 안에 다른 모듈은 물론 구조체, 열거, 상수, 트레이트, 함수도 추가할 수 있다.
- src/lib.rs는 크레이트 루트로, 모듈 트리 구조에서 루트 역할을 한다.
- (2)는 (1)모듈의 모듈 트리(module tree)이다.
- 모듈 트리는 파일시스템의 디렉터리 트리와 유사하다.

<br />

## 모듈 트리의 아이템을 참조하기 위한 경로들

```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // (1) 절대경로
    crate::front_of_house::hosting::add_to_waitlist();

    // (2) 상대경로
    front_of_house::hosting::add_to_waitlist();
}

```

- `절대경로`: 크레이트 이름이나 crate 리터럴을 이용한, 크레이트 루트부터 시작하는 경로
- `상대경로`: 현재 모듈에서 시작해 self, super, 현재 모듈의 식별자를 이용하는 경로
- 두 경로 모두 하나 이상의 식별자로 구성되며, 각 식별자를 ::로 구분한다.
- (1)은 절대경로로써 파일 시스템에서 /로 경로를 시작하는 것과 마찬가지이다.
- **러스트 가이드는 코드의 정의와 호출은 독립적이므로 절대경로를 사용하기를 권장한다.**
- 위 코드는 컴파일 에러를 낸다.
  - _error[E0603]: module hosting is private_
  - **즉, 러스트 모듈에서 접근성 방식은 모든 아이템(함수, 구조체, 모듈 등)이 기본적으로 비공개다.**
  - **그러나 자식 모듈의 아이템은 부모 모듈의 아이템을 사용할 수 있다.**

<br />

#### `pub` 키워드로 경로 공개하기

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    front_of_house::hosting::add_to_waitlist();
}
```

- 모듈만 공개한다고 그 내부 아이템들도 공개되지는 않는다.
- **모듈의 pub 키워드는 부모 모듈이 하위 모듈을 참조할 수 있게만 할 뿐이다.**
- 따라서 예제처럼 add_to_waitlist 함수를 공개하고 싶다면 함수에도 키워드를 붙여야 한다.

<br />

#### `super`로 시작하는 상대경로

```rust
fn serve_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::serve_order();
    }

    fn cook_order() {}
}

```

- `super` 키워드를 이용한 상대경로는 파일시스템의 `..`문법처럼 부모 모듈부터 시작할 수 있다.
- back_of_house 모듈과 serve_order 함수는 같은 레벨에 있으므로 크레이트의 모듈 트리를 재구성할 때도 함께 이동될 것이다.
- **따라서 super를 사용하면 추후 코드를 다른 모듈로 이동해도 수정할 코드를 최소화할 수 있게 된다.**

<br />

#### struct와 enum 공개하기

```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    let mut meal = back_of_house::Breakfast::summer("Rye");

    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);

    // 컴파일 에러!
    // meal.seasonal_fruit = String::from("blueberries");
}
```

- struct는 각 필드도 공개/비공개 처리할 수 있다.
- enum은 pub를 쓰면 모든 열거값이 공개된다.

<br />

## use 키워드: 경로 자체를 스코프로 가져오기

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

// (1)
use crate::front_of_house::hosting;

// (2)
// use self::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

- `use`는 경로를 현재 범위로 가져와, 그 아이템이 마치 현재 스코프인 것처럼 호출할 수 있게 해준다.
- 파일시스템의 `심볼릭 링크(symbolic link)`를 생성하는 것과 유사하다.
- 단, (2) 상대경로의 경우 현재 범위의 이름부터 시작하는 대신 self 키워드를 사용한다.

<br />

- **Tip 1: 어떤 모듈에서 파생되었는지 알아야 하기 때문에 함수까지 use로 가져오진 말자.**
  - `use self::front_of_house::hosting::add_to_waitlist`
  - 게다가 러스트는 같은 이름의 두 아이템이 현재 스코프에 존재하는 것을 지원하지 않는다.
- **Tip 2: `as` 키워드로 같은 이름의 두 아이템을 현재 스코프로 가져올 수 있다.**
  - `ex1) use std::fmt::Result;`
  - `ex2) use std::io::Result as IoResult;`
- **Tip 3: pub use 키워드로 이름을 Re-exporting하기**
  - use 키워드로 스코프에 이름을 가져오면, 그 이름은 새로운 스코프에서 비공개가 된다.
  - 따라서 그 스코프에 작성한 코드를 외부에서 접근할 수 있게 하려면 pub 키워드를 써야 한다.
  - `pub use crate::front_of_house::hosting;`
  - 이를 통해 코드의 내부 구조는 유지하되 외부에는 다른 구조로 코드를 노출할 수 있다.
- **Tip 4: Cargo.toml 파일에 필요한 크레이트를 나열해 외부 패키지를 사용할 수 있다.**
  - 표준 라이브러리 또한 외부 패키지이나, 함께 제공되므로 Cargo.toml 파일에 추가할 필요는 없다.
  - 표준 라이브러리 크레이트의 이름인 std으로 시작하는 절대 경로로 사용한다.
  - `use std::collections:HashMap;`
- **Tip 5: 중첩 경로로 use 목록을 깔끔하게 유지할 수 있다.**
  - 예시1처럼 여러 아이템을 같은 경로로부터 가져올 수 있다.
  - `ex1) use std::{cmp::Ordering, io};`
  - 예시2처럼 중복되는 경로를 self로 가져올 수도 있다.
  - `ex2) use std::io::{self, Write}`
- **Tip 6: 글롭(`*`) 연산자로 어떤 경로의 모든 공개 아이템을 현재 스코프로 가져올 수 있다.**
  - `use std::collections::*;`

<br />

## 모듈을 다른 파일로 분리하기

```rust
// (1)
// src/lib.rs
mod front_of_house;

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

```rust
// (2)
// src/front_of_house.rs
pub mod hosting;
```

```rust
// src/front_of_house/hosting.rs
pub fn add_to_waitlist() {}
```

- 이렇게 다른 파일로 모듈을 쪼개도 모듈 트리는 같은 형태로 유지된다.
- (2)처럼 mod명에 코드블록 대신 세미콜론을 쓰면 모듈의 콘텐츠를 같은 이름의 파일에서 가져온다.
