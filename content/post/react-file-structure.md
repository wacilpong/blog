---
title: "file structure with React"
date: 2019-07-10
tags: ["web-development", "react", "file-structure", "javascript"]
draft: false
---

## Why I am considering it

`앵귤러 5+`로 프로젝트를 진행하다가 리액트를 쓰게 되었는데, 앵귤러는 처음 1.x버전부터 본인을 `MVW(Model-View-Whatever)`와 같은 패턴을 지원하는 `Declarative Template`이라고 지칭한다. 그리고 `angular-cli` 커맨드를 사용하게 되면, 컴포넌트 1개당 관련 .css/.ts/.test.js/.html 파일들이 폴더로 생성되는 구조이다. 따라서 비교적 폴더구조에 대해서는 크게 고민하지 않았는데, 리액트를 해보니 굉장히 자유도가 높았고 폴더 구조도 쓰는 사람마다 천차만별이었다. 그러다보니 이에 대해 자연스럽게 고민하고 찾아봤다.

I was dealing with angular framwork that calls `Declarative Template` itself, supports the patterns like `MVW(Model-View-Whatever)`, and I recently start to managing react project. Moreover `angular-cli` command generates .css/.ts/.test.js/.html files to each components. So I didn't considering about directory structure deeply, but now I move to react and it much more depends on programmer.

## What React says about it ?

기본적으로 리액트는 다음과 같이 말한다.

> React doesn’t have opinions on how you put files into folders. That said there are a few common approaches popular in the ecosystem you may want to consider: Grouping by features or routes, Grouping by file type.

일단 리액트는 파일을 어떻게 나열하고 구조를 잡는지에 대해 딱히 정석이 없다. 다만 고려할만한 아주 일반적인 예시를 들어주는데, 기능 혹은 라우트에 따라 한 폴더에 `js, html, css`를 모두 두는 것, 그리고 컴포넌트나 API와 같은 비슷한 파일타입별로 폴더를 만들어 두는 방법이 있다. 이렇게 일반적인 얘기를 친절히 해주며 리액트는 한마디 덧붙인다. Don’t overthink it!

Well, there is not a perfect guide for file structuring in react ecosystem. But, very general examples here: grouping all `js, html, css` by features or routes, or, grouping by file type such as components and API.

## What I am using and will considering to use ?

우선 이번에 이직한 회사는 다음과 같은 구조를 갖고 있었다.

I moved to another company, and they structured like this:

```
src/
  api/
  actions/
  reducers/
  services/
  utils/
  typings/
  components/
  styles/
  assets/
```

회사에서 `typescript`를 도입해 사용하고 있었기 때문에 typings 폴더에서 해당 프로젝트에서 사용되는 인터페이스를 만들어 쓰고 있다. ts를 쓰고 있다는 점은 마음에 들었지만, 컴포넌트 폴더에 `js`파일만 두고 `(s)css`파일을 모두 따로 뺀 것이 마음에 들지는 않았다. 일반적인 방식에 의해도 확장자가 같다고 한번에 모아두는 것이 좋지는 않은 것 같다고 느꼈다. 그래서 차츰차츰 아래와 같은 구조를 만들어보려고 하고 있다.

It using `typescript`, so managing all types about the interfaces in this project in typings folder. I pretty happy that they using ts, but it isn't that about all `js` files in components folder and all `(s)css` files in styles folder. I think It looks complicated, why all files set aside in same folder even if it has same file extension ? So, I gradually make this structure like this:

```
src/
  api/
  actions/
  modules/
  services/
  view-model-creator/
  utils/
  typings/
  components/
    atoms/
      ButtomComponent/
        .ts
        .css
    molecules/
    organisms/
    pages/
      TestPageComponent/
        .ts
        .css
  assets/
    _exampleReset.css
    _exampleBase.css
    img/
```

1. 우선 함께 일하는 동료의 제안으로 `view-model-creator`라는 녀석을 두게 되었는데, 컴포넌트 내에서 데이터를 파싱해 보여주기 보다는, 뷰모델을 만들어서 미리 파싱된 데이터를 컴포넌트에서 쓰기 위해 만들었다.
   <br>
   My coworker suggest `view-model-creator`. Instead of parsing and displaying data in a component, we created pre-parsed data for using it in a component.

2. 그리고 [아토믹 디자인(atomic design)](http://bradfrost.com/blog/post/atomic-web-design/)을 적용해 컴포넌트를 나누기로 했다. 이를 통해 공통 단위의 컴포넌트들에 대한 재사용성이 좀 더 강화되었으면 좋겠다.
   <br>
   We devide the components units by atomic design rule. I expect the small unit component will be more reusable.

3. 리덕스 상태에 대한 관리 뿐만 아니라 인증이나 UI 조작 등, 전역으로 조작되어야 하는 것들에 대한 관리를 포함한다는 의미에서 리듀서가 아닌 모듈이라는 이름을 채택했다.
   <br>
   We choose `modules`, not a `reducers`, in regards to not only the redux state managing, but also the managing global state and functions like UI or authentication.

4. 외부 API에 대한 통신 (후에는 내부 API 통신까지도)을 담당하는 의미에서 서비스를 두었다.
   <br>
   `Service` managing API communication.

## Umm

리액트가 정확한 가이드를 내려주지 않으니 어려운 점도 있지만, 개발자 각자만의 구조를 만들어간다는 점이 좋은 것 같..지만 매우 혼돈의 카오스적인 아이임은 분명하다.
