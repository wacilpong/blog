---
title: "After reading Rust book chapter 4"
date: "2022-04-13"
tags: ["rust"]
draft: false
og_description: "Understanding Ownership"
---

## 소유권 (Ownership)

### 배경

- ownership은 rust가 메모리를 어떻게 관리하는지에 대해 제어하는 일련의 규칙이다.
- 가비지 컬렉터나 개발자가 임의로 메모리를 해제하는 방식 대신, ownership 시스템에 의해 관리된다.
- rust 같은 시스템 프로그래밍 언어에서는 값이 스택/힙 어디에 저장되는지에 따라 언어의 동작에 영향을 미친다.
  - 스택과 힙은 모두 런타임에 활용하는 메모리의 일부이다.
  - 스택은 Last In First Out 구조이며, 고정된 크기를 가져야 한다.
  - 컴파일 시점에 알 수 없거나 런타임에 동적으로 변하는 데이터는 힙 메모리에 저장한다.
  - 힙에 데이터를 넣으려면 운영체제는 일정한 공간을 찾아 사용중임을 표시하고 해당 메모리의 주소값(pointer)을 넘겨주며 이를 할당(allocating)이라고 한다.
  - 포인터 자체는 고정된 크기이므로 스택에 저장할 수 있다.
  - 실제 포인터가 가리키는 데이터는 그 포인터가 가리키는 메모리를 따라가야 한다.
- **함수를 호출할 때 (힙 메모리에 저장된 데이터에 대한 포인터를 포함한) 여러 값이 전달되며, 그 값들은 함수의 로컬변수로써 할당되어 스택에 저장되고 함수 실행이 끝나면 스택에서 제거된다.**
- **코드의 어느 부분이 힙 메모리에 저장된 데이터를 사용하는지 추적하고 힙에 저장되는 데이터의 중복을 최소화해 사용하지 않는 데이터를 힙 메모리에서 제거하면 메모리 부족 문제를 해소할 수 있다.**
- => rust ownership은 위 문제를 해결하기 위한 방법이다.

<br />

### 규칙

- rust에서 다루는 각각의 값은 owner라고 불리우는 변수를 가지고 있다.
- 특정 시점에 값의 owner는 단 하나뿐이다.
- owner가 범위를 벗어나면 그 값은 제거된다.

<br />

### 사례: String 타입

```rust
let s = "hello";
let s2 = String::from("hello");
```

- s는 문자열 리터럴로, 불변하며 코드 작성 시점에 필요한 모든 문자열값을 알 수 없다.
- s2는 String 타입으로, 힙에 할당되므로 컴파일 시점에 알 수 없는 크기의 문자열을 저장할 수 있다.
- **s2는 from 함수를 통해 문자열 리터럴을 이용해 생성시킨 String 인스턴스이다.**
- **String 타입은 변경할 수 있지만, 문자열 리터럴은 변경할 수 없는 이유는 메모리 차이이다.**

<br />

#### String 타입에서의 메모리 할당

> 해당 메모리는 반드시 런타임에 운영체제에 요청해야 하고, String 타입의 사용이 완료되면 이 메모리를 운영체제에 다시 돌려줄 방법이 필요하다.

