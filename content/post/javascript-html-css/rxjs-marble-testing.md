---
title: "Rxjs marble testing with jasmine-marbles"
date: "2020-08-09"
tags: ["javascript/html/css"]
description: "About rxjs marble testing"
og_description: "About rxjs marble testing"
draft: false
---

## What is marble diagram?

![marble-merge](https://user-images.githubusercontent.com/27843313/89752134-136a9a80-db0e-11ea-9f29-b3a5a9326585.png)

마블 다이어그램은 위 사진처럼 일련의 시간 흐름에서 발생(emit)되는 값을 조각으로 명시하는 것이다. 어떠한 sequence 중에서 일정 부분을 포착해놓은 것이라고 할 수 있다. 위 예시는 두 흐름 시퀀스를 merge operator를 통해 합친 것이다. 그래서 테스트하기가 까다로울 수 있는데, 이를 일련의 규칙을 통해 테스트하는 것이 marble testing이다.

이때 흘러가는 각각의 프레임은 10ms로 본다. 예를 들어, `---o|`라는 콜드 옵저버블은 30ms 후에 o라는 값을 방출하고 종료한다.

<br />

## Marble Syntax

1. `-`: Tiem, each frame represents 10ms of time
2. `|`: The successful completion of an observable
3. `#`: An error terminating the observable
4. `^`: Subscription point to the hot observable
5. `!`: Unsubscription point at which a subscription is unsubscribed
6. `a`: Any character value being emitted by the producer
7. `()`: Emit a single grouped value on same time frame.

<br />

## Example

(1) source 옵저버블이 일어날 때마다 startWith로 최초 시작한 후 항상 'done'이라는 값을 방출하는 옵저버블 테스트

```ts
const source$ = cold("-a-b-|");
const expected$ = cold("ab-c-|", {a: "done", b: "done", c: "done"});
const result$ = source$.pipe(
  startWith({}),
  switchMap(() => of("done"))
);

expect(result$).toBeObservable(expected$);
```

<br />

(2) hot 옵저버블에 대한 기본적인 테스트 (구독한 후 a를 방출하고 10ms 후에 종료)

```ts
const source = hot("-^a-|", {a: 5});
const expected = cold("-a-|", {a: 5});

expect(source).toBeObservable(expected);
```
