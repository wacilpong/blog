---
title: "After reading Rust book chapter 8"
date: "2022-05-29"
tags: ["rust"]
draft: false
og_description: "Common Collections"
---

## Vector

```rust
// (1)
let v: Vec<i32> = Vec::new();

// (2)
let v = vec![1, 2, 3];

// (3)
let mut v = Vec::new();

v.push(5);
v.push(6);
v.push(7);
v.push(8);
```

- 연속된 일련의 값을 저장하는 컬렉션, `Vec<T>`
- 모든 값은 메모리상에 연속으로 저장되고, 같은 타입의 값만 저장할 수 있다.
- (1)처럼 빈 벡터를 생성할 수도 있고, 러스트는 벡터에 값을 추가하면 타입을 추론할 수 있으므로 (2)처럼 값을 지정해 벡터를 생성하는 `vec!` 매크로를 제공한다.
- (3)처럼 `push` 메서드를 이용해 뮤터블한 벡터에 값을 추가할 수 있다.
- **다른 구조체와 마찬가지로 벡터도 스코프를 벗어나면 해제, 즉 drop 메서드가 호출된다.**
- _벡터에 참조형 값을 저장하면 복잡해지는데, 다음 기회에 알려준다고 한다.. !?_

<br />

#### 벡터로부터 값 읽기

```rust
let v = vec![1, 2, 3, 4, 5];

// (1)
let third: &i32 = &v[2];

println!("The third element is {}", third);

// (2)
match v.get(2) {
    Some(third) => println!("The third element is {}", third),
    None => println!("There is no third element."),
}

// (3)
let mut v = vec![1, 2, 3, 4, 5];
let first = &v[0];

v.push(6);
println!("The first element is: {}", first);
```

- (1)은 **&와 []를 이용해 인덱스 문법으로 접근하는 방법이며, 저장된 값의 참조를 반환한다.**
- (2)은 **get 메서드를 이용하고, 이때는 Option<&T> 타입의 값을 반환한다.**
- 벡터에 존재하지 않는 인덱스값을 사용할 때 프로그램이 어떻게 반응할 지 직접 결정할 수 있다.
- (1)의 방식으로는 패닉을 발생시키므로 프로그램이 강제 종료되기를 원할 때 유용하다.
- (2)의 방식은 None값이 반환되므로 벡터의 범위를 벗어나 읽으려는 시도가 빈번할 때 유용하다.
- 벡터 또한 소유와 대여 규칙이 적용되므로 (3)은 아래와 같은 에러를 낸다.
  - _cannot borrow `v` as mutable because it is also borrowed as immutable_
  - 같은 스코프에서 가변참조와 불변참조를 동시에 가질 수 없기 때문이다.

<br />

#### 벡터의 값 순회하기

```rust
// (1)
let v = vec![100, 32, 57];
for i in &v {
    println!("{}", i);
}

// (2)
let mut v = vec![100, 32, 57];
for i in &mut v {
    *i += 50;
}
```

- (1)은 for loop으로 벡터에 저장된 i32타입의 값에 대한 불변참조를 가져와 출력한다.
- (2)은 가변 벡터에 저장된 값에 대한 가변참조를 가져와 값을 변경하고 있다.
- 가변참조가 가리키는 값을 변경하려면 `역참조 연산자(*)`를 이용해야 하는데, 이는 15장에서 다룬다.

<br />

#### 벡터에 enum을 통해 여러 타입 저장하기

```rust
enum SpreadsheetCell {
    Int(i32),
    Float(f64),
    Text(String),
}

let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("blue")),
    SpreadsheetCell::Float(10.12),
];
```

- 어떤 아이템 목록에 각기 다른 타입의 값을 저장할 일은 많다.
- **따라서 enum을 활용하면 벡터에 각기 다른 타입의 값을 저장할 수 있다.**
- 러스트는 컴파일 시점에 벡터에 어떤 타입의 값이 저장될지 알아야 한다.
- 따라서 프로그램 작성 시점에 저장할 타입들을 알 수 없다면 이 방법도 유용하지 않다.
  _그때는 17장에서 설명할 트레이트 객체를 사용한다._

<br />
<hr />

## String

