---
title: "After reading Rust book chapter 18"
date: "2022-08-26"
tags: ["rust"]
draft: false
og_description: "Patterns and Matching"
---

## All the Places Patterns Can Be Used

### 1-1. match Arms

```rust
match VALUE {
    PATTERN => EXPRESSION,
    PATTERN => EXPRESSION,
    PATTERN => EXPRESSION,
}
```

```rust
match x {
    None => None,
    Some(i) => Some(i + 1),
}
```

- match 표현식에 사용된 값에 대한 모든 가능성을 반드시 처리해야 한다.
- 마지막 가지에는 나머지 모든 경우를 처리한다.
- `_` 패턴은 모든 값과 일치하는 패턴이나, 변수에 바인딩되지 않으므로 마지막 가지에 쓴다.

<br />

### 1-2. Conditional `if let` Expressions

```rust
fn main() {
    let favorite_color: Option<&str> = None;
    let is_tuesday = false;
    let age: Result<u8, _> = "34".parse();

    if let Some(color) = favorite_color {
        println!("Using your favorite color, {color}, as the background");
    } else if is_tuesday {
        println!("Tuesday is green day!");
    } else if let Ok(age) = age {
        if age > 30 {
            println!("Using purple as the background color");
        } else {
            println!("Using orange as the background color");
        }
    } else {
        println!("Using blue as the background color");
    }
}
```

- favorite_color가 None이 아닐 때까지 `if문` 로직을 수행한다.
  - None이면 is_tuesday가 true이면 `else-if문` 로직을 수행한다.
  - false이면 파싱된 age값이 Err가 아닐 때까지 `else-if-let` 로직을 수행한다.
  - 모든 예외 경우에 `else문` 로직을 수행한다.

<br />

### 1-3. Conditional `while let` Loops

```rust
let mut stack = Vec::new();

stack.push(1);
stack.push(2);
stack.push(3);

while let Some(top) = stack.pop() {
    println!("{}", top);
}
```

- stack의 값이 None이 아닐 때까지 반복문 로직을 수행한다.
- 만약 stack이 비면 None을 반환하게 된다.

<br />

#### for loops

```rust
let v = vec!['a', 'b', 'c'];

for (index, value) in v.iter().enumerate() {
    println!("{} is at index {}", value, index);
}
```

- for문 바로 뒤에 오는 키워드는 패턴이어서 튜플로 구조화할 수 있다.
- 이때 index, value는 `enumerate`메서드가 반환하는 인덱스와 값으로 매칭된다.

<br />

### 1-4. `let` Statements

```rust
// (1) 성공
let (x, y, z) = (1, 2, 3);

// (2) 에러
let (x, y) = (1, 2, 3);
```

- (2)는 아래처럼 에러를 낸다.
  _this expression has type `({integer}, {integer}, {integer})`_
- 이를 수정하려면 `_`, `..`처럼 패턴에서 무시할 수 있는 값을 쓰면 된다.

<br />

### 1-5. Function Parameters

```rust
fn foo(x: i32) {
    // code goes here
}
```

```rust
fn print_coordinates(&(x, y): &(i32, i32)) {
    println!("Current location: ({}, {})", x, y);
}

fn main() {
    let point = (3, 5);
    print_coordinates(&point);
}
```

- 함수 괄호에 오는 x 인자 부분이 바로 패턴이다.

<br />
<hr />

## Refutability: 패턴 매칭에 실패할까, 아닐까?

```rust
fn main() {
    let some_option_value: Option<i32> = None;

    // (1)
    let Some(x) = some_option_value;

    // (2)
    if let Some(x) = some_option_value {
        println!("{}", x);
    }

    // (3)
    if let x = 5 {
        println!("{}", x);
    };
}
```

- (1)은 let Some(x)가 None인 경우 커버하지 못하므로 컴파일되지 않는다.
  _refutable pattern in local binding: `None` not covered_
- (2)애서 실패 가능한 경우를 커버했으므로 컴파일된다.
- (3)처럼 항상 실패하지 않는 패턴도 러스트 입장에선 논리적으로 맞지 않아 컴파일되지 않는다.
  _irrefutable `if let` pattern_

<br />
<hr />

## Pattern Syntax

### 3-1. 리터럴과 매칭하기

```rust
let x = 1;

// 패턴은 리터럴에 직접 비교할 수 있다.
match **x** {
    1 => println!("하나"),
    2 => println!("둘"),
    3 => println!("셋"),
    _ => println!("나머지"),
```

