---
title: "Prerender Status Code"
date: "2019-10-06"
tags: ["configuration"]
draft: false
og_description: "재직중인 회사에서 헤드리스 브라우저(headless browser)를 이용한 SEO를 다뤄보면서 여러 시행착오를 겪었다."
---

재직중인 회사에서 헤드리스 브라우저(headless browser)를 이용한 SEO를 다뤄보면서 여러 시행착오를 겪었다. SSR(Server Side Rendering)을 도입할 수 없는 상황이었기 때문에 CSR(Client Side Rendering)로 잘 핸들링해야 했다. 회사에서 [**netlify**](https://www.netlify.com/)라는 static deploy 서비스를 사용중이었는데, 유료회원이면 prerender라는 내장된 서비스를 옵션으로 사용할 수 있었다. [**prerender**](https://prerender.io/)는 헤드리스 브라우저를 통해 페이지의 정적 정보들을 저장해놓고, 크롤러가 해당 정보들을 긁어갈 수 있도록 해주는 SEO를 돕는 일종의 기술이다. netlify는 이를 내장시켜서 사용할 수 있도록 만든 것이다.

<br />

## Headless browser ?

그러면 먼저 헤드리스 브라우저가 무엇인지 알아야 하는데, 쉽게 말하면 아무 UI도 없는 웹브라우저다. 즉, CLI(Command Line Interface)을 통해서만 네트워킹될 수 있는 웹브라우저다. 하지만 브라우저와 똑같이 js, css, HTML을 인식하고 렌더링할 수 있기 때문에 웹사이트 데이터를 스크랩하거나 테스트로 사용될 수 있다. 근데 머리없는 브라우저라니 이름 약간 무서운데 나만 그렇게 느끼나...? 마치 `목 없는 기사` 이런 느낌.

<br />

## Prerendering ?

[ref: netlify prerender](https://www.netlify.com/blog/2016/11/22/prerendering-explained/)

> Prerendering is a process to preload all elements on the page in preparation for a web crawler to see it. A prerender service will intercept a page request to see if the user-agent viewing your site is a bot and if the user-agent is a bot, the prerender middleware will send a cached version of you site to show with all JavaScript, Images, etc are rendered statically. If the user-agent is anything but a bot, then everything is loaded as normal, prerendering is only used to optimize the experience for bots only.

## so, what is Prerender Status Code ?

어쨌든 프리렌더를 사용하면 봇은 각 페이지의 meta태그를 바라보고 크롤링하게 되는데, 프리렌더봇이 자꾸 `404 Not Found` 페이지를 긁어가서 이를 막아야할 일이 생겼다. 이때 메타에 아래처럼 써두면 봇이 404로 인식해 크롤링하지 않게 된다.

<br />

```html
<meta name="prerender-status-code" content="404" />
```

관련 내용이 있는 [prerender document best practice](https://prerender.io/documentation/best-practices)를 읽었을 때, 막연하게 해당 태그를 최상단 루트에 달아놓으면 404인 페이지는 알아서 긁어가지 않겠거니 안일하게 생각했는데 역시 아니었다. 루트(index.html)에 해당 태그를 달아놓으니 구글봇 기반의 모든 봇들이 아예 해당 웹사이트를 크롤링하지 않는 문제가 생겼다. 그래서 반대로 404로 리턴해야하는 경우를 미리 알 수 있는 경우에만 해당 태그를 사용하면 된다.

<br />

#### _NOTE: react-helmet_

나는 리액트로 만든 SPA(Single Page Applicatio)를 다루고 있었기 때문에, 각 페이지에서 메타정보를 바꿀 수 있는 `react-helmet`을 함께 사용했다. 그런데 아쉽게도 결국 `title`과 같은 메타정보들을 바꾸려면 모든 페이지에 각각 작성해야 해서 생각보다 크고 노가다 작업이라 아직 반영하지 못했다. 아래처럼 `Meta`와 같은 일종의 wrapper를 만들어서 라우팅되는 각 페이지 상단에 삽입하면 될 것 같다.

<br />

```javascript
const Meta = ({ title, description }) => (
  <Helmet
    title={title}
    titleTemplate={`%s | ${title}`}
    meta={[
      {
        name: "description",
        content: description
      },
      {
        property: "og:title",
        content: title
      },
      {
        property: "og:description",
        content: description
      },
      {
        property: "og:type",
        content: "website"
      }
    ]}
  />
);
```

<br />

이런 식으로 모든 페이지에 SEO 작업을 해두면 `prerender-status-code`도 활용할 수 있을 것 같다.
