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