```rust
// (1)
let mut s = String::new();

// (2)
let data = "초기값";
let s = data.to_string();

// (3)
let s = String::from("초기값");
```

- 문자(character)의 컬렉션이며, UTF-8 형식으로 저장된다.
- **러스트 언어 명세에서는 오직 문자열 슬라이스 str 타입만 지원하고, 주로 값을 대여한 &str 형태로 자주 보인다.**
- 반면 String 타입은 러스트의 표준 라이브러리가 제공하는 타입이다.
- 러스트에서 문자열이란 둘 중 하나를 의미하는 것이 아니라, 둘을 동시에 의미한다.
- 위 예시처럼 문자열을 생성하는 방법은 다양하며, 셋 모두 문자열 리터럴인 String 타입이다.

<br />

#### 문자열 수정하기

```rust
// (1)
let mut s1 = String:from("foo");
let s2 = "bar";

s1.push_str(s2);
println!("s2: {}", s2);

// (2)
let s1 = String::from("hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2;

// (3)
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");
let s = format!("{}-{}-{}", s1, s2, s3);
```

- (1)의 **push_str 메서드는 매개변수의 소유권을 가지지 않으므로**, 코드에서 s1에 붙인 후에 println에서도 s2를 여전히 사용할 수 있다.
- (2)의 + 연산자는 내부적으로 add라는 메서드를 사용한다.
  - `fn add(self, s: &str) -> String {...}`
  - 두번째 인자로 &str 타입을 받는데, String 타입을 넣어도 강제 역참조에 의해 변환된다.
  - self에 소유권이 있으므로 (2)의 s1은 메서드 스코프로 이동하므로 유효하지 않게 된다.
  - 복잡한 문자열을 결합할 경우 +와 " 기호 때문에 문자열의 최종형태 가늠이 어렵다.
- (3)의 **format! 매크로를 사용하면 결합된 String 값을 반환하고, 인자에 대한 소유권도 없다.**

<br />

#### 문자열의 인덱스

```rust
// (1)
let len = String::from("Hola").len();

// (2)
let len = String::from("안녕하세요").len();

// (3)
[236, 149, 136, 235, 133, 149, 237, 149, 152, 236, 132, 184, 236, 154, 148]
['안', '녕', '하', '세', '요']
["안", "녕", "하", "세", "요"]

// (4)
let hello = "안녕하세요";
let s = &hello[0..3];
```

- 러스트의 문자열은 인덱스를 지원하지 않는데, 메모리에 어떻게 저장하는지부터 알아야 한다.
- (1)의 길이는 4이자 벡터에 저장된 문자열의 길이가 4byte라는 뜻이다.
- (2)의 길이는 5지만 **유니코드의 스칼라값은 3byte이므로 '안녕하세요'를 UTF-8로 인코딩하면 15byte이다.**
- 러스트 관점에서 문자열은 크게 바이트, 스칼라값, 그래핌 클러스터(문자라고 부르는 것에 가까운 것)로 구분된다.
  - (3)처럼 '안녕하세요'는 총 15개의 바이트값으로 저장된다.
  - (3)의 두번째 줄은 이를 러스트의 char타입인 유니코드 스칼라값으로 표현한 것이다.
  - (3)의 마지막 줄은 같은 데이터를 그래핌 클러스터로 표현한 것이다.
- String 타입에 인덱스를 지원하지 않는 큰 이유는, **인덱스 처리는 항상 O(1)이 소요되어야 하지만, 러스트는 유효한 문자를 파악하기 위해 처음부터 스캔해야 하므로 String 타입에서만큼은 일정한 성능을 보장할 수 없어서다.**
- 그럼에도 (4)처럼 인덱스를 활용해 문자열 슬라이스를 만들 수도 있다.
  - 이때 앞서 말했듯 한 글자가 3byte를 차지하므로 변수 s는 '안'이 된다.
  - `&hello[0..1]`처럼 작성하면 런타임에 패닉이 발생하므로 주의하자.
  - _thread 'main' panicked at 'byte index 1 is not a char boundary;_

<br />

#### 문자열 순회

```rust
// (1)
for c in "안녕하세요".chars() {
  println!("{}", c);
}

// (2)
for b in "안녕하세요".bytes() {
  println("{}", b);
}
```

