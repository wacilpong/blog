---
title: "My recently junior web developer interview"
date: 2017-12-11
tags: ["web-development", "interview"]
draft: false
---

## what kind of companies?
힙한 분위기를 느끼고 싶어서 스타트업만 건드렸다. 블록체인, 핀테크, 클라우드IDE, AI 등등 다양한 분야의 회사에 신입 개발자로 지원했다. 프론트엔드/백엔드 가릴 것 없이 넣었고, 주로 nodeJs 기반의 회사로 넣었다. 12월 4일부터 12월 8일까지 일주일 간 인터뷰만 보러 다녔다.

I apply to 7 different startups that developing web like blockchain, fintech, cloud IDE, traslating AI, medical AI. The most of them are based on nodeJs. I was an interviewee during 2017. 12. 04 ~ 2017. 12. 08.

## what questions I've got?
1. 스레드 vs 프로세스 Thread vs Process
2. 자바스크립트 호이스팅 Javascript Hoisting
3. 자바스크립트 클로저 Javascript Closure
4. 디자인 패턴 설명 Explain about design pattern
5. node.js가 동작하는 내부원리 The inner logic of node.js
6. URI를 쳤을 때 웹브라우저에서는 어떤 일들이? What happens when I type the URI in the web browser?
7. 관계형 DB 아키텍처 그려보기 Design RDBMS architecture
8. 주로 이용하는 웹사이트 개선사항 말해보기 Tell a plan for improving the one of website
9. NoSql 동작원리와 확장성 설명하기 Explain the mechanism and the scalability of NoSql
10. 객체지향 vs 함수형 패러다임 Objective oriented vs functional paradigm
11. 로컬, 세션, 쿠키영역에 대해 각각 설명 Explain each of these local, session, cookies field
12. API server를 사용하는 이유? Why using API server, not a socket network? even with API is slower!
13. RESTful에 대해 설명 Explain RESTful
14. Coding test - string to integer, find the missing number, DP(Collatz, BFS)
15. Html vs Xhtml
16. Css flex

## Let's solve those questions!
### Thread vs Process
: 먼저, 어플리케이션, 프로세스, 스레드 간의 관계를 알 필요가 있다.<br>
First of all, we must know the relationship among the application, process and thread.

![program](http://2.bp.blogspot.com/-iztLs3xTqWU/Wi4sBc3soxI/AAAAAAAABy8/GtHdXcPMizwow61EPnRnkucGj-qzv7QZwCK4BGAYYCw/s1600/processvsthread.png)

(1) ***Process*** 는 단일스레드와 시작되며, 이를 primary 스레드라고도 한다. 그리고 추후 스레드를 더 생성할 수 있다. 프로세스는 이처럼 적어도 하나의 스레드가 반드시 필요하다.

Process starts with a single thread(`primary thread`), and can create more later. So process has at least one thread.

(2) ***Thread*** 는 computer system에서 프로세서가 시간을 할당하는 최소 실행 단위이다. 이는 다음 실행될 명령어 주소를 가진 프로그램 카운터, 중앙처리장치(CPU)에 빠르게 접근할 수 있는 레지스터들, 고유한 ID를 가진다. 하지만 스레드는 그 자체만으로 프로그램이 아니고, 프로그램 안에서 동작할 수 있다. 모든 스레드는 각자의 메모리를 가지며 시스템 자원에도 접근할 수 있다.

Thread is the smallest unit of execution to which processor allocates time. It consists `program counter, a stack, set of registers`, id. But thread itself is not a program. it can runs within a program. All threads can access to their own memory and system resources.


### Javascript Hoisting
: 자바스크립트는 초기화가 아니라 선언만 상단부로 끌어올려 컨텍스트에 적용한다. 즉, 물리적으로 작성한 코드가 스코프 상단으로 옮겨지는 것은 아니다. 어떠한 선언은 컴파일 단계에서 메모리에 저장되지만, 코드에서 입력한 위치에 그대로 있다. 이러한 개념을 호이스팅이라고 한다.

Javascript only hoists declarations, not initializations. It's not physically moved to the top of code. This is a term, hoisting.

```
// It gives no error
n = 1;
n + 1;
let n;

// 'b' is undefined in log
let a = 1, b;
console.log(a + " " + b);
b = 2;
```