<br />

### 3-2. 명명된 변수와 매칭하기

- 명명된 변수는 모든 값과 일치하는 패턴이므로 match 표현식에서 사용하는 것은 복잡하다.
- match 표현식은 새 스코프를 생성하므로 패턴으로 선언한 변수는 표현식 바깥에 선언된 같은 이름의 변수를 shadowing한다.

<br />

#### 출력 결과 예측하기?

```rust
fn main() {
    let x = Some(5);
    let y = 10;

    match x {
        Some(50) => println!("50"),

        // 변수 y는 앞서 10을 대입한 변수 y가 아니라 새로운 변수
        // y는 Some 값에 저장된 모든 값과 일치
        // y에 Some 값 안에 저장된 변수 x의 값이 바인딩된다.
        Some(y) => println!("일치, y = {:?}", y),
        _ => println!("일치하지 않음, x = {:?}", x),
    }

    println!("결과: x = {:?}, y = {:?}", x, y);
    // 출력결과: 일치, y = 5
    // 결과: x = Some(5), y = 10
}
```

- shadow 변수를 생성하지 않고 외부의 변수 x와 y의 값을 비교하기 위한 match 표현식을 생성하려면 매치 가드(match guard)를 대신 사용하면 된다.

<br />

### 3-3. 다중 패턴

```rust
let x = 1;

match x {
    1 | 2 => println!("1 또는 2"),
    3 => println!("3"),
    _ => println!("그 외 나머지 값"),
}
```

- match 표현식에는 or의 의미가 있는 | 문법을 이용해 여러개의 패턴을 비교할 수 있다.

<br />

### 3-4. `..=` 문법으로 범위 값과 매칭하기

```rust
fn main() {
    let x = 5;

    match x {
        1..=5 => println!("one through five"),
        _ => println!("something else"),
    }
}
```

```rust
fn main() {
    let x = 'c';

    match x {
        'a'..='j' => println!("early ASCII letter"),
        'k'..='z' => println!("late ASCII letter"),
        _ => println!("something else"),
    }
}
```

- 가장자리의 값을 포함하는 값의 범위와 비교하며, 1부터 1000처럼 큰 범위일 때 유용하다.
- 범위는 숫자나 char 값만 사용할 수 있다.
- 컴파일 타임에 범위가 비어있지 않은지 검사해야 하기 때문이다.
- 범위가 비어있는지 러스트가 판단할 수 있는 타입은 char 타입과 숫자 뿐이다.

<br />

### 3-5. 값을 분리하여 Destructuring

- 패턴은 구조체, 열거자, 튜플, 그리고 참조 destructuring 용도로 사용할 수 있다.

<br />

#### 구조체의 해체

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point {x: 0, y: 7 };

    // 변수 p에 저장된 구조체의 x와 y필드값에 일치하는 변수 a와 b를 생성한다.
    let Point {x: **a**, y: **b** } = p;
    assert_eq!(0, a);
    assert_eq!(7, b);
}
```

- 패턴에 사용하는 변수 이름은 구조체의 필드 이름과 반드시 일치할 필요는 없다.
- 하지만 쉽게 기억하기 위해 필드이름과 같은 이름의 변수를 사용하는 것이 일반적이다.

<br />

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point {x: 0, y: 7 };

    // let Point { x: x, y: y } = p; 대신
    let Point { **x, y** } = p;
    assert_eq!(0, a);
    assert_eq!(7, b);
}
```

- 모든 필드를 위한 변수를 생성하지 않고 구조체 패턴에 리터럴 값을 이용해서 해체할 수 있다.

<br />

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 0, y: 7 }:

    match p {
        // y 필드값이 0 이면서 x 필드값은 어떤 값이든 일치하는 경우, 변수 x를 생성
        Point { x, y: 0 } => println!("x 축 {}에 위치하는 점", x),
        // x 필드값이 0 이면서 y 필드값은 어떤 값이든 일치하는 경우, 변수 y를 생성
        Point { x: 0, y } => println!("y 축 {}에 위치하는 점", y),
        // 위의 두 경우 제외한 모든 경우, 변수 x, y 모두 생성
        Point { x, y } => println!("좌표 ({}, {})에 위치하는 점", x, y),
    }
}
```

<br />

#### 열거자의 해체

```rust
// p.123
enum Message {
    Quit, // 연관 데이터를 전혀 갖지 않는다.
    Move { x: i32, y: i32 }, // 익명 구조체를 포함
    Write(String), // 하나의 String값을 포함
    ChangeColor(Color), // 세 개의 i32값을 포함
}

