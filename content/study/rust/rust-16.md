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

<br />
<hr />

## 멀티 스레드 사용하기

### 메시지 패싱

#### 채널

- 쓰레드 간 통신하는 방법
- 데이터를 송신하는 transmitter, 수신하는 receiver
  - 둘 중에 하나라도 drop되면 채널은 닫힘

<br />

#### 채널 생성

```rust
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();
}
```

- `mpsc(multiple producer single consumer)` 라이브러리 사용
- 데이터를 보내는 주체는 여럿이 될 수 있지만 받는 주체는 하나뿐

<br />

#### 채널을 통해 메시지 주고받기

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
    });

    let received = rx.recv().unwrap();
    println!("Got: {}", received);
}
```

- `recv`: 쓰레드 블락하고 데이터 올 때까지 기다림
- `try_recv`: 실행하는 시점에 바로 `Result<T, E>` 타입 리턴. 데이터가 올 때까지 반복적으로 호출하면 되며, 다른 작업과 병행해야 할 때 유용함

<br />

#### 채널과 소유권 이전

```rust
fn main() {
    thread::spawn(move || {
        let val = String::from("hi");

				// 소유권 넘어감
        tx.send(val).unwrap();

				// Error: borrow of moved value: `val`
        println!("val is {}", val);
    });
}
```

- rust의 소유권 이전은 Race Condition 문제를 컴파일 시점에 체크해줌

<br />

#### Multiple Producer

```rust
fn main() {
    let (tx, rx) = mpsc::channel();
    let tx1 = tx.clone();
}
```

- `clone` 메서드 이용해서 producer 복사
- 동일한 기능 그대로 사용 가능

<br />

### 상태 공유

#### 뮤텍스

- 동일한 위치의 데이터에 여러 개의 쓰레드가 동시에 접근하면 데이터의 동기화 문제가 생김
- 이를 해결하기 위해 데이터에 접근하기 위해서는 `락(lock)`을 가지고 있어야 하는 제약을 둔 방법
- 데이터 사용이 끝나면 락을 반납해야 함

<br />

#### Mutex<T>

- 뮤텍스 구현
- `Deref`, `Drop` 트레이트를 구현한 스마트 포인터
- `lock` 메서드는 `MutexGuard` 타입을 반환하는데, 이 타입은 스코프가 끝나면 자동으로 락을 해제함

```rust
use std::sync::Mutex;

fn main() {
		// 초기값 5
    let m = Mutex::new(5);

    {
        let mut num = m.lock().unwrap();

				// 값을 6으로 변경
        *num = 6;
    }

    println!("m = {:?}", m);
}
```

<br />

#### Arc<T> - Mutex<T> 공유하기

- 스마트 포인터를 공유할 때 사용했던 `Rc<T>` 타입을 사용하면 에러가 난다

  ```rust
  use std::rc::Rc;
  use std::sync::Mutex;
  use std::thread;

  fn main() {
      let counter = Rc::new(Mutex::new(0));
      let mut handles = vec![];

      for _ in 0..10 {
          let counter = Rc::clone(&counter);
          let handle = thread::spawn(move || {
              let mut num = counter.lock().unwrap();

              *num += 1;
          });
          handles.push(handle);
      }

      for handle in handles {
          handle.join().unwrap();
      }

      println!("Result: {}", *counter.lock().unwrap());
  }
  ```

  - Error: Rc<Mutex<i32>> cannot be sent between threads safely
  - Rc<T> 타입은 멀티쓰레드 사용에 안전하지 않음

- 멀티쓰레드 사용에 안전한 `Arc<T>` 타입을 사용해야 함
  - `Rc<T>`와 사용방법은 거의 동일함
  - 멀티쓰레드를 안전하게 사용하기 위한 오버헤드가 추가적으로 발생하기 때문에 멀티쓰레드 사용 상황이 아닌 경우엔 `Rc<T>`를 사용하는 것을 권장함

<br />

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

<br />

#### Send & Sync

- Send: 쓰레드 간 소유권 이전이 가능하게 해줌
- Sync: 여러 쓰레드에서 데이터를 참조할 수 있게 해줌
- `Arc<T>` 를 사용하려면 T가 Send, Sync 트레이트를 구현해야 함

  ```rust
  use std::sync::{Arc, Mutex};
  use std::thread;
  use std::rc::Rc;

  fn main() {
  		// the trait `Send` is not implemented for `Rc<Mutex<i32>>`
  		// the trait `Sync` is not implemented for `Rc<Mutex<i32>>`
      let counter = Arc::new(Rc::new(Mutex::new(0)));

  		// 멀티쓰레드 사용하는 부분...
  }
  ```

- 직접 구현하는 것은 권장하지 않음

<br />
<hr />

## Rust의 멀티쓰레드는 언제나 안전한 걸까?

- 그건 아니다.
- 데드락 같은 상황은 컴파일 시점에 캐치되지 않을 수 있으니 주의해야 함
  ```rust
  use std::sync::{Arc, Mutex};
  use std::thread;
  use std::time::Duration;

  fn main() {
      let counter = Arc::new(Mutex::new(0));
      let counter2 = Arc::new(Mutex::new(0));

      let mut handles = vec![];

      for i in 0..2 {
          let counter = Arc::clone(&counter);
          let counter2 = Arc::clone(&counter2);

          let handle = thread::spawn(move || {
              let mut num;
              let mut num2;

              if i == 0 {
                  num = counter.lock().unwrap();
                  thread::sleep(Duration::from_millis(100));
                  num2 = counter2.lock().unwrap();
              } else {
                  num = counter2.lock().unwrap();
                  thread::sleep(Duration::from_millis(100));
                  num2 = counter.lock().unwrap();
              }

              *num += 1;
              *num2 += 1;
          });

          handles.push(handle);
      };

      for handle in handles {
          handle.join().unwrap();
      }

      println!("Result: {}", *counter.lock().unwrap());
  }
  ```
