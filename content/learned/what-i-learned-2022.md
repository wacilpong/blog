---
title: "2022"
date: "2022-01-01"
description: "About what I learned at 2022"
og_description: "About what I learned at 2022"
draft: false
---

## **2022-09-14**

- 분명 git이 설치되어 있는데도 vscode에서 `git(extension)`을 찾을 수 없다고 뜰 때?
  - 에디터에서 `cmd + ,`를 눌러 Settings으로 이동한다.
  - `git.path`를 검색해 `Edit in settings.json`로 진입한다.
  - git.path에 본인의 git 설치 경로를 적어준다.
  - `which git` 명령어를 통해 찾으며, 나는 `/usr/local/bin/git`였다.

<br />

## **2022-05-11**

- 라이브러리성 코드가 혼재된 코드를 디버깅할 때는 크롬 개발자도구 break point 디버깅을 잘 활용하자. 귀찮아도 꼭 하자. 때로는 멀리 가는 길처럼 보여도 소스코드 디버깅을 하는 것이 가장 빠른 길이다.

<br />

## **2022-01-11**

- 처음에 대충 보면 react hooks가 마치 상태관리 도구인 것처럼 느껴질 수 있지만, 전혀 아니다.
  - 상태관리 도구가 아니라 상태를 잘 정리할 수 있는 옵션들을 제공한다.
  - **react hooks는 로직을 재사용하기 위해 만들어진 리액트 모듈이다.**
  - `useState`, `useReducer`는 컴포넌트 상태를 관리하기 위한 방법일 뿐이다.
  - `useContext`는 기존 context api를 props drilling 없이 공유하게 해줄 뿐이다.
  - 즉, 컴포넌트 트리의 전역적인 상태를 관리하기 위한 도구는 아니다.
- react hooks를 쓰더라도 여전히 트리 내 전역상태를 관리할 필요는 있다.
  - context는 사용자 권한이나 언어 같은 '전역적'이라고 여겨질 만한 데이터를 컴포넌트 트리에서 공유할 수 있도록 설계되었다.
  - 자주 바뀌는 데이터가 아니며, context는 컴포넌트 재사용을 어렵게 만든다.
  - 따라서 자주 변경된다면 **redux와 같은 상태를 예측 가능하도록 돕는 도구**를 고려해야 한다.

<br />
<hr />

## **2022-01-06**

- [ts의 데코레이터(decorator)](https://www.typescriptlang.org/docs/handbook/decorators.html)는 처음에 앵귤러를 지원하기 위해 추가되었다.
  - 현재까지도 표준화가 되지 않았기 때문에 앵귤러를 쓰거나 어노테이션이 필요한 프레임워크가 아니라면 쓰지 않는 게 좋다.
  - 데코레이터는 아래처럼 클래스, 메서드, 프로퍼티에 어노테이션(annotation)을 붙이거나 기능을 추가하는 데 사용할 수 있다.
    ```ts
    class Greeter {
      greeting: string;
      constructor(message: string) {
        this.greeting = message;
      }
      @logged
      greet() {
        return "hi," + this.greeting;
      }
    }
    function logged(target: any, name: string, descriptor: PropertyDescriptor) {
      const fn = target[name];
      descriptor.value = function () {
        console.log(`Calling ${name}`);
        return fn.apply(this, arguments);
      };
    }
    console.log(new Greeter("Roomy").greet());
    // Calling greet
    // hi,roomy
    ```
- [데코레이터 쓰임새](https://www.geeksforgeeks.org/what-are-decorators-and-how-are-they-used-in-javascript/)
  - `Class member decorators`
    - 클래스의 메서드, 프로퍼티에 데코레이팅되며 3개의 인자를 지닌다.
    - target: 멤버가 속해있는 클래스 _ex. Greeter_
    - name: 멤버의 이름 _ex.greet_
    - descriptor: Object.defineProperty로 전달되는 멤버에 대한 description
  - Members of classes
    - 전체 클래스에 데코레이팅되며 생성자 함수에 적용된다.
    - 단일 매개변수(클래스의 생성자 함수)를 받는다.
