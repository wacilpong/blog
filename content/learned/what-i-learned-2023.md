---
title: "2023"
date: "2023-01-01"
description: "About what I learned at 2023"
og_description: "About what I learned at 2023"
draft: false
---

## **2023-04-05**

- web API의 `stopPropagation()` 메서드는 같은 이벤트일 때만 상위 요소로의 전파를 막는 메서드이다.
  - 어떤 요소의 click 이벤트에서 stopPropagation()을 호출했다고 해보자.
  - 그 요소의 부모 요소에 change와 같은 다른 이벤트가 걸려 있었다면, 그것은 호출된다.
  - 따라서 이런 경우에는 `preventDefault()`로 [사용자 에이전트](https://developer.mozilla.org/ko/docs/Glossary/User_agent)의 모든 기본동작을 막아야 한다.