- (1)을 통해 개별 유니코드 스칼라값을 순회할 수 있다.
- (2)을 통해 문자열의 각 바이트를 반환해 순회할 수 있다.
- 문자열에서 그래핌 클러스터를 가져오는 방법은 너무 복잡해서 표준 라이브러리는 제공하지 않는다.

<br />

#### Strings Are Not So Simple

- 러스트는 UTF-8 데이터를 다루기에 충분한 고민을 하게 만든다.
- 러스트의 문자열에 대한 방식은 조금 복잡할지라도, **개발 시점에 ASCII 문자가 아닌 다른 형식의 문자를 다룰 때 에러를 처리해야할 필요가 없다는 장점이 있다.**

<br />
<hr />

## Hash Map

```rust
// (1)
use std:collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("블루"), 10);
scores.insert(String::from("레드"), 50);

// (2)
use std::collections::HashMap;

let teams = vec![String::from("블루"), String::from("레드")];
let initial_scores = vec![10, 50];
let mut scores: HashMap<_, _> = teams.into_iter().zip(initial_scores.into_iter()).collect();
```

- 특정 키에 값을 연결할 때 사용하며, 더 범용으로 사용되는 map을 구현한 구현체다.
- 다양한 언어에 존재하며 해시 테이블, 딕셔너리, 연관 배열과 같은 이름을 지닌다.
- **범용 컬렉션 중에서는 사용빈도가 낮아 프렐류드를 통해 자동으로 가져오지 않으므로 use로 가져와야 한다.**
- 벡터와 마찬가지로 해시맵은 데이터를 힙 메모리에 저장하고, 모든 키와 모든 값의 타입은 같아야 한다.
- (1)처럼 new 함수를 통해 빈 해시맵을 생성할 수 있다.
- (2)처럼 튜플의 벡터에 `collect` 메서드를 호출해 해시맵으로 변환할 수도 있다.

<br />

#### 해시맵과 소유권

```rust
use std::collections::HashMap;

let field_name = String::from("Favorite color");
let field_value = String::from("Blue");

let mut map = HashMap::new();
map.insert(field_name, field_value);
// field_name and field_value are invalid at this point
// try using them and see what compiler error you get!
```

- i32처럼 copy트레이트를 구현하는 타입은 값들이 해시맵으로 복사된다.
- 하지만 String처럼 값을 소유하는 타입은 값과 함께 소유권이 해시맵으로 이동된다.

<br />

#### 해시맵 값 접근/수정하기

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow"), 50);

let team_name = String::from("Blue");
let score = scores.get(&team_name);

for (k, v) in &scores {
  println!("{}: {}", k, v);
}

// (1)
scores.insert(String::from("Red"), 10);
scores.insert(String::from("Red"), 20);

// (2)
scores.entry(String::from("Green")).or_insert(50);
scores.entry(String::from("Green")).or_insert(60);

// (3)
use std::collections::HashMap;

let text = "hello world wonderful world";
let mut map = HashMap::new();

for word in text.split_whitespace() {
  let count = map.entry(word).or_insert(0);
  *count += 1;
}

println!("{:?}", map);
```

- **해시맵의 get 메서드는 Option<&V> 타입을 반환하고, 그 키에 값이 없으면 None을 반환한다.**
- for loop을 통해 해시맵의 키-쌍을 순회하고, 임의의 순서로 출력할 수 있다.
- (1)처럼 같은 키로 insert하면 처음 마지막 것으로 값을 덮으므로 Red의 값은 20이다.
- (2)의 `entry` 메서드는 키에 값이 할당되지 않을 때만 추가하므로 Green의 값은 50이다.
- (3)처럼 기존 값에 따라 새로운 해시맵을 만들 수도 있다.
  - (3)의 map 결과는 `{"world": 2, "hello": 1, "wonderful": 1}`이다.
  - `or_insert` 메서드는 키에 할당된 값에 대한 가변 참조(&mut V)를 반환한다.
  - 가변참조를 count변수에 저장했으므로 이 변수에 새 값을 할당하려면 count를 역참조(\*)해야 한다.
