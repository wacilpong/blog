---
title: "After reading Rust book chapter 14"
date: "2022-07-17"
tags: ["rust"]
draft: false
og_description: "More About Cargo and Crates.io"
---

## 릴리즈 프로필을 이용한 빌드 커스터마이징

```rust
// Cargo.toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

- `cargo build`: dev 프로필을 사용하고, `--release`를 붙이면 release 프로필을 쓴다.
- `opt-level`: 러스트가 코드에 적용할 최적화 수준을 지정, 0 ~ 3까지이며 기본값은 0이다.

<br />
<hr />

## crates.io 사이트에 크레이트 발행하기

- [crates.io](https://crates.io)의 크레이트 레지스트리는 오픈소스로 작성된 코드를 주로 호스팅한다.

<br />

### 유용한 문서 주석 작성하기

````rust
/// Adds one to the number given.
///
/// # Examples
///
/// ```
/// let arg = 5;
/// let answer = my_crate::add_one(arg);
///
/// assert_eq!(6, answer);
/// ```
pub fn add_one(x: i32) -> i32 {
    x + 1
}
````

- `문서 주석(documentation comment)`은 슬래시 3개로 시작한다.
- `cargo doc` 명령
  - 주석으로 HTML 문서를 생성할 수 있다.
  - 러스트와 함께 발행되는 rustdoc으로 target/doc에 HTML 문서를 생성한다.
  - `--open` 옵션을 함께 실행하면 생성한 HTML 문서를 브라우저를 통해 보여준다.

<br />

#### (1) 문서 주석에 사용하는 섹션

- Panics
  - 함수가 패닉을 발생시키는 경우를 설명한다.
  - 함수의 호출자가 프로그램이 패닉을 발생하는 것을 원치 않을 때는 이 함수를 호출하지 않도록 주의한다.
- Errors
  - 함수가 Result 타입을 반환하면 어떤 종류의 에러를 발생할 수 있는지, 어떤 조건인지 명시한다.
  - 이를 통해 호출자가 발생 가능한 에러를 적절히 처리하는 데 도움이 된다.
- Safety
  - 함수 호출이 안전하지 않다면 왜인지, 호출할 때 주의할 내용은 뭔지 언급한다.

<br />

#### (2) 문서 주석을 테스트에 활용하기

```sh
cargo test
Doc-tests my_crate

running 1 test
test src/lib.rs - add_one (line 5) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.27s
```

- 코드는 수정되었는데 문서가 최신화되지 않으면 나쁘다.
- `cargo test` 명령을 통해 문서의 예제 코드도 테스트로 실행한다.
- 따라서 `assert_eq!` 매크로가 패닉을 반환하도록 함수나 예제를 수정하면 실제 코드와 예제가 일치하지 않음을 알 수 있다.

<br />

#### (3) 아이템을 보유한 루트를 위한 주석

````rust
//! # My Crate
//!
//! `my_crate` is a collection of utilities to make performing certain
//! calculations more convenient.

/// Adds one to the number given.
// --snip--
///
/// # Examples
///
/// ```
/// let arg = 5;
/// let answer = my_crate::add_one(arg);
///
/// assert_eq!(6, answer);
/// ```
pub fn add_one(x: i32) -> i32 {
    x + 1
}
````

- `//!`는 주석을 추가하는 것이 아니라, 주석을 갖고 있는 아이템을 문서에 추가한다.
- 따라서 크레이트나 모듈 전체를 문서화하기 위해 모듈 안에 작성한다.

<br />

### pub use 키워드를 이용해 공개 API 발행하기

```rust
//! # Art
//!
//! A library for modeling artistic concepts.

// (3)
pub use self::kinds::PrimaryColor;
pub use self::kinds::SecondaryColor;
pub use self::utils::mix;

pub mod kinds {
    /// The primary colors according to the RYB color model.
    pub enum PrimaryColor {
        Red,
        Yellow,
        Blue,
    }

    /// The secondary colors according to the RYB color model.
    pub enum SecondaryColor {
        Orange,
        Green,
        Purple,
    }
}

pub mod utils {
    use crate::kinds::*;

    /// Combines two primary colors in equal amounts to create
    /// a secondary color.
    pub fn mix(c1: PrimaryColor, c2: PrimaryColor) -> SecondaryColor {
        // --snip--
        unimplemented!();
    }
}
```

