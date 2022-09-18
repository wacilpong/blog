---
title: "After reading Rust book chapter 20"
date: "2022-09-09"
tags: ["rust"]
draft: false
og_description: "Final Project: Building a Multithreaded Web Server"
---

## Single-Threaded Web Server

```rust
// src/main.rs
use std::{
    fs,
    io::{prelude::*, BufReader},
    net::{TcpListener, TcpStream},
};

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        handle_connection(stream);
    }
}

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);

    // calling `next` to get the first item from the iterator.
    // The first `unwrap` takes care of the `Option` and stops the program if the iterator has no items.
    // The second `unwrap` handles the `Result` and has the same effect as the unwrap that was in the map.
    let request_line = buf_reader.lines().next().unwrap().unwrap();

    let (status_line, filename) = if request_line == "GET / HTTP/1.1" {
        ("HTTP/1.1 200 OK", "src/hello.html")
    } else {
        ("HTTP/1.1 404 NOT FOUND", "src/404.html")
    };

    let contents = fs::read_to_string(filename).unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

<br />

## Turning into a Multithreaded Server

```rust
use std::{
    fs,
    io::{prelude::*, BufReader},
    net::{TcpListener, TcpStream},
    thread,
    time::Duration,
};

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        thread::spawn(|| {
            handle_connection(stream);
        });
    }
}

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let request_line = buf_reader.lines().next().unwrap().unwrap();

    let (status_line, filename) = match &request_line[..] {
        "GET / HTTP/1.1" => ("HTTP/1.1 200 OK", "src/hello.html"),
        "GET /sleep HTTP/1.1" => {
            thread::sleep(Duration::from_secs(5));
            ("HTTP/1.1 200 OK", "src/hello.html")
        }
        _ => ("HTTP/1.1 404 NOT FOUND", "src/404.html"),
    };

    let contents = fs::read_to_string(filename).unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

- `/sleep`으로 진입하면 `thread::sleep` 구문으로 인해 5초 늦게 DOM이 그려진다.
- `handle_connection` 호출할 때 새로운 스레드를 만들지 않으면 새 탭에서 동기적으로 동작한다.
  - `/sleep`을 띄운 상태에서 새 탭을 열어 `/`를 진입해보면 알 수 있다.
  - `thread::spawn`를 통해 새 스레드를 생성하면 기다릴 필요 없이 동작한다.

<br />

```rust
// src/main.rs
use std::{
    fs,
    io::{prelude::*, BufReader},
    net::{TcpListener, TcpStream},
    thread,
    time::Duration,
};

use hello_server::ThreadPool;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
    let pool = ThreadPool::new(4);

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        pool.execute(|| {
            handle_connection(stream);
        });
    }
}

fn handle_connection(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let request_line = buf_reader.lines().next().unwrap().unwrap();

    let (status_line, filename) = match &request_line[..] {
        "GET / HTTP/1.1" => ("HTTP/1.1 200 OK", "src/hello.html"),
        "GET /sleep HTTP/1.1" => {
            thread::sleep(Duration::from_secs(5));
            ("HTTP/1.1 200 OK", "src/hello.html")
        }
        _ => ("HTTP/1.1 404 NOT FOUND", "src/404.html"),
    };

    let contents = fs::read_to_string(filename).unwrap();
    let length = contents.len();

    let response =
        format!("{status_line}\r\nContent-Length: {length}\r\n\r\n{contents}");

    stream.write_all(response.as_bytes()).unwrap();
}
```

```rust
// src/lib.rs
use std::{
  sync::{mpsc, Arc, Mutex},
  thread,
};

pub struct ThreadPool {
  workers: Vec<Worker>,
  sender: mpsc::Sender<Job>,
}

type Job = Box<dyn FnOnce() + Send + 'static>;

impl ThreadPool {
  pub fn new(size: usize) -> ThreadPool {
      assert!(size > 0);

      let (sender, receiver) = mpsc::channel();

      let receiver = Arc::new(Mutex::new(receiver));

      let mut workers = Vec::with_capacity(size);

      for id in 0..size {
          workers.push(Worker::new(id, Arc::clone(&receiver)));
      }

      ThreadPool { workers, sender }
  }

  pub fn execute<F>(&self, f: F)
  where
      F: FnOnce() + Send + 'static,
  {
      let job = Box::new(f);

      self.sender.send(job).unwrap();
  }
}

struct Worker {
  id: usize,
  thread: thread::JoinHandle<()>,
}


impl Worker {
  fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
      let thread = thread::spawn(move || loop {
          let job = receiver.lock().unwrap().recv().unwrap();

          println!("Worker {id} got a job; executing.");

          job();
      });

      Worker { id, thread }
  }
}
```

- `id`와 `JoinHandle<()>` 필드를 갖는 구조체를 정의해야 한다.
  - `thread::spawn` 함수가 JoinHandle<T>를 반환하기 때문이다.
  - 스레드 풀에 작업을 전달하는 클로저는 아무것도 반환하지 않으므로 T가 ()가 된다.
- `ThreadPool`은 `Worker` 인스턴스의 벡터를 가져야 한다.
- id와 빈 클로저로 생성된 스레드를 갖는 Worker 인스턴스를 반환하는 `Worker::new` 함수를 정의해야 한다.
- `ThreadPool::new`에서 worker 값들을 벡터에 저장해야 한다.
