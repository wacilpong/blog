---
title: "After reading Rust book chapter 12"
date: "2022-06-30"
tags: ["rust"]
draft: false
og_description: "An I/O Project: Building a Command Line Program"
---

## Accepting Command Line Arguments

### Reading the Argument Values

```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    let query = &args[1];
    let filename = &args[2];

    println!("검색어: {}", query);
    println!("대상 파일: {}", filename);
}
```

- 커맨드의 인수를 읽기 위해 표준 라이브러리의 `args` 함수를 사용해야 한다.
- `collect` 함수는 다양한 종류의 컬렉션을 만들 수 있다.
- 따라서 args 변수 타입을 문자열의 벡터로 명시해야 한다.
- 러스트에서 타입을 명시할 일이 거의 없지만, collect 함수는 반드시 명시해야 한다.
- args[0]에는 프로그램의 이름이 저장되어 있으므로 인덱스 1부터 사용한다.
- 위 코드에 `cargo run hi test.txt`를 실행한 결과값:
  _검색어: hi 대상 파일: test.txt_

<br />

### Reading a File

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let query = &args[1];
    let filename = &args[2];

    println!("검색어: {}", query);
    println!("대상 파일: {}", filename);

    let contents = fs::read_to_string(filename).expect("파일을 읽지 못했습니다.");

    println!("파일 내용:\n{}", contents);
}
```

- 파일 처리를 위해 표준 라이브러리 fs 모듈의 `read_to_string` 함수를 사용해야 한다.
- 해당 함수는 파일의 내용을 `Result<String>` 타입으로 반환한다.
- 해당 프로젝트 루트에 poem.txt 파일을 만들어서 실행하면 된다.
- 위 코드는 다음의 개선할만한 지점이 있다.
  - main 함수가 인수 처리와 파일 열기 2가지 작업을 하고 있어 분리가 필요하다.
  - filename, contents 등 설정 변수들을 구조체로 묶어 목적을 명확히 해야 한다.
  - 에러 메시지가 너무 단순하므로 다양한 상황을 잡을 수 있어야 한다.
  - 필요한 인수를 구체화하지 않아 인덱스 범위를 벗어났다는 러스트 에러가 발생한다.

<br />
<hr />

## Refactoring to Improve Modularity and Error Handling

### 바이너리 프로젝트의 관심 분리

#### (1) 인수 구문분석 분리하기

```rust
fn main() {
  ...
  let (query, filename) = parse_config(&args);
  ...
}

fn parse_config(args: &[String]) -> (&str, &str) {
    let query = &args[1];
    let filename = &args[2];

    (query, filename)
}
```

- main 함수가 여러 작업을 수행하는 책임 문제는 바이너리 프로젝트에서 쉽게 찾을 수 있다.
- 러스트는 바이너리 프로그램의 main 함수의 관심을 분리하기 위한 지침을 제공한다:
  - 프로그램을 main.rs와 lib.rs로 분리하고 로직을 lib.rs 파일로 옮긴다.
  - 커맨드 구문분석 로직이 충분히 작다면 main.rs 파일에 남겨둔다.
  - 커맨드 구문분석 로직이 복잡해지기 시작하면 main.rs에서 추출해 lib.rs로 옮긴다.
- `parse_config`는 main 함수에서 인수 구문분석 로직만 추출해온 함수다.
- 지금처럼 작은 프로그램에서는 과도하게 보이지만, 점진적 리팩토링을 위해 필요하다.

<br />

#### (2) 설정값의 그룹화

```rust
fn main() {
  ...
  let config = parse_config(&args);
  ...
}

struct Config {
    query: String,
    filename: String
}

fn parse_config(args: &[String]) -> Config {
    let query = args[1].clone();
    let filename = args[2].clone();

    Config { query, filename }
}
```

- 튜플 대신 관련있는 필드를 묶어 `Config` 구조체를 생성하고, 두 값이 연관있음을 표현한다.
- 직접 String 값을 소유하는 Config 인스턴스를 반환하는 이유:
  - 인수값의 소유권은 main 함수의 args 매개변수에 있으며, `parse_config` 함수는 이 값을 대여하고 있다.
  - 즉, Config 구조체가 args 벡터의 값에 대한 소유권을 가지려고 하면 러스트 대여 규칙을 위반하는 셈이다.
  - **따라서 clone 메서드를 호출해 복제본을 만드는데, 문자열 데이터의 참조를 저장할 때보다 메모리 소모는 크지만, 참조 수명을 관리할 필요가 없다. (트레이드오프)**

<br />

#### (3) Config 구조체의 생성자

```rust
fn main() {
  ...
  let config = Config::new(&args);
  ...
}

struct Config {
    query: String,
    filename: String
}