fn main() {
    let msg = Message::ChangeColor(0, 160, 255);

    match msg {
        Message::Quit => {
            // 데이터가 없는 열것값은 어떤 값도 해체할 수 없다. Message::Quit 리터럴 값에만 일치하므로 패턴에 변수도 포함하지 않는다.
            println!("Quit: 해체할 값이 없습니다.")
        },
        Message::Move { x, y } => {
            // 구조체와 유사한 형태의 열것값은 구조체를 사용할 때와 유사한 패턴을 사용할 수 있다.
            println!(
                "Move: x = {}, y = {}",
                x,
                y
            );
        },
        Message::Write(text) => println!("Write: {}", text),
        Message::ChangeColor(r, g, b) => {
            println!(
                "ChangeColor: R = {}, G = {}, B = {}",
                r,
                g,
                b
            )
        },
    }
}
```

- 열거자를 해체하기 위한 패턴은 열거자에 데이터를 저장하는 방법을 정의한 것과 같아야 한다.

<br />

#### 중첩된 구조체와 열거자의 해체

```rust
// ChangeColor 메시지가 RGB와 HSV 색상을 지원한다면
enum Color {
    Rgb(i32, i32, i32),
    Hsv(i32, i32, i32),
}

enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(**Color**),
}

fn main() {
    let msg = Message::ChangeColor(Color::Hsv(0, 160, 255));

    match msg {
        Message::ChangeColor(Color::Rgb(r, g, b)) => {
            println!(
                "ChangeColor: R = {}, G = {}, B = {}",
                r,
                g,
                b
            );
        },
        Message::ChangeColor(Color::Hsv(h, s, v)) => {
            println!(
                "ChangeColor: H = {}, S = {}, V = {}",
                h,
                s,
                v
            )
        },
        _ => {}
    },
}
```

<br />

#### 구조체와 튜플의 해체

```rust
let ((feet, inches), Point {x, y}) = ((3, 10), Point { x: 3, y: -10 });
```

- 헤체패턴은 더 복잡한 방법으로 섞거나 중첩할 수 있다.

<br />

### 3-6. 패턴의 값 무시하기

- 패턴의 값 전체를 무시할 수도 있고, 일부만 무시할 수도 있다.

<br />

#### `_` 패턴으로 값 전체 무시하기

```rust
fn foo(_: i32, y: i32) {
    println!("이 함수는 y 매개변수만 사용한다: {}", y);
}

fn main() {
    foo(3, 4);
}
```

- match 표현식의 마지막 가지로도 사용할 수 있지만, 어떤 패턴에서도 사용할 수 있다.
- ex. 어떤 트레이트의 시그너처를 구현하는데 함수의 본문에서 해당 매개변수가 필요치 않을 때

<br />

#### `_`를 중첩해서 값의 일부만 무시하기

```rust
let mut setting_value = Some(5);
let new_setting_value = Some(10);

match (setting_value, new_setting_value) {
    // 두 Some값에 저장된 실제 값은 사용하지 않지만, 모두 Some 값을 가지고 있는지만 검사한다.
    (Some(_), Some(_)) => {
        println!("이미 설정된 값을 덮어쓸 수 없습니다.");
    }
    // 그 외의 경우: 둘 중 하나가 None
    _ => {
        setting_value = new_setting_value;
    }
}

println!("현재 설정: {:?}", setting_value);
```

```rust
// 한 패턴에서 여러 번 사용해서 특정 값을 무시
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (first, _, third, _, fifth) => {
        println!("일치하는 숫자: {}, {}, {}", first, third, fifth)
    },
}
```

<br />

#### 변수 이름을 `_`로 시작해 사용하지 않는 변수 무시하기

```rust
fn main() {
    let _x = 5;
    let y = 10; // y에 대해서만 경고가 출력된다.
}
```

- 러스트는 일단 선언한 변수를 사용하지 않으면 버그의 원인이 될 수 있으므로 경고를 출력한다.
- 필요 시 사용하지 않는 변수에 대해 러스트가 경고를 출력하지 않도록 하려면 변수명을 밑줄로 시작한다.
- 변수 이름으로 `_`만 사용하는 것과 밑줄로 시작하는 변수명을 사용하는 것은 차이가 있다.
- `_x`는 변수에 값을 바인딩하지만, `_`는 바인딩하지 않는다.

<br />

```rust
let s = Some(String::from(""));

