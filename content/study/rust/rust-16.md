---
title: "After reading Rust book chapter 16"
date: "2022-08-06"
tags: ["rust"]
draft: false
og_description: "Fearless Concurrency"
---

- 다중 프로세서를 사용할 수록 동시성과 병렬 처리가 중요해지고 있다.
- 이 챕터에서 동시성을 말할 때 개념적으로 병렬 처리라고 생각해도 된다.

<br />

## 코드를 동시에 실행하기 위해 스레드 사용하기

- 프로그램의 계산을 여러 스레드로 나누어 처리하면 성능은 향상되지만 복잡해진다.
  - Race condition: 스레드가 처리되는 순서 문제
  - Deadlocks: 두 스레드가 서로 처리되기를 기다리는 교착 문제
  - 특정 상황에서만 발생해 재현하기 어려운 버그
- 여러 언어에서는 운영체제가 스레드를 만들도록 호출할 수 있는 API를 제공한다.
- 러스트 표준 라이브러리는 1:1 스레드 구현 모델을 사용한다.
- 러스트 프로그램은 하나의 언어 스레드 당 하나의 운영체제 스레드를 사용한다.

<br />

### `spawn`: 스레드 생성하기

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }
}
```

- `thread::sleep`은 현재 실행중인 스레드를 강제로 종료하는 함수다.
- 메인 스레드가 완료되면, 모든 spawn 스레드는 실행 여부와 상관없이 종료된다.
- 따라서 위 코드는 숫자 4까지 각각 출력되다가, 5에서 spawn 것만 출력되며 끝난다.
- 그러나 스레드의 실행 순서와, spawn 스레드가 다 실행되는지는 보장할 수 없다.

<br />

### `join`: 모든 스레드 끝나도록 기다리기

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    // (1)
    // handle.join().unwrap();

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }

    // (2)
    handle.join().unwrap();
}
```

```rust
// (1) 결과
hi number 1 from the spawned thread!
hi number 2 from the spawned thread!
hi number 3 from the spawned thread!
hi number 4 from the spawned thread!
hi number 5 from the spawned thread!
hi number 6 from the spawned thread!
hi number 7 from the spawned thread!
hi number 8 from the spawned thread!
hi number 9 from the spawned thread!
hi number 1 from the main thread!
hi number 2 from the main thread!
hi number 3 from the main thread!
hi number 4 from the main thread!
```

```rust
// (2) 결과
hi number 1 from the main thread!
hi number 2 from the main thread!
hi number 1 from the spawned thread!
hi number 3 from the main thread!
hi number 2 from the spawned thread!
hi number 4 from the main thread!
hi number 3 from the spawned thread!
hi number 4 from the spawned thread!
hi number 5 from the spawned thread!
hi number 6 from the spawned thread!
hi number 7 from the spawned thread!
hi number 8 from the spawned thread!
hi number 9 from the spawned thread!
```

- `thread::spawn`의 반환 타입은 `JoinHandle`이다.
- 해당 구조체의 메서드인 join을 실행하면 모든 스레드가 종료되기를 기다린다.
- 따라서 위 코드는 생성하는 모든 spawn 스레드가 완료된다.
- (2)처럼 for loop 이전에 join을 실행하면 spawn 스레드를 모두 기다렸다가 main 스레드가 실행된다.

<br />

### `move` Closures: 다른 스레드로 소유권 이동하기

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Here's a vector: {:?}", v);
    });

    // (1)
    // drop(v)

    handle.join().unwrap();
}
```

- 러스트 클로저는 환경을 캡쳐해 spawn으로 생성된 스레드에서 v에 접근할 수 있어야 한다.
- 이때 v에 대한 참조를 빌려와 출력을 시도하지만, 러스트는 이 스레드가 얼마나 유효한지 알 수 없다.
- 따라서 위 코드는 에러를 낸다.
  _closure may outlive the current function, but it borrows `v`, which is owned by the current function_
- 그렇다고 drop으로 v를 해제하면 생성되는 스레드가 전혀 실행되지 않을 수 있다.
- spawn 스레드가 v를 참조하지만 main 스레드가 즉시 v를 해제하므로 v는 유효하지 않게 된다.
  _help: to force the closure to take ownership of `v` (and any other referenced variables), use the `move` keyword_

<br />

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

    // (1)
    // drop(v)

    handle.join().unwrap();
}
```

- 클로저 앞에 move를 붙여 클로저가 사용하는 값의 소유권을 강제로 갖도록 할 수 있다.
- 이때 v는 클로저가 사용된 환경으로 소유권이 이동되므로 (1)의 v는 사용할 수 없다.
  _value used here after move_
