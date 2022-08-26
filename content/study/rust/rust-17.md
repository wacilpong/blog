---
title: "After reading Rust book chapter 17"
date: "2022-08-22"
tags: ["rust"]
draft: false
og_description: "Object-Oriented Programming Features of Rust"
---

## 객체지향 언어의 특징

### 1-1. 데이터와 행위를 정의하는 객체

- 객체는 데이터와 그 데이터를 운영하는 절차(메서드)를 모아둔 개념이다.
- 구조체/열거자는 impl 블록을 통해 메서드를 제공하기 때문에 러스트는 객체지향이다.

<br />

### 1-2. 캡슐화

- 객체의 상세 구현에 접근하지 못하도록 한다.
- 공개API에 의존하여 객체를 다룰 수 있다.
- 러스트에서는 `pub` 키워드를 적용할 수 있으며, 기본적으로 모든 것은 비공개이다.

<br />

```rust
pub struct AveragedCollection {
	list: Vec<i32>,
	average: f64,
}

impl AveragedCollection {
    pub fn add(&mut self, value: i32) {
        self.list.push(value);
        self.update_average();
    }

    pub fn remove(&mut self) -> Option<i32> {
        let result = self.list.pop();
        match result {
            Some(value) => {
                self.update_average();
                Some(value)
            }
            None => None,
        }
    }

    pub fn average(&self) -> f64 {
        self.average
    }

    fn update_average(&mut self) {
        let total: i32 = self.list.iter().sum();
        self.average = total as f64 / self.list.len() as f64;
    }
}
```

- `add`, `remove`, `average` 라는 공개 메서드로 아이템을 조작할 수 있다.
- `list`, `average` 필드는 비공개이므로 외부에서 필드값을 변경할 수 없다.

<br />

### 1.3. 타입 시스템으로서의 상속, 코드 공유를 위한 상속

- 객체가 다른 객체의 데이터와 행위를 물려받는 메커니즘이다.
- 러스트에는 부모 구조체의 필드와 메서드 구현을 물려받는 구조체를 정의하는 **상속**의 개념은 없다.

<br />

#### 상속을 택하는 이유?

```rust
  pub trait Summary {
      fn summarize(&self) -> String {
          String::from("(lRead more...)")
      }
  }

  pub struct NewsArticle {
      pub headline: String,
      pub location: String,
      pub author: String,
      pub content: String,
  }

  impl Summary for NewsArticle {}

  let article = NewsArticle {
      headline: String::from("Penguins win the Stanley Cup Championship!"),
      location: String::from("Pittsburgh, PA, USA"),
      author: String::from("Iceburgh"),
      content: String::from(
          "The Pittsburgh Penguins once again are the best \
           hockey team in the NHL.",
      ),
  };

  println!("New article available! {}", article.summarize());
```

- `Summary` 트레이트를 구현하는 타입이라면 `summarize` 메서드를 활용 가능하다.
  _부모 클래스에 메서드를 구현하면 상속 받는 자식 클래스에서도 메서드를 사용 가능한 것과 유사_
- `Summary` 트레이트를 구현할 때 `summarize` 메서드의 기본 구현을 재정의 가능하다.
  _부모 클래스의 메서드를 자식 클래스에서 override하는 것과 유사_

<br />

- (1) 코드의 재사용: 러스트는 트레이트를 통해 다른 방식으로 구현 가능하다.
- (2) 타입 시스템: 러스트는 제네릭과 트레이트 경계를 통해 타입들의 규칙을 정의한다.
  - 부모 타입이 필요한 곳에 자식 타입을 전달할 수 있게 하려는 **다형성** 속성
  - 상속에서는 서브클래스를 이용해 다형성을 구현한다.
  - 러스트는 제네릭을 사용하며 트레이트 경계를 이용해 타입들이 반드시 제공해야 할 규칙을 정의한다.

<br />

- 상속은 최근에 여러 언어에서 프로그래밍 디자인 해법으로서의 가치를 잃었다고 한다.
  - 필요 이상의 많은 코드를 공유해야하기 때문이다.
  - 부모 클래스의 메서드는 서브클래스를 위한 것이 아니므로 서브클래스에서 호출하는 것이 논리상 X
  - 이것이 에러를 유발하는 원인이 되기도 한다.
  - 러스트에서는 상속 대신 **트레이트 객체**를 이용하는 방법을 채택하게 되었다.