if let Some(_s) = s { // 변수 s의 값이 _s로 이동하게 되어서
    println!("문자열을 찾았습니다.");
}

println!("{:?}", s); // 변수 s를 더는 사용할 수 없다.
```

```rust
let s = Some(String::from(""));

if let Some(_) = s { // 바인딩 되지 않음
    println!("문자열을 찾았습니다.");
}

println!("{:?}", s); // 변수 s 사용 가능
```

<br />

#### `..`를 이용해 값의 나머지를 무시하기

```rust
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

let origin = Point { x: 0, y: 0, z: 0 };

match origin {
    Point { x, .. } => println!("x = {}", x),
}
```

```rust
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (first, .., last) => {
        println!("first = {}, last = {}", first, last);
    },
}
```

```rust
let numbers = (2, 4, 8, 16, 32);

match numbers {
    (.., second, ..) => {
        println!("second = {}", second);
    },
}
// error
```

- 여러 부분으로 구성된 값에 대해서는 `..` 문법으로 값의 일부만 검사하고 나머지는 무시할 수 있다.
- 값을 무시하기 위해 밑줄을 나열할 필요가 없다.
- 러스트 관점에서 second 변수에 일치하는 값을 찾기 전/후 몇 개의 값을 무시해야 하는지 모른다.

<br />

### 3-7. 매치 가드를 이용한 추가 조건

```rust
let num = Some(4);

match num {
    // 패턴만으로는 if x < 5를 표현할 수 없으므로 매치가드는 로직의 표현력을 한층 더 높여준다
    Some(x) **if x < 5** => println!("5보다 작은 값: {}", x),
    Some(x) => println!("{}", x),
    None => (),
}
```

- 매치 가드는 match 표현식의 가지에 일치해야 할 패턴 외에도 추가적인 if 조건을 지정해서 그 조건이 일치할 때만 해당 가지의 코드를 실행한다.
- 패턴이 변수를 가리는 문제를 매치 가드를 이용해 해결할 수 있다.

<br />

```rust
fn main() {
    let x = Some(5);
    let y = 10;

    match x {
        Some(50) => println!("50"),
        // 새 변수 n을 생성해서 y(10)를 가리지 않고 값을 비교할 수 있다.
        // 매치가드 n == y는 패턴이 아니며 그래서 새로운 변수를 생성하지 않는다.
        Some(**n**) **if n == y** => println!("일치, y = {:?}", y),
        _ => println!("일치하지 않음, x = {:?}", x),
    }

    println!("결과: x = {:?}, y = {:?}", x, y);
}
```

- 매치가드에는 or 연산자 |를 이용해서 여러 패턴을 지정할 수 있다.

<br />

```rust
let x = 4;
let y = false;

match x {
    **4 | 5 | 6** if y => println!("예"),
    _ => println!("아니오"),
}
```

- (4 | 5 | 6) if y …로 동작하고 4 | 5 | (6 if y)… 처럼 동작하지 않는다.

<br />

### 3-8. `@` 바인딩

```rust
enum Message {
    Helllo { id: i32 },
}

let msg = Message::Hello { id: 5 };

match msg {
    Message::Hello { id: id_variable @ 3...7 } => {
        // 값이 범위 패턴과 일치하는지 확인하는 동시에
        // 일치하는 값을 변수에 바인딩한다.
        println!("id를 범위에서 찾았습니다: {}", id_variable)
    },
    Message::Hello { id: 10...12 } => {
        // 패턴에 명시된 범위에 속하는지만 검사하며
        // id 필드의 실제 값을 가진 변수를 선언하지 않는다.
        println!("id를 다른 범위에서 찾았습니다.")
    },
    Message::Hello { id } => {
        // (구조체 필드를 간략하게 표기하는 문법을 사용해서)
        // 변수를 범위없이 선언했으므로 id라는 이름의 변수로 그 값을 사용할 수 있고,
        // id 필드값을 비교하지 않으며 어떤 값이든 이 패턴과 일치하게 된다.
        println!("다른 id {}를 찾았습니다.", id)
    },
```

- @(앳) 연산자는 어떤 값이 패턴과 일치하는지를 비교하는 동시에 그 값을 가진 변수를 생성한다.
