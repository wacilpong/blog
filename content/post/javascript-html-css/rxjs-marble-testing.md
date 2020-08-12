---
title: "Rxjs marble testing with jasmine-marbles"
date: "2020-08-09"
tags: ["javascript/html/css"]
description: "About rxjs marble testing"
og_description: "About rxjs marble testing"
draft: false
---

## What is marble diagram?
![marble-merge](https://rxjs-dev.firebaseapp.com/assets/images/marble-diagrams/merge.png)

마블 다이어그램은 위 사진처럼 일련의 시간 흐름에서 발생(emit)되는 값을 조각으로 명시하는 것이다. 어떠한 sequence 중에서 일정 부분을 포착해놓은 것이라고 할 수 있다. 위 예시는 두 흐름 시퀀스를 merge operator를 통해 합친 것이다. 그래서 테스트하기가 까다로울 수 있는데, 이를 일련의 규칙을 통해 테스트하는 것이 marble testing이다.

이때 흘러가는 각각의 프레임은 10ms로 본다. 예를 들어, `---o|`라는 콜드 옵저버블은 30ms 후에 o라는 값을 방출하고 종료한다.

<br />

## Marble Syntax
- `-` : Time, 각각을 프레임이라고 부르며 10ms를 의미한다.
- `|` : 옵저버블이 성공적으로 완료되었음을 의미한다.
- `#` : 옵저버블이 종료되며 에러를 일으켰음을 의미한다.
- `^` : 핫 옵저버블의 구독 시점을 의미한다.
- `!` : 구독을 해제한 시점을 의미한다.
- `a` : producer에 의해 방출되는 어떠한 값, a가 아니라 다른 문자여도 된다.
- `()` : 여러 값들이 한번에 방출될 때를 의미한다. ex) '--(abc)-|' → a,b,c가 한번에 방출된다.

<br />

## Example
(1) source 옵저버블이 일어날 때마다 startWith로 최초 시작한 후 항상 'done'이라는 값을 방출하는 옵저버블 테스트

```ts
const source$ = cold('-a-b-|');
const expected$ = cold('ab-c-|', {a: 'done', b: 'done', c: 'done'});
const result$ = source$.pipe(
  startWith({}),
  switchMap(() => of('done'))
);

expect(result$).toBeObservable(expected$);
```

<br />

(2) hot 옵저버블에 대한 기본적인 테스트 (구독한 후 a를 방출하고 10ms 후에 종료)
```ts
const source = hot('-^a-|', { a: 5 });
const expected = cold('-a-|', { a: 5 });

expect(source).toBeObservable(expected);
```