impl Config {
    fn new(args: &[String]) -> Config {
        let query = args[1].clone();
        let filename = args[2].clone();

        Config { query, filename }
    }
}
```

- 생각해보면 `parse_config` 함수의 목적은 Config 인스턴스를 생성하는 것이다.
- 따라서 더욱 보편적인 패턴에 따라 Config 구조체의 연관함수로 바꾸는 편이 낫다.

<br />

### 에러 처리 개선하기

- args 벡터가 3개보다 적으면 인덱스 1과 2를 참조할 때 패닉이 발생한다.
  _index out of bounds: the len is 1 but the index is 1_
- 최종 사용자 입장에서는 왜 이런 에러가 발생하는지 알 수 없으므로 개선해야 한다.

<br />

#### (1) 에러 메시지 개선하기

```rust
impl Config {
    fn new(args: &[String]) -> Config {
        if args.len() < 3 {
            panic!("필요한 인수가 지정되지 않았습니다.");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        Config { query, filename }
    }
}
```

- new 연관함수에 길이가 충분한지 검사하는 코드를 추가했다.
- 그러나 `panic!` 매크로는 사용상의 문제보다 프로그래밍적 문제에 적합하다.
- 따라서 작업의 성공/실패 여부를 의미하는 Result 타입을 반환하도록 하자.

<br />

#### (2) panic! 매크로 호출 대신 Result 반환하기

```rust
impl Config {
    fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("필요한 인수가 지정되지 않았습니다.");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}
```

- 작업이 성공하면 Config 인스턴스를 반환하고, 그렇지 않으면 에러메시지를 반환한다.
- 이때 `&'static str`은 정적 수명을 가진 문자열 리터럴 타입이며 에러메시지를 저장하기 위함이다.

<br />

#### (3) Config::new 함수 호출하고 에러 처리하기

```rust
use std::process;

fn main() {
  ...
  let config = Config::new(&args).unwrap_or_else(|err| {
      println!("Problem parsing arguments: {}", err);
      process::exit(1);
  });
  ...
}
```

- 0이 아닌 상태는 프로그램을 호출한 프로세스에게 프로그램이 에러 상태여서 종료되었음을 알리는 규칙이다.
- `unwrap_or_else`는 표준 라이브러리가 `Result<T, E>`타입에 정의한 메서드다.
  - panic! 매크로가 아닌 다른 방법으로 에러를 처리할 수 있다.
  - Ok 값이면 그 열거값에 저장된 값을 반환한다.
  - **Err 값이면 클로저를 이용해 해당 메서드에 전달한 익명함수를 호출한다.**
  - **Err에 저장되는 값은 익명함수의 파이프 문자(|) 사이에 선언하는 인수에 전달된다.**

<br />

### main 함수에서 로직 분리하기

```rust
fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    println!("검색어: {}", config.query);
    println!("대상 파일: {}", config.filename);

    run(config);
}

fn run(config: Config) {
    let contents = fs::read_to_string(config.filename).expect("파일을 읽지 못했습니다.");

    println!("파일 내용:\n{}", contents);
}
```

- 현재 작성된 코드에서 설정, 에러처리와 관련되지 않은 코드를 분리할 수 있다.
- main 함수를 더 쉽게 검증할 수 있으며 나머지 로직에 대한 테스트도 작성할 수 있다.

<br />

```rust
...
use std::error::Error;

fn main() {
    ...
    if let Err(e) = run(config) {
        println!("애플리케이션 에러: {}", e);
        process::exit(1);
    }
}

fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    println!("파일 내용:\n{}", contents);

    Ok(())
}
```

- run 함수는 원래 유닛타입을 반환했으므로 Ok인 경우 유지한다.
- `Box<dyn Error>`는 트레이트 객체로 함수가 Error 트레이트를 구현하는 타입을 반환하지만, 반환될 값의 타입은 특정하지 않는다는 의미이다.
- **panic! 매크로 호출 대신 `?` 연산자를 사용하면 현재 함수의 호출자에게 에러값을 반환할 수 있다.**
- run 함수는 성공 시 ()를 반환하므로 오로지 에러가 발생했는지만 파악하면 된다.
- 따라서 `unwrap_or_else`를 이용해 ()값을 얻어올 필요가 없다.
- if let 구문과 기존 unwrap_or_else 함수 본문은 같다.
- 즉, 에러메시지 출력 후 프로그램을 종료한다.

<br />

### 라이브러리 크레이트로 분리하기

```rust
// lib.rs
use std::fs;
use std::error::Error;

pub struct Config {
  pub query: String,
  pub filename: String
}

impl Config {
  pub fn new(args: &[String]) -> Result<Config, &'static str> {
      if args.len() < 3 {
          return Err("필요한 인수가 지정되지 않았습니다.");
      }

      let query = args[1].clone();
      let filename = args[2].clone();

      Ok(Config { query, filename })
  }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
  let contents = fs::read_to_string(config.filename)?;

  println!("파일 내용:\n{}", contents);

  Ok(())
}
```

```rust
// main.rs
use std::env;
use std::process;

use minigrep::Config;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    println!("검색어: {}", config.query);
    println!("대상 파일: {}", config.filename);

    if let Err(e) = minigrep::run(config) {
        println!("애플리케이션 에러: {}", e);
        process::exit(1);
    }
}
```

- 이제 lib.rs는 테스트할 수 있는 공개 API를 갖게 된 셈이다.
- 따라서 main.rs에서 스코프로 가져와서 사용할 수 있다.