<br />
<hr />

## 다른 타입을 허용하는 트레이트 객체

### 2-1. 트레이트: 공통 행위를 정의

```rust
pub trait Draw {
    fn draw(&self);
}

// (1) 트레이트만을 활용한 객체
// : 여러 타입을 저장할 수 있다.
pub struct Screen {
    pub components: Vec<Box<dyn Draw>>,
}

impl Screen {
    pub fn run(&self) {
        for component in self.components.iter() {
            component.draw();
        }
    }
}

// (2) 제네릭과 트레이트 경계를 활용한 객체
// : 같은 종류의 타입에 대한 컬렉션을 지원한다.
// pub struct Screen<T: Draw> {
//     pub components: Vec<T>
// }

// impl<T> Screen<T>
//     where T: Draw {
//     pub fn run(&self) {
//         for component in self.components.iter() {
//             component.draw();
//         }
//     }
// }
```

- 트레이트 객체는 `&` 참조, `Box<T>` 스마트 포인터 등의 포인터를 이용해 생성해야 하고, `dyn` 키워드와 함께 트레이트를 명시해야 한다.
- 다른 언어에서는 데이터와 행위를 **객체**라는 하나의 개념으로 칭한다.
- 러스트 구조체/열거자는 필드에 저장된 데이터와 `impl` 블록에 정의하는 행위가 별개이므로 객체가 아니다.
- 트레이트 객체는 데이터와 행위가 결합하지만, 객체와 다른 점은 데이터를 추가할 수 없다.
  _트레이트 객체의 목적: 공통된 행위에 대한 추상화를 제공한다._

<br />

### 2-2. 트레이트 구현

```rust
pub trait Draw {
    fn draw(&self);
}

pub struct Screen {
    pub components: Vec<Box<dyn Draw>>
}

impl Screen {
    pub fn run(&self) {
        for component in self.components.iter() {
            component.draw();
        }
    }
}


// Button이 아닌 다른 구조체일 경우 다른 필드가 정의될 수 있다.
// 다른 타입이여도 Draw 트레이트를 구현하고 있다.
pub struct Button {
    pub width: u32,
    pub height: u32,
    pub label: String,
}

impl Draw for Button {
    fn draw(&self) {
        println!("Draw Button");
    }
}
```

```rust
use gui::Draw;

struct SelectBox {
    width: u32,
    height: u32,
    options: Vec<String>,
}

impl Draw for SelectBox {
    fn draw(&self) {
        println!("Draw SelectBox")
    }
}

use gui::{Button, Screen};

fn main() {
    let screen = Screen {
        components: vec![
            Box::new(SelectBox {
                width: 75,
                height: 10,
                options: vec![
                    String::from("Yes"),
                    String::from("Maybe"),
                    String::from("No"),
                ],
            }),
            Box::new(Button {
                width: 50,
                height: 10,
                label: String::from("OK"),
            })
        ],
    };


    // (Duck typing과 유사)
    // Screen 구조체의 run 메서드: draw 메서드만 호출하면 되기 때문에 각 컴포넌트의 실제 타입은 상관 없다.
    screen.run();
}
```

- 러스트는 어떤 값이 특정 메서드를 구현하는 지 런타임에 검사할 필요가 없다.
- 필요한 메서드를 구현하지 않았을 때 발생할 에러에 대해도 걱정할 필요가 없다.
- 어떤 값이 트레이트 객체에 필요한 트레이트를 구현하지 않으면 컴파일 단계에서 허용하지 않기 때문이다.

  ```rust
  use gui::Screen;

  fn main() {
      let screen = Screen {
          // String 타입에 Draw 트레이트에 필요한 메서드가 없기 때문에 컴파일 오류 발생!
          components: vec![Box::new(String::from("Hi"))],
      };

      screen.run();
  }
  ```

<br />

### 2-3. 동적 호출을 수행하는 트레이트 객체