- 첫번째 절차는 개발자가 `String::from` 함수를 호출하면 되며, 이 동작은 일반적이다.
- 두번째 절차는 **rust는 변수에 할당된 메모리는 변수를 소유한 스코프를 벗어나는 순간 자동으로 해제한다.**
  - 변수가 범위를 벗어나면 rust는 [drop](https://doc.rust-lang.org/std/ops/trait.Drop.html#tymethod.drop)이라는 이름의 특별한 함수를 호출한다.
  - drop 함수는 그 타입에 대한 메모리를 해제하며, 닫는 중괄호를 만나면 자동으로 호출된다.

<br />

#### (1) 변수-데이터가 상호작용하는 방식: 이동(move)

```rust
let x = 5;
let y = x;

println!(println!("{}", x);

let s1 = String::from("hello");
let s2 = s1;

// value used here after move
println!("{}", s1);
```

- 정수와 달리 스트링 타입은 포인터, 길이, 용량을 스택에 저장하고 힙에 저장되는 데이터를 다루기 때문에 메모리 해제(free)가 필요하다.
- rust는 `let s2 = s1;` 라인 이후에 변수 s1을 무효화시킨다.
- 따라서 s1은 스코프 범위를 벗어나도 변수를 더이상 메모리에서 해제(free)할 대상이 아니다.
- 얕은 복사가 아닌 무효화 처리이기 때문에 이동(move)했다고 표현한다.
- 이로써 위 코드에서 s2만 유효하기 때문에 두 변수가 스코프를 벗어나도 s2만 메모리를 해제한다.

<br />

#### (2) 변수-데이터가 상호작용하는 방식: 복제(clone)

```rust
let s1 = String::from("hello");
let s2 = s1.clone();

println!("s1 = {}, s2 = {}", s1, s2);
```

- 스택 데이터가 아닌 힙 메모리에 저장된 String 데이터를 깊은 복사해야 한다면 `clone`을 쓴다.
- 복사하는 메모리의 크기에 따라 무거운 작업이 될 수도 있다.
- 자세한 사항은 5장에서 다룬다.

<br />

#### (3) 스택 전용 데이터: 복사(copy)

```rust
let x = 5;
let y = x;

println!("x = {}, y = {}", x, y);
```

- 그럼 위 코드는 clone하지도 않았고 변수 y로 move하지도 않았는데 왜 동작할까?
- 정수형 같은 타입은 컴파일 시점에 이미 크기를 알 수 있어 온전히 스택에 저장된다.
- 즉, 실제 값을 복사하는 것이 성능에 부담을 주지 않는다.
- 깊은 복사와 얕은 복사 간의 차이가 없으므로 clone해도 얕은 복사와 차이가 없다.
- [copy trait](https://doc.rust-lang.org/book/appendix-03-derivable-traits.html#clone-and-copy-for-duplicating-values)라는 특성이 적용되어 있으면 그 타입의 변수는 새 변수에 할당해도 무효화되지 않는다.
  - `u32`와 같은 모든 정수형 타입
  - `bool`, true와 false만 갖는 불리언 타입
  - `f64`와 같은 부동 소수점 타입
  - `char`, 문자 타입
  - copy trait가 적용된 타입으로 이루어진 튜플, _ex. (i32, i32)_

<br />

### Ownership and Functions

```rust
fn main() {
    let s = String::from("hello");

    takes_ownership(s);

    let x = 5;

    makes_copy(x);
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
// Here, some_string goes out of scope and `drop` is called. The backing
// memory is freed.

fn makes_copy(some_integer: i32) {
    println!("{}", some_integer);
}
// Here, some_integer goes out of scope. Nothing special happens.
```

- 함수에 값을 전달하는 것은, 변수에 값을 대입하는 것과 유사하다.
- 위 코드에서 takes_ownership 메서드 호출 후 변수 s를 사용하려고 하면 컴파일 에러가 뜰 것이다.

<br />

### Return Values and Scope

```rust
fn main() {
    let s1 = gives_ownership();
    let s2 = String::from("hello");
    let s3 = takes_and_gives_back(s2);
}

fn gives_ownership() -> String {
    let some_string = String::from("yours");

    some_string
}

fn takes_and_gives_back(a_string: String) -> String {
    a_string
}
```

- 함수의 반환값 또한 ownership을 이전하고, 스코프를 벗어날 때 drop 함수에 의해 제거된다.
- 함수에 값을 전달할 때 ownership을 이전하고 싶지 않다면 어떻게 해야 할까?
- 함수에 전달했던 변수를 다시 사용하기 위해 매번 그 변수를 실제 반환값과 함께 다시 반환해야 하는 것은 번거롭다.
- 이를 위해 rust는 참조(references)를 지원한다.

<br />
<hr />

## References and Borrowing

```rust
fn main() {
    let s1 = String::from("hello");
    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
```

- 값의 ownership을 이동시키는 대신, 매개변수로 전달된 객체의 참조를 이용하도록 할 수 있다.
- **앰퍼샌드(&) 기호가 바로 참조이며, ownership을 가져오지 않고도 값을 참조할 수 있다.**
- `&s1`은 변수 s1의 값은 읽을 수 있지만 ownership은 없는 참조인 상태를 의미한다.
- 참조가 가리키는 값은 참조가 범위를 벗어나더라도 drop 함수가 호출되지 않는다.
- **즉, calculate_length함수가 끝날 때 변수 s는 자신이 가리키는 값에 ownership이 없으므로 아무 일도 일어나지 않는다.**
- 함수의 매개변수로 참조를 전달하는 것을 `borrowing`이라고 한다.
- 빌려온 매개변수, 즉 참조는 불변하므로 변경할 수 없다.

<br />

### 가변 참조 (Mutable References)

```rust
fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

```rust
let mut s = String::from("hello");
let r1 = &mut s;
let r2 = &mut s;

println!("{}, {}", r1, r2);
```

- **(1) 특정 스코프 내의 특정 데이터에 대한 가변 참조는 하나만 허용된다.**
  - 첫번째 코드처럼 가변 참조를 전달받으면 변경할 수 있다.
  - 두번째 코드는 에러를 낸다. _cannot borrow `s` as mutable more than once at a_
  - 이는 data races를 컴파일 시점에 방지하기 위함이다.

<br />

```rust
let mut s = String::from("hello");

let r1 = &s; // no problem
let r2 = &s; // no problem
let r3 = &mut s; // BIG PROBLEM

println!("{}, {}, and {}", r1, r2, r3);
```

```rust
let mut s = String::from("hello");

let r1 = &s; // no problem
let r2 = &s; // no problem
println!("{} and {}", r1, r2);
// variables r1 and r2 will not be used after this point

let r3 = &mut s; // no problem
println!("{}", r3);
```

- **(2) 불변 참조를 이미 사용중일 때도 가변 참조를 생성할 수 없다.**
  - 데이터를 읽는 동작은 아무 영향이 없으므로 불변 참조는 여러 개 생성해도 된다.
  - 첫번째 코드는 에러를 낸다. _cannot borrow `s` as mutable because it is also borrowed as immutable_
  - 두번째 코드는 r1, r2의 스코프가 끝나기 전에 참조가 더이상 사용되지 않으므로 r3는 허용되며, 이를 `Non-Lexical Lifetimes(NLL)`이라고 한다.

<br />

```rust
fn main() {
    let reference_to_nothing = dangle();
}

fn dangle() -> &String {
    let s = String::from("hello");

    &s
}
```

- **(3) 참조는 항상 유효해야 한다.**
  - rust는 죽은 참조가 일어나지 않도록 컴파일러가 보장한다.
  - 이때 죽은 참조란 이미 해제되어 다른 정보가 저장된 메모리를 계속 참조하는 포인터이다.
  - 즉, 어떤 데이터에 대한 참조를 생성하면 컴파일러가 참조하기 전에 스코프를 벗어났는지 확인해준다.
  - 따라서 위 코드는 에러를 낸다. _missing lifetime specifier_
  - **dangle 함수는 String에 대한 참조를 반환하는데, 변수 s가 반환시점에 스코프를 벗어나므로 drop 함수가 호출되고 메모리가 해제된다.** 따라서 이 함수는 에러의 위험이 있기 때문에 에러를 발생시키는 것이다.

<br />
<hr />

## Slice Type

### (1) 문자열 슬라이스

```rust
fn main() {
    let mut s = String::from("hello world");
    let word = first_word(&s);

    s.clear();
}

fn first_word_length(s: &String) -> usize {...}
fn second_word_length(s: &String) -> (usize, usize) {...}
```

- 슬라이스 또한 ownership을 갖지 않는 타입이다.
- **슬라이스를 통해 컬렉션 전체가 아닌, 컬렉션의 연속된 요소들을 참조할 수 있다.**
- first_word_length 함수의 usize타입 반환값은 String 타입과 별개이므로 나중에도 값이 유효할 것이라 보장 X
- second_word_length 함수는 단어의 시작과 끝 인덱스를 모두 추적해야 하므로 관리할 상태가 늘어난다.
- main 함수를 보면 s변수를 비워도 word변수는 여전히 5를 가지고 있다.
- **즉, word변수는 더이상 s변수와 데이터 싱크가 맞지 않아 버그를 유발할 수 있다.**
- => 이 문제를 해결하기 위해 slice를 이용할 수 있다.

<br />

```rust
let s = String::from("hello world");

let hello = &s[0..5];
let world = &s[6..11];
```

```rust
let s = String::from("hello");
let len = s.len();

// (1)
let slice = &s[0..2];
let slice = &s[..2];

// (2)
let slice = &s[3..len];
let slice = &s[3..];

// (3)
let slice = &s[0..len];
let slice = &s[..];
```

- 위 방식을 통해 String 일부에 대한 참조를 얻게 된다.
- `[시작인덱스..끝인덱스]` 형태로, world변수는 7번째 문자로부터 5개 문자를 참조한다.
- 위 (1),(2),(3)은 각각 동일하게 동작한다.

<br />

```rust
fn main() {
    let mut s = String::from("hello world");
    let word = first_word(&s);

    s.clear(); // error!

    println!("the first word is: {}", word);
}

fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

- 이제 first_word 함수는 String 타입에 대한 참조가 유효성을 컴파일러가 보장해준다.
- _cannot borrow `s` as mutable because it is also borrowed as immutable_

<br />

```rust
let s = "Hello, world!";
```

- **문자열 리터럴은 slice 타입이다.**
- 문자열 리터럴 s변수의 타입은 `&str`이며, 바이너리의 어느 한 부분을 가리키는 슬라이스라는 뜻이다.
- 따라서 문자열 리터럴은 항상 불변하다.
- &str타입의 참조 포인터는 스택에, 리터럴 값은 바이너리로 존재한다.
- **_즉, 데이터 자체는 스택/힙이 아니라 런타임에 프로그램이 할당되는 메모리 영역에 존재할 것이다!_**

<br />

```rust
// AS-IS
fn first_word(s: &String) -> &str {}

// TO-BE
fn first_word(s: &str) -> &str {}
```

- AS-IS 함수는 String 타입의 값만 넘길 수 있다.
- TO-BE 함수는 String과 &str 모두 적용할 수 있다.
- 왜냐하면 String 타입을 전달해야 한다면 전체 문자열 슬라이스를 넘기면 된다.
- 즉, **String 타입에 대한 참조대신 문자열 슬라이스를 매개변수로 사용하면 같은 기능을 유지하면서 더 보편적인 API 형태가 된다.**

<br />

### (2) 그외 타입 슬라이스

```rust
let a = [1, 2, 3, 4, 5];
let slice = &a[1..3];
```

- 위 슬라이스는 `&[i32]`타입이다.
- 슬라이스는 문자열에 특화되어 있으나, 모든 종류의 컬렉션에 활용할 수 있다.
- _컬렉션은 벡터(vectors)를 소개하는 8장에서 자세히 다룸_
