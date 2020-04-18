---
title: "Shadow DOM vs Virtual DOM"
date: "2018-11-09"
tags: ["html"]
draft: false
og_description: "DOM(Document Object Model), is literally a structured model by objects."
---

## DOM, Die Or March ?

### :P

`DOM(Document Object Model)`, is literally a structured model by objects. In other words, DOM represents the web-page (documents) by object-oriented. Web browsers handle the DOM, and we can interact with it using Javascript and CSS. BUT, when we manipulate the DOM, it takes long bcuz of the rendering calculation (`reflow` and `repaint`).

<br />

DOM은 말 그대로 오브젝트들로 구성된 모델이다. 달리 말하면, DOM은 웹페이지에 대한 객체지향적 표현이다. 웹 브라우저가 이 DOM을 조작하고, 우리는 Javascript와 CSS를 이용해 통신(조작)할 수 있다. 그런데 DOM을 조작할 때 `reflow`와 `repaint`에 대한 렌더링 계산 때문에 속도가 늦어진다.

<br />

#### 1. reflow

- it triggerd when calculate the node size of `Render Tree`.
- it triggerd once at least at the beggining of the webpage.

#### 2. repaint

- it triggerd when update the DOM.

#### 3. What triggers those ?

- Adding, Removing and Updating DOM node.
- Moving and animating the DOM node on the page.
- `display:none, visibility:hidden`
- User action like scrolling and resizing the window.

<br />

So, We need to reduce DOM manipulation.
<br />

그래서 위와 같은 이유로 DOM 조작 자체를 최소화해야 한다.
<br />

<hr>

## Virtual DOM

This is one of the way to avoid the unnecessary DOM manipulation. It avoids re-rendering page, and represents UI that is kept in memory and synced with the REAL DOM. It is a concept implemented by libraries in JavaScript on top of browser APIs. such as `ReactJs` and `VueJs`. In react, the virtual DOM called `React DOM`.
<br />

이는 불필요한 DOM 조작을 피하기 위한 방법 중의 하나이다. 페이지를 다시 렌더링하는 것을 피하고, UI 자체를 표현하여 메모리 상에 저장되고 실제 DOM과 동기화한다. 이는 리액트나 뷰와 같은 브라우저 API들에 기반하여 자바스크립트로 구현된 컨셉이다. 참고로 리액트에서는 이러한 가상 DOM을 `React DOM`이라고 부른다.
<br />

**_Then, How about Angular2+ ?_**

- `Angular2+` manipulates DOM directly, but it has `ChangeDetectionRef`, is the base class of angular view.
- it is a tree collects all views that are to be checked for changes.
- So we can also reduce the DOM manipulation.

<br />

## Shadow DOM

This is a browser technology designed primarily for scoping variables and CSS in web components. and is mostly about encapsulation of the implementation. It refers to the ability of the browser to include a subtree of DOM elements into the rendering of a document, but not into the main document DOM tree.

<br />

이는 웹 컴포넌트들에서 변수들과 CSS의 범위를 지정하기 위해 설계된 브라우저 기술이다. 주로 캡슐화를 위해 사용된다. DOM 엘리먼트들의 서브 트리를 렌더링 영역에 포함시키지만, 메인 DOM 트리에는 포함시키지 않는 브라우저의 한 스킬이다.

<br />

[Ref: Using Shadow DOM (Javascript)](https://developer.mozilla.org/ko/docs/Web/Web_Components/Using_shadow_DOM)
