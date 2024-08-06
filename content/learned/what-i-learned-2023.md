---
title: "2023"
date: "2023-01-01"
description: "About what I learned at 2023"
og_description: "About what I learned at 2023"
draft: false
---

## **2023-05-14**

- js의 `exec()` 메서드는 주어진 문자열에서 일치하는지 여부를 배열 혹은 null로 반환해준다.

  - 이때 exec()에 플래그를 설정(/foo/g, /foo/y 등)하면 이전 일치의 인덱스를 저장하게 된다.
  - 문서에 따르면 아래와 같다.
    > Each call to `exec()` will update its lastIndex property, so that the next call to exec() will start at the next character.
  - 즉, exec()를 호출할 때마다 lastIndex 속성이 업데이트 된다.
  - 그러면 다음 exec()가 호출되면 다음 문자에서 시작되므로 주의해야 한다.
  - 더 이상 맞는 것을 찾지 못하면 null을 반환한다.
  - 아래처럼 null이 반환되고, 또 다시 호출하면 다시 처음부터 실행한다.

    ```js
    // 예시
    const str = "Helloworld!";
    const pattern = /([A-Za-z]+)|([ !])/g;

    // ["Helloworld", "Helloworld", undefined]
    pattern.exec(str);

    // null
    pattern.exec(str);
    ```

<br />
<hr />

## **2023-04-05**

- `하이드레이션(hydration)`
  - 리액트에서의 하이드레이션은 서버 측에서 생성한 HTML 페이지에 클라이언트 측에서 실행하는 js 코드를 추가해서 애플리케이션 상태를 관리하고 렌더링하는 기법이다.
  - 즉, 서버 측에서 HTML을 생성하고 js를 통해 클라이언트가 동적으로 렌더링할 수 있게 된다.
  - 서버 측에서 렌더링한 DOM과 클라이언트가 렌더링한 DOM이 한데 섞여 SPA처럼 보인다.
  - 이 점이 물과 물에 섞인 물질이 한데 어우러져 하나의 문자처럼 보이는 것과 비슷해 하이드레이션이라 불린다.

<br />
<hr />

## **2023-04-05**

- web API의 `stopPropagation()` 메서드는 같은 이벤트일 때만 상위 요소로의 전파를 막는 메서드이다.
  - 어떤 요소의 click 이벤트에서 stopPropagation()을 호출했다고 해보자.
  - 그 요소의 부모 요소에 change와 같은 다른 이벤트가 걸려 있었다면, 그것은 호출된다.
  - 따라서 이런 경우에는 `preventDefault()`로 [사용자 에이전트](https://developer.mozilla.org/ko/docs/Glossary/User_agent)의 모든 기본동작을 막아야 한다.
