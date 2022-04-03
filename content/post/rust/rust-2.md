---
title: "After reading Rust book capter 2"
date: "2022-04-03"
tags: ["rust"]
draft: false
og_description: "After reading Rust book capter 2"
---

## guessing game 입출력 붙이기

```rust
use std::io;

fn main() {
    println!("Guess the number!");
    println!("Please input your guess.");

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");

    println!("You guessed: {}", guess);
}
```

- io는 [prelude: rust standard library](https://doc.rust-lang.org/std/prelude/index.html)에 있다.
- rust에서 모든 변수는 불변(immutable)한 것이 기본이다.
- rust에서 변수를 가변적으로 사용하려면 변수명 앞에 `mut`를 선언한다.
- `::`는 뒤의 함수가 앞쪽에 연관되어 있음을 의미하는 문법이다.
- `String::new()`는 스트링 타입의 인스턴스를 생성하며, new는 여러 타입을 생성할 수 있는 보편적인 이름의 함수이다.
- `&`은 해당 argument가 reference임을 의미하며, 참조는 기본적으로 불변하다.
- 따라서 해당 예제에서는 **가변적이어야 하므로 &guest가 아닌 &mut guess이다.**
- read*line 메서드는 `io::Result` 타입을 반환하기도 하는데, enum으로 Ok와 Err값이 있다. expect 메서드를 통해 Result타입에 대응하고 에러인 경우 프로그램을 종료시킨다. \*에러에 대한 복구방법은 9장에서 다룸*
- println! 메서드의 `{}`는 값을 대입할 공간 역할을 하며 여러개도 가능하다.

<br />

### crate: Rust Package Registry 써보기

- Cargo.toml `[dependencies]` 하위에 [rand](https://crates.io/crates/rand)를 명시한다.
- 이때 cargo는 dependencies에 리스팅된 crate들을 다운받는데, rand가 의존하는 다른 crate들까지 가져온다.
- `Cargo.lock` 파일을 통해 의존성들에 특정 버전을 고정시킬 수 있다.
- `cargo update` 명령어를 통해 lock파일을 무시하고 의존성의 마이너 버전상 가장 최신으로 업데이트한다.

<br />

## 1 ~ 100 랜덤숫자 부여하기

```rust
use std::io;
use rand::Rng;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("The secret number is: {}", secret_number);

    println!("Please input your guess.");

    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");

    println!("You guessed: {}", guess);
}
```

- Rng는 Random number generator이다.
- `start..end`에서 end는 초과를 의미하므로, 1..=100라고 써도 같다.
- 참고로 `cargo doc --open` 명령어를 통해 패키지와 사용된 의존성에 관한 문서를 확인할 수 있다.

<br />

## 지정된 숫자와 추측한 숫자 비교하기

```rust
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    // --snip--

    println!("You guessed: {}", guess);

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Too small!"),
        Ordering::Greater => println!("Too big!"),
        Ordering::Equal => println!("You win!"),
    }
}
```

- `Ordering`은 Result와 마찬가지로 enum타입이며 Less/Greater/Equal은 비교해서 반환될 수 있는 결과이다.
- `match` 표현식은 패턴과 그 패턴이 주어지는 인자와 같을 때 실행될 코드로 구성된다.
- 지정숫자가 38, 추측숫자가 50일 때 두번째 가지인 Greater까지만 검사하고 match는 종료된다!
- 위 코드는 `mismatched types` 에러를 내며 컴파일되지 않을 것이다.
- guess 변수를 String 타입으로 선언했으나 secret_number 인자는 숫자 타입이기 때문이다.
- 아래 라인을 추가해 변수를 새로 정의할 필요없이 guess 변수를 형변환하여 재사용할 수 있다.
  ```rust
  let guess: u32 = guess.trim().parse().expect("Please type a number!");
  ```
  - `u32`는 부호 없는 정수 타입으로, 작은 범위의 양수 처리에 적합하다.
  - `trim`은 문자열 양끝 공백(ex. `\n`, `\r\n`...)을 제거한다.
  - [parse](https://doc.rust-lang.org/std/primitive.str.html#method.parse)는 문자열을 다양한 숫자 타입으로 변환한다.
  - parse 메서드는 논리적으로 숫자로 형변환할 수 있는 문자열에 대해서만 지원한다.
  - expect로 문자열을 숫자로 변환할 수 없을 때는 Err 결과를 반환해 프로그램을 종료시킨다.

<br />

## 맞히면 종료하고 잘못된 입력값 처리하기

```rust
fn main() {
    // --snip--

    let guess: u32 = match guess.trim().parse() {
        Ok(num) => num,
        Err(_) => continue,
    };

    println!("You guessed: {}", guess);

    loop {
        println!("Please input your guess.");

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
              println!("You win!");
              break;
            }
        }
    }
}
```

- 이 반복문은 main 함수의 마지막 코드이므로 반복문을 탈출시키면 프로그램은 종료된다.
- **parse 메서드는 Result타입이므로 match 표현식에서 성공/실패 결과를 처리할 수 있다.**
- Err 인자의 `밑줄(_)`은 모든 값을 표현하는 문자를 의미한다.
- 이제 숫자가 아닌 값을 입력하면 프로그램을 종료하지 않고 다시 입력할 수 있다.

<br />
<hr />

## Final Code

```rust
// main.rs

use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    loop {
        println!("Please input your guess.");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("You guessed: {}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
```
