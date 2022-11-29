---
title: "2022"
date: "2022-01-01"
description: "About what I learned at 2022"
og_description: "About what I learned at 2022"
draft: false
---

## **2022-11-29**

- `[oh-my-zsh] To fix your permissions you can do so by disabling...`

  - 해당 디렉터리의 owner가 현재 user와 다른 경우 발생한다.
  - 계정이 2개일 수 있어서 그냥 에러 메시지를 무시해주기로 했다.

    ```sh
    $ vi ~/.zshrc

    # source 전에 해줘야 한다.
    ZSH_DISABLE_COMPFIX="true"

    source $ZSH/oh-my-zsh.sh
    ```

<br />

## **2022-11-05**

- `[oh-my-zsh] Insecure completion-dependent directories detected:...`

  - /usr/local 경로의 모든 파일에 대한 소유 권한을 초기화할 일이 있었다.
    ```sh
    $ sudo chown -R $(whoami):admin /usr/local/*\
    $ && sudo chmod -R g+rwx /usr/local/*
    ```
  - /usr/local은 개인 컴퓨터에서 지역적으로 생성되는 시스템 파일이다.
  - /usr/local/bin는 참고로 기본 프로그램이 아닌 경우 주로 설치되는 경로이다.
  - 그런데 /usr/local/share 경로까지 모두 초기화되어서 zsh 소유권 문제가 발생해버렸다. _앗 내 실수!_
  - 따라서 아래 명령어를 수행해 해결해주었다.

    ```sh
    $ compaudit

    There are insecure directories
    /usr/local/share/zsh/site-functions
    /usr/local/share/zsh

    $ chmod 755 /usr/local/share/zsh/site-functions
    $ chmod 755 /usr/local/share/zsh
    ```

- 리눅스 `/usr` 디렉토리 이해
  - 여기는 시스템이 아닌 사용자가 실행할 프로그램들이 저장된다.
  - `bin`: 일반적인 유틸리티나 프로그래밍 도구 및 대부분의 사용자 명령어가 위치함 _cd, python, curl..._
  - `lib`: 라이브러리들이 위치함 _cron_
  - `local`: 기본 os에서는 필요하지 않는 실행가능한 파일들과 라이브러리들이 위치 _homebrew_
  - `share`: 아키텍처에서 독립된 데이터 파일들이 위치함 _vim, zsh..._
  - `include`: C 프로그램에 포함되는 헤더파일들이 위치한다.

<br />

## **2022-10-26**

- 실제로 서빙되고 있는데도 `lsof -i :{port}`로 아무것도 뜨지 않을 때?
  - 80 기본포트로 도커 컨테이너를 서빙했다가 정지 및 삭제했는데 죽지 않아 강제로 kill하려고 했으나 pid가 뜨지 않았다.
  - `lsof -P | grep ':80'`로 포트 서비스명 대신 포트번호를 출력했더니 떴다.
  - `lsof -P | grep ':80' | awk '{print $2}'`까지 해주면 pid만 뽑을 수 있다.
  - `kill -9 {pid}`하면 된다.
  - 그래도 안뜬다면 브라우저 캐시를 다 날리거나 시크릿창에서 한번 해보자.

<br />

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
