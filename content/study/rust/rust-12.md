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

<br />
<hr />

## 테스트 주도 방법으로 라이브러리 기능 개발하기

- TDD는 소프트웨어 작성법 중 하나일 뿐이지만, 코드의 디자인 또한 주도한다.
- 여기서는 파일 내용에서 검색해 검색어를 포함하는 라인의 목록을 반환하는 기능을 작성한다.

<br />

### 실패하는 테스트 작성하기

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_result() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
    }
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
  vec![]
}
```

- 위 테스트는 검색할 검색어와 검색 대상이 되는 텍스트를 입력받아 포함하는 줄만 반환한다.
- search 함수는 아직 빈 벡터를 반환하도록 구현되어 있으므로 테스트는 실패한다.
- 이때 수명을 지정하지 않으면 러스트는 두 인수 중 어떤 것이 필요한지 알 수 없어 에러를 낸다.
  - **슬라이스가 참조하는 데이터가 유효해야 그에 대한 참조도 유효하기 때문이다.**
  - contents가 아닌 query 인수로부터 문자열 슬라이스를 만들 수도 있어 명확하지 않다.
  - 따라서 search 함수가 반환하는 데이터는 contents 인수와 같은 수명임을 명시해야 한다.

<br />

### 위 테스트 성공시키기

- contents 인수의 각 줄을 순회한다.
- 각 줄이 검색어를 포함하고 있는지 확인한다.
- 검색어가 포함되어 있으면 반환할 값의 목록에 그 줄을 추가한다.
- 검색어가 포함되어 있지 않으면 다음 줄로 건너뛴다.
- 검색어를 포함하는 줄의 목록을 반환한다.

<br />

```rust
// lib.rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
            results.push(line);
        }
    }

    results
}
```

```rust
// lib.rs
pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
  let contents = fs::read_to_string(config.filename)?;

  for line in search(&config.query, &contents) {
    println!("{}", line);
  }

  Ok(())
}
```

- `lines` 메서드는 반복자를 반환한다.
- `contains` 메서드로 검색어의 포함 야부를 확인한다.
- 검색어를 포함하는 줄을 가변 벡터 `results`에 저장한다.
- **TDD로 개발한 search 함수를 run 함수에 활용하면, 이제 검색어가 포함된 줄만 출력한다.**

<br />
<hr />

## 환경 변수 다루기

- 사용자가 환경 변수를 이용해 문자열 검색에 대소문자를 구분하지 않도록 설정해보자.
- 환경 변수를 설정하면 그 터미널 세션에서는 대소문자를 구분하지 않고 검색을 계속할 수 있다.

<br />

```rust
use std::fs;
use std::error::Error;
use std::env;

pub struct Config {
  pub query: String,
  pub filename: String,
  pub ignore_case: bool,
}

impl Config {
  pub fn new(args: &[String]) -> Result<Config, &'static str> {
      if args.len() < 3 {
          return Err("필요한 인수가 지정되지 않았습니다.");
      }

      let query = args[1].clone();
      let filename = args[2].clone();
      let ignore_case = env::var("IGNORE_CASE").is_ok();

      Ok(Config {
          query,
          filename,
          ignore_case,
      })
  }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
  let contents = fs::read_to_string(config.filename)?;

  let results = if config.ignore_case {
      search_case_insensitive(&config.query, &contents)
  } else {
      search(&config.query, &contents)
  };

  for line in results {
      println!("{}", line);
  }

  Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn case_sensitive() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Duct tape.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
    }

    #[test]
    fn case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Trust me.";

        assert_eq!(
            vec!["Rust:", "Trust me."],
            search_case_insensitive(query, contents)
        );
    }
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
  let mut results = Vec::new();

  for line in contents.lines() {
      if line.contains(query) {
          results.push(line);
      }
  }

  results
}

pub fn search_case_insensitive<'a>(
  query: &str,
  contents: &'a str,
) -> Vec<&'a str> {
  let query = query.to_lowercase();
  let mut results = Vec::new();

  for line in contents.lines() {
      if line.to_lowercase().contains(&query) {
          results.push(line);
      }
  }

  results
}
```

```txt
$ IGNORE_CASE=1 cargo run to poem.txt
```

- `search_case_insensitive` 함수는 'rUsT'라는 검색어로 'Rust', 'Trust me'를 찾아낸다.
- `to_lowercase` 메서드는 기존 데이터를 참조하는 것이 아니라 새로운 데이터를 생성한다.
- 따라서 query 섀도우 변수는 문자열 슬라이스가 아니라 문자열이다.
- `contains` 메서드는 문자열 슬라이스가 매개변수이기 때문에 query의 참조(&)를 넘겨야 한다.
- `ignore_case` 변수는 env::var 함수의 IGNORE_CASE 환경 변수 값이 대입된다.
- `env::var` 함수는 환경 변수가 설정되어 있으면 Ok, 그렇지 않으면 Err를 반환하는 Result 타입이다.
- 여기서는 환경 변수의 값보다는 어떤 값이든 설정되어 있는지 여부만 확인한다.
- 따라서 unwrap, expect 보다는 값이 있기만 하면 false를 반환하는 `is_err`가 적합하다.
- **이제 IGNORE_CASE에 값을 설정하면 'to'의 검색 결과에 대문자도 포함된다.**

<br />
<hr />

## stderr를 이용해 에러메시지 출력

- println! 매크로는 표준 출력에만 지정된 메시지를 출력한다.
- 따라서 표준 에러를 이용해 메시지를 출력하려면 다른 방법을 사용해야 한다.
- 대부분의 터미널에서의 output 종류:
  - `stdout`: standard output for general information
  - `stderr`: standard error for error messages

<br />

### 에러의 기록 여부 확인하기

```txt
cargo run > output.txt
```

- `>`를 통해 출력 메시지를 화면이 아닌 파일에 기록하도록 한다.
- 따라서 에러 메시지를 화면에서 확인할 수 없고, output.txt 파일에 기록되었다.
- 하지만 에러 메시지는 다른 커맨드 프로그램처럼 터미널 화면에 보이는 편이 낫다.
- **즉, stderr로 출력해서 프로그램이 성공했을 때의 데이터만 파일에 기록되는 편이 낫다.**

<br />

### 에러를 stderr로 출력하기

```rust
// main.rs
fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });

    if let Err(e) = minigrep::run(config) {
        eprintln!("애플리케이션 에러: {}", e);
        process::exit(1);
    }
}
```

```txt
(1)
$ cargo run > output.txt

(2)
$ cargo run to poem.txt > output.txt
```

- `eprintln!`는 표준 에러 스트림에 메시지를 출력하는 표준 라이브러리가 지원하는 매크로다.
- (1)을 다시 실행해보면 다른 커맨드 프로그램처럼 에러 메시지가 터미널 화면에 출력된다.
- (2)를 실행해보면 터미널에는 아무것도 출력되지 않지만, 검색 결과가 output.txt에 기록된다.
