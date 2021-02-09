---
title: "2021"
description: "About what I learned by year"
og_description: "About what I learned by year"
draft: false
---

## **2021-02-09**

- [sapper](https://sapper.svelte.dev/)는 svelte로 구동시키는 웹앱 프레임워크다. 아래의 구조로 이루어진다. routes연결부분이 rails랑 비슷하다는 생각이 들었다.

  ```txt
  src
      client.js
      server.js
      service-worker.js
      template.html
  src/routes
      ...
  static
  ```

  - template.html에 `%sapper.head%`와 같은 태그를 명시하여 서버에서 받은 응답을 처리할 수 있다. 동적으로 메타를 바꿔야 하므로 SSR 필수요소.
  - src/routes에 svelte컴포넌트를 넣으면 해당 컴포넌트 자체가 하나의 라우트 엔트리가 된다.
  - static은 리액트와 마찬가지로 static 리소스들을 몰아 넣는 곳.

<br />

- 프로젝트에 절대경로를 사용하고 싶으면 webpack, rollup같은 번들러에 alias 관련 플러그인을 설정하면 잘 되는데, 에디터에 빨간 줄이 나와도 당황하지 말자. jsconfig 혹은 tsconfig에 `paths`를 명시해서 에디터가 알 수 있도록 해주자.
  ```txt
  "compilerOptions": {
      ...
      "baseUrl": "./",
      "paths": {
        "@/*": ["src/*"]
      }
  }
  ```