- `정적 호출 (static dispatch)`
  - 컴파일러가 메서드를 사용하는 코드를 분석해 제네릭 타입 매개변수를 실제 타입으로 대체하는 코드를 생성해 정적 호출을 실행한다.
  - 컴파일러가 컴파일타임에 어떤 메서드를 호출하는지 알고 있다는 의미이다.
- `동적 호출 (dynamic dispatch)`
  - 컴파일러가 컴파일타임에 어떤 메서드를 호출하는지 판단하지 못하는 경우에 실행한다.
  - 컴파일러가 런타임에 호출할 메서드를 찾아내기 위한 코드를 추가한다.
- 트레이트 객체는 동적 호출을 사용한다.
  - 컴파일러가 트레이트 객체를 사용하는 코드에 사용되는 타입을 모두 알 수 없다.
  - 러스트는 런타임에 트레이트 객체의 포인터를 이용해 어떤 메서드를 호출할 것인지를 알아낸다.
    _런타임 비용 발생_
  - 하지만 코드의 유연성이 향상되기 때문에 케이스에 맞게 적절한 사용을 권장한다.

<br />

### 2-4. 객체 안전성을 요구하는 트레이트 객체

- 러스트는 트레이트를 구현하는 실제 타입을 알 수 없으므로 객체 안전성이 보장되어야 한다.
- 트레이트 객체는 **객체 안전성**을 가진 트레이트만 사용할 수 있다.
- 트레이트의 모든 메서드가 다음의 조건을 충족하면 안전하다.
  - **(1) 메서드의 반환 타입이 Self가 아니다.**
  - **(2) 메서드에 제네릭 타입 매개변수가 없다.**

<br />
<hr />

## 객체지향 디자인 패턴 구현

#### **상태 패턴 (state pattern)**

- 객체지향 디자인 패턴
- 객체가 특정 상태에 따라 행위를 달리하는 상황에서 자신이 직접 상태를 체크하여 상태에 따라 행위를 호출하지 않고, 상태를 객체화 하여 상태가 행동을 할 수 있도록 위임하는 패턴을 말한다.

  <br />

### 3-1~5. Blog, Post 상태 패턴 구현해보기

```rust
// lib.rs
pub struct Post {
    state: Option<Box<dyn State>>,
    content: String,
}

impl Post {
    pub fn new() -> Post {
        Post {
            state: Some(Box::new(Draft {})),
            content: String::new(),
        }
    }

    pub fn add_text(&mut self, text: &str) {
        self.content.push_str(text);
    }

    pub fn content(&self) -> &str {
        // self.state의 소유권은 필요하지 않으므로
        // state의 참조를 얻기 위해 as_ref()를 호출한다.
        self.state.as_ref().unwrap().content(&self)
    }

    pub fn request_review(&mut self) {
        // 구조체의 필드에 값을 대입하지 않는 것을 허용하지 않기 때문에
        // Some 값일 때에만 그 값의 소유권을 가져온다.
        if let Some(s) = self.state.take() {
            self.state = Some(s.request_review())
        }
    }

    pub fn approve(&mut self) {
        if let Some(s) = self.state.take() {
            self.state = Some(s.approve())
        }
    }
}

trait State {
    // self를 Box<Self> 타입으로 둔 이유
    // : Box<Self> 타입의 소유권을 가져와 상태를 새로운 상태로 변경하기 위해
    fn request_review(self: Box<Self>) -> Box<dyn State>;
    fn approve(self: Box<Self>) -> Box<dyn State>;
    fn content<'a>(&self, post: &'a Post) -> &'a str {
        ""
    }
}

struct Draft {}

impl State for Draft {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        // 리뷰를 기다리는 상태로 변경된다.
        Box::new(PendingReview {})
    }

    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }
}

struct PendingReview {}

impl State for PendingReview {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        // 이미 리뷰를 기다리는 상태이기 때문에 self를 반환한다.
        // Post 구조체의 request_review 메서드는 현재 상태값이 어떻든 같은 코드를 동작하고,
        // 상태 변환에 대한 것은 각 상태에 위임한다.
        self
    }

      fn approve(self: Box<Self>) -> Box<dyn State> {
        Box::new(Published {})
    }
}

struct Published {}

impl State for Published {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        self
    }

    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }

    // 왜 수명 어노테이션이 필요할까?
    // post의 참조를 인수로 전달받고, post의 일부를 참조로 반환해야 하므로
    // 반환하는 참조의 수명은 인수로 전달받은 수명과 관련이 있다.
    fn content<'a>(&self, post: &'a Post) -> &'a str {
        &post.content
    }
}
```