- pub use 키워드를 쓰면 내부 구조와는 다른 공개용 구조로 아이템을 다시 노출할 수 있다.
- 다시 노출하면 공개 아이템을 원래 정의한 위치가 아닌 다른 위치에 노출한다.

<br />

```rust
// (1)
use art::kinds::PrimaryColor;
use art::utils::mix;

fn main() {
    let red = PrimaryColor::Red;
    let yellow = PrimaryColor::Yellow;
    mix(red, yellow);
}

// (2)
use art::mix;
use art::PrimaryColor;

fn main() {
    // --snip--
}
```

- art 라이브러리를 사용하는 사람 관점에서 PrimaryColorsms kinds 모듈에, mix 함수는 utils 모듈에 정의되어 있다.
- art의 내부 구조는 사용하는 사람에게는 그다지 유용한 정보가 아니다.
- 따라서 (3)처럼 `pub use` 구문을 통해 아이템들을 최상위 수준으로 다시 노출시킨다.
- 그러면 (1)대신 (2)처럼 가져올 수 있고, 중첩된 모듈이 많을 때 유용하다.

<br />

### crate.io 계정 생성하기

- [crates.io](https://crates.io) 로그인 후, API 토큰을 생성한다.
- `cargo login {token}`을 실행하면 토큰을 ~/.cargo/credentials에 저장한다.

<br />

### 새 크레이트에 메타데이터 추가하기

```txt
[package]
name = "guessing_game"
version = "0.1.0"
edition = "2021"
description = "A fun game where you guess what number the computer has chosen."
license = "MIT OR Apache-2.0"
```

- 위 메타데이터 정도는 필수적으로 입력해야 하며, 이외에는 [cargo](https://doc.rust-lang.org/cargo/) 문서를 보자.
- `cargo publish`를 통해 크레이트를 발생할 수 있다.
- 크레이트 발행은 https://crates.io 사이트에 특정 버전 크레이트를 업로드하는 과정이다.

<br />

### 등록한 크레이트의 새 버전 발행하기

- 새 버전의 릴리즈를 준비할 때는 Cargo.toml의 버전값을 수정한다.
- 시맨틱 버저닝(Semantic Versioning) 규칙을 이용해 적절하게 버전을 지정하자.

<br />

### cargo yank: crates.io에서 버전 제거하기

- 이전 버전의 크레이트를 삭제할 수는 없다.
- 다른 프로젝트들이 앞으로 이전 버전을 새로 의존 목록에 추가하는 것을 막을 수는 있다.
- cargo는 특정 버전의 크레이트에 대한 지원을 중단(yank)하는 기능을 제공한다.
- Cargo.lock 파일이 생성된 모든 프로젝트는 문제없이 동작하되, 중단된 버전을 사용하지 못하도록 한다.
- `cargo yank --vers 1.0.1`
- `cargo yank --vers 1.0.1 --undo`
- 중단해도 코드는 남아있다.
- 즉, 중단은 실수로 중요한 보안 정보를 업로드했을 때 삭제하는 용도로 지원하는 것은 아니다.

<br />
<hr />

## Cargo Workspaces

- 어느 시점이 되면 패키지를 여러 라이브러리 크레이트로 나누어야 할 시기가 온다.
- 이때 cargo는 여러 패키지를 관리할 수 있는 워크스페이스 기능을 제공한다.

<br />

### 워크스페이스 생성하기

```txt
[workspace]

members = [
    "adder",
]

```

```sh
$ cargo new adder
     Created binary (application) `adder` package

```

```txt
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

- 워크스페이스는 최상위에 하나의 target 디렉터리를 가지고, 여기에 모든 빌드물이 모인다.
- 따라서 adder 크레이트는 독립적인 target 디렉터리를 가지지는 않는다.
- 만약 각 크레이트가 독립적인 target을 가진다면, 각 크레이트를 빌드할 때마다 의존하는 다른 크레이트들도 다시 컴파일되기 때문에 하나의 target만 공유하는 것이다.

<br />

### 워크스페이스에 두 번째 크레이트 생성하기

```txt
[workspace]

members = [
    "adder",
    "add_one",
]
```

```sh
$ cargo new add_one --lib
     Created library `add_one` package
```

```txt
├── Cargo.lock
├── Cargo.toml
├── add_one
│   ├── Cargo.toml
│   └── src
│       └── lib.rs
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

- 워크스페이스에 라이브러리 크레이트를 생성했다.
- 이제 바이너리 크레이트 adder에 라이브러리 크레이트 add_one에 대한 의존성을 추가할 수 있다.

<br />

```yaml
# adder/Cargo.toml
[dependencies]
add_one = { path = "../add_one" }
```

```rust
// adder/src/main.rs
use add_one;

fn main() {
    let num = 10;
    println!(
        "Hello, world! {} plus one is {}!",
        num,
        add_one::add_one(num)
    );
}
```

- 이제 최상위 add 디렉터리에서 `cargo build` 명령으로 빌드할 수 있다.
- `cargo run -p adder`를 통해 워크스페이스에서 실행할 패키지 이름을 지정할 수 있다.

<br />

#### (1) 워크스페이스에 외부 크레이트 의존성 추가하기

- 워크스페이스는 최상위에 _Cargo.lock_ 파일을 갖기 때문에, 모든 의존성에 대해 같은 버전을 적용할 수 있다.
- 따라서 _adder/Cargo.toml_, *add_one/Cargo.toml*에 각각 rand 크레이트를 추가하면 cargo는 하나의 rand만 *Cargo.lock*에 추가한다.
- rand 크레이트를 추가하여 `add_one` 크레이트에서 rand를 사용해보자.

<br />

```yaml
# add_one/Cargo.toml
[dependencies]
rand = "0.8.3"
```

- _add_one/src/lib.rs_ 파일에 `use rand;`를 추가하고 프로젝트 루트에서 `cargo build`를 실행하면
- `rand` 크레이트를 가져와 컴파일하지만, 스코프에 포함된 `rand`를 참조하지 않았으므로 경고가 표시된다.

<br />

```sh
$ cargo build
    Updating crates.io index
  Downloaded rand v0.8.3
   --snip--
   Compiling rand v0.8.3
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
warning: unused import: `rand`
 --> add_one/src/lib.rs:1:5
  |
1 | use rand;
  |     ^^^^
  |
  = note: `#[warn(unused_imports)]` on by default

warning: 1 warning emitted

   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished dev [unoptimized + debuginfo] target(s) in 10.18s
```

- 최상위 *Cargo.lock*엔 `add_one`의 rand 의존성 정보가 포함되었다.
- 하지만 rand가 워크스페이스 어딘가에서 사용되더라도, 다른 크레이트에서 _Cargo.toml_ 파일에 rand를 추가하지 않으면 사용할 수 없다.
- 예를 들어 `adder` 크레이트의 *adder/src/main.rs*에 `use rand;`를 추가하면 에러가 발생한다.

<br />

```sh
$ cargo build
  --snip--
   Compiling adder v0.1.0 (file:///projects/add/adder)
error[E0432]: unresolved import `rand`
 --> adder/src/main.rs:2:5
  |
2 | use rand;
  |     ^^^^ no external crate `rand`
```

- 위 에러를 해결하려면 `adder` 패키지의 *Cargo.toml*에 rand에 대한 의존성을 추가해야 한다.
- `adder` 패키지를 빌드하면 *Cargo.lock*의 `adder`에 대한 의존성 목록에 rand가 추가되지만, rand가 다시 다운로드되진 않는다.
- cargo는 rand 패키지를 사용하는 워크스페이스 내 모든 크레이트가 동일한 버전을 사용하도록 하여 공간을 절약하고 워크스페이스의 크레이트가 서로 호환되도록 한다.

<br />

#### (2) 워크스페이스에 테스트 추가하기

```rust
pub fn add_one(x: i32) -> i32 {
    x + 1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(3, add_one(2));
    }
}
```

- 또 다른 개선을 위해 `add_one` 크레이트 내에서 `add_one::add_one` 함수 테스트를 추가하자
- 이제 최상위 디렉토리에서 `cargo test`를 실행하면 워크스페이스 내 모든 크레이트의 테스트가 실행된다.

<br />

```sh
$ cargo test
   Compiling add_one v0.1.0 (file:///projects/add/add_one)
   Compiling adder v0.1.0 (file:///projects/add/adder)
    Finished test [unoptimized + debuginfo] target(s) in 0.27s
     Running target/debug/deps/add_one-f0253159197f7841

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running target/debug/deps/adder-49979ff40686fa8e

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

- 출력의 첫번째 섹션은 `add_one` 크레이트의 `it_works` 테스트가 통과했음을 보여준다.
- 다음 섹션은 `adder` 크레이트에서 0개의 테스트가 발견됐음을 보여준다.
- 마지막 섹션은 `add_one` 크레이트에서 0개의 문서 테스트가 발견되었음을 보여준다.

<br />

```sh
$ cargo test -p add_one
    Finished test [unoptimized + debuginfo] target(s) in 0.00s
     Running target/debug/deps/add_one-b3235fea9a156f74

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests add_one

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

- 최상위에서 `-p` 플래그로 이름을 지정해 워크스페이스의 특정 크레이트에 대한 테스트만 실행할 수도 있다.
- `cargo test`가 `add_one` 크레이트에 대한 테스트만 실행하고 `adder` 크레이트 테스트는 실행하지 않았다.
- 워크스페이스의 크레이트를 crates.io에 배포하려면 각 크레이트를 별도로 배포해야 한다.
- 테스트와 마찬가지로 `-p` 플래그로 배포하려는 크레이트의 이름을 지정해 특정 크레이트를 배포할 수 있다.
- 프로젝트가 커지면 워크스페이스 사용을 고려해볼 수 있다.
- 하나의 큰 코드 덩어리보단 작은 개별 컴포넌트를 이해하는게 더 쉽다.
- 또한 워크스페이스에 크레이트를 관리하면 크레이트가 동시에 자주 변경되어도 크레이트간의 조화가 더 쉬워진다.

<br />
<hr />

## cargo install: crates.io에서 바이너리 설치하기

```sh
$ cargo install ripgrep
    Updating crates.io index
  Downloaded ripgrep v11.0.2
  Downloaded 1 crate (243.3 KB) in 0.88s
  Installing ripgrep v11.0.2
--snip--
   Compiling ripgrep v11.0.2
    Finished release [optimized + debuginfo] target(s) in 3m 10s
  Installing ~/.cargo/bin/rg
   Installed package `ripgrep v11.0.2` (executable `rg`)
```

- 설치한 모든 바이너리는 루트의 bin 폴더에 저장된다.
- rustup로 러스트를 설치하고 설정을 바꾸지 않았다면 이 디렉터리는 `$HOME/.cargo/bin`이다.
- 설치한 프로그램을 실행할 수 있도록 디렉터리를 `&PATH` 환경변수에 추가해야 한다.
- 위 예시의 마지막 줄을 보면 ripgrep은 rg 디렉터리에 설치되었다.
- 설치 디렉터리가 경로에 등록되었다면 `rg --help` 명령으로 파일을 검색할 수 있다.

<br />
<hr />

## 사용자 정의 명령으로 cargo 확장하기

- $PATH 변수에 cargo-something 바이너리가 지정되어 있다면,
- 이 바이너리는 `cargo something`처럼 cargo 하위명령으로 실행할 수 있다.
- 사용자 정의 명령은 `cargo --list`로 확인할 수 있다.
