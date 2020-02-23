---
title: "Scroll restoration"
date: "2020-02-23"
tags: ["javascript"]
draft: true
---

재미있는 현상을 발견했다. 스크롤을 내리다가 특정 페이지로 이동 후, 다시 전 페이지로 이동(뒤로가기)하면 스크롤 위치를 기억하지 못하는 것이다. 왜 이럴까 한번 파보았다.

<hr />

## history.scrollRestoration

좀 찾아보니 이런 속성이 있었다. history 객체에는 브라우저 안에서 사용자가 방문한 URL들이 기록된다. window 객체 내부에 들어있기 때문에 window안에서 접근할 수 있다. 이러한 history API의 action으로는 아래의 세 가지가 있다.

- [PUSH](https://developer.mozilla.org/ko/docs/Web/API/History/pushState) : 브라우저의 세션 기록 스택에 상태를 추가
- [POP](https://developer.mozilla.org/ko/docs/Web/API/Window/popstate_event) : 현재 활성화된 세션 기록 항목이 바뀔 때 발생
- [REPLACE](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState) : 현재 활성화된 세션 기록 항목을 유지하고 state 및 url path 등의 정보를 변경할 때 발생

<br />

[history-api-scroll-restoration 문서](https://developers.google.com/web/updates/2015/09/history-api-scroll-restoration)에 따르면 기본적으로 history API는 스크롤 위치를 함께 저장하여 사용자가 페이지를 방문할 때마다 복원시킨다. 그리고 이 스크롤 이벤트는 popstate가 이루어지기 전에 일어난다. 그런데 이러한 스크롤 위치를 저장시키지 않는 방법이 있는데, 아래처럼 직접 속성을 바꾸면 된다.

```javascript
if ("scrollRestoration" in history) {
  // Back off, browser, I got this...
  history.scrollRestoration = "manual";
}
```

<br />

하지만 내가 다루던 프로젝트는 리스트를 탐색하다가 특정 페이지를 누른 후, 다시 이전 페이지 리스트로 돌아가야 했기 때문에 기존 방식처럼 스크롤 위치를 기억해야 했다. 그래서 위 속성의 기본값이 `auto`이니, 다른 문제로 스크롤 위치를 잃는다고 판단했다.

<hr />

## List wrapper which has dynamic height