```rust
// main.rs
use blog::Post;

fn main() {
    let mut post = Post::new();

    post.add_text("나는 오늘 점심으로 샐러드를 먹었다.");
    assert_eq!("", post.content());

    post.request_review();
    assert_eq!("", post.content());

    post.approve();
    assert_eq!("나는 오늘 점심으로 샐러드를 먹었다.", post.content());
}
```

<br />

### 3-6. 상태 패턴의 트레이드 오프

- 상태 패턴의 장/단점
  - (장) 상태 패턴을 사용하면 상태를 확인하고 개별 동작을 구현할 필요가 없다.
  - (장) **새로운 구현을 추가해 확장하기가 수월하다는 장점이 있다.**
  - (단) 상태 객체가 상태 간의 전환을 구현하기 때문에 일부 상태가 다른 상태와 연결될 수 있다.
  - (단) 로직이 중복된다.

<br />

- 상태와 행위를 타입으로 정의하기

  ```rust
  // lib.rs
  pub struct Post {
      content: String,
  }

  pub struct DraftPost {
      content: String,
  }

  impl Post {
      pub fn new() -> DraftPost {
          DraftPost {
              content: String::new(),
          }
      }

      pub fn content(&self) -> &str {
          &self.content
      }
  }

  impl DraftPost {
      pub fn add_text(&mut self, text: &str) {
          self.content.push_str(text);
      }
  }
  ```

  - DraftPost 구조체에서는 content 메서드를 제공하지 않는다.
  - 따라서 초고 상태의 포스트는 content를 출력하지 못한다는 사실을 보장할 수 있다.
    _위반 시 컴파일 에러 발생_

<br />

- 다른 타입으로 전환을 이용해 상태 전환 구현하기

  ```rust
  pub struct Post {
      content: String,
  }

  pub struct DraftPost {
      content: String,
  }

  impl Post {
      pub fn new() -> DraftPost {
          DraftPost {
              content: String::new(),
          }
      }

      pub fn content(&self) -> &str {
          &self.content
      }
  }

  impl DraftPost {
      pub fn add_text(&mut self, text: &str) {
          self.content.push_str(text);
      }

      pub fn request_review(self) -> PendingReviewPost {
          PendingReviewPost {
              content: self.content,
          }
      }
  }

  pub struct PendingReviewPost {
      content: String,
  }

  impl PendingReviewPost {
      pub fn approve(self) -> Post {
          Post {
              content: self.content,
          }
      }
  		// content 메서드가 없기 때문에 DraftPost 구조체와 마찬가지로
  		// content를 출력할 수 없다.
  		// approve 메서드를 통해 Post 구조체로 전환하여 content를 출력하는 방법 뿐이다.
  }
  ```

  ```rust
  // main.rs
  use blog::Post;

  fn main() {
    // DraftPost
    let mut post = Post::new();

    post.add_text("I ate a salad for lunch today");

    // DraftPost -> PendingReviewPost
    let post = post.request_review();

    // PendingReviewPost -> Post
    let post = post.approve();

  	// content에 접근 불가한 구조체인 경우 컴파일 에러가 발생하기 때문에
  	// 중간 중간 assert_eq를 통해 검사할 필요가 없어졌다.
    assert_eq!("I ate a salad for lunch today", post.content());
  }
  ```

  - 섀도우 인스턴스를 사용하여 post를 다른 타입으로 계속 전환하게 된다.
    _더 이상 객체지향 상태 패턴을 따르지 않게 된다._
  - 해당 패턴의 장점
    - 유효하지 않은 상태로의 전환이 불가능하다.
    - 컴파일 타임에 에러가 발생하여 버그를 사전 방지할 수 있다.
