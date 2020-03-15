---
title: "Scroll restoration"
date: "2020-02-23"
tags: ["javascript"]
draft: false
---

재미있는 현상을 발견했다. 스크롤을 내리다가 특정 페이지로 이동 후, 다시 전 페이지로 이동(뒤로가기)하면 스크롤 위치를 기억하지 못하는 것이다. 왜 이럴까 한번 파보았다.

<hr />

## history.scrollRestoration

SPA를 하면서 발견한 현상이어서 SPA에서만 발생하는 문제일까 싶어서 `scroll restore in spa` 등으로 검색해서 좀 찾아보니 이런 속성이 있었다. history 객체에는 브라우저 안에서 사용자가 방문한 URL들이 기록된다. window 객체 내부에 들어있기 때문에 window안에서 접근할 수 있다. 이러한 history API의 action으로는 아래의 세 가지가 있다.

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

#### **without asynchronous task**

가장 의심스러웠던 건 화면이 그려질 때 데이터를 비동기로 호출한 후에 렌더링시키므로, 데이터가 불러와서 렌더링을 할 때에는 그 데이터가 그려질 엘리먼트 부분이 비어있을 것이라는 점이었다. 즉, history API의 스크롤 이벤트가 발생하여 스크롤을 위치시는 타이밍이 `데이터 호출 완료 -> 렌더링 진행 -> 렌더링 완료`의 절차의 중간 어디쯤에서 이루어져 해당 엘리먼트의 높이값이 0이거나 없는 상태에서 계산한다고 추측했다.

이를 CRA로 이루어진 SPA 프로젝트에서 간단하게 테스트해보았다. 먼저 아무런 비동기 처리가 없는, 데이터를 그대로 마크업하어 렌더링하는 컴포넌트로 이루어진 페이지는 스크롤 위치를 잘 기억했다.

<br />

![scroll-o](/blog/images/scroll-o.gif)

<br />

#### **with asynchronous**

그런데 실제로 프로젝트를 할 때에는 아마 마크업 부분을 이런 식으로 비동기로 받아와서 처리하는 부분이 많다. 데이터를 받아와서, 데이터가 존재하면 뭔가 레이아웃을 그리는 형태이다. 이렇게 되면 앞서 말했듯이 데이터를 호출한 후에 렌더링을 진행할 때에는 해당 엘리먼트의 높이가 없기 때문에 높이값이 고정되어 있지 않는 한, 기억하고 있던 스크롤을 정확한 곳에 위치시키지 못한다. 나는 `setTimeout`을 걸어서 데이터가 0.5초 후 들어가도록 처리해서 테스트해봤다.

```jsx
const [list, setList] = useState([]);

useEffect(() => {
  (async () => {
    setList(await getListApi());
  })();
}, []);

<div className="list">{list.length && <>...</>}</div>;
```

![scroll-x](/blog/images/scroll-x.gif)

<br />

혹시 몰라서 바깥 컨테이너 역할의 엘리먼트에 `min-height`와 `height`를 100%로 지정해봤는데, 해당 속성은 해당 브라우저 문서의 보이는 부분 높이값에 해당하므로 밑에 동적으로 늘어나는 높이값을 포함하진 못했다. 그래서 스크롤이 되게 애매한 위치로 기억되는 것을 확인했다. 아마 문서의 높이값 100%에 따른 계산에서의 스크롤 위치인듯 싶다.

<br />

## Hmm...

이게 좋은 방법인지는 모르겠는데, 우선 내가 다루는 프로젝트 구조에서는 동적인 리스트 부분에 `min-height`값을 크게 지정해주고, 렌더링이 모두 끝난 시점에는 해당 엘리먼트의 `clientHeight`값으로 덮어주는 잔머리 굴린 방식을 생각했다. 이러면 SPA에서 아무리 재렌더링이 일어나도 최소 높이값이 지정되어 있기 때문에 스크롤 위치를 항상 정확히 기억한다.

처음부터 해당 영역에 맞게 스크롤을 기억하도록 하고 싶은데, 뭔가 스크립트단이 아니라 HTML이나 CSS로 해결할 수도 있지 않을까? 좀더 파봐야겠다. 구글링하다보니 이런 stackoverflow 질문을 발견했는데 이 질문이 제일 내 궁금증이랑 비슷하다. [how-do-people-handle-scroll-restoration](https://stackoverflow.com/questions/44970279/how-do-people-handle-scroll-restoration-with-react-router-v4) 하지만 명쾌한 답변은 없다.

또 재미있는 부분은 컴포넌트로 진입했을 때 재렌더링이 좀 여러번 일어나는 페이지가 유독 이런 이슈가 있다는 점이다. 조만간 좀더 디버깅해보고 명확한 해답을 알고 싶다!
