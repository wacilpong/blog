---
title: "2024"
date: "2024-01-01"
description: "About what I learned at 2024"
og_description: "About what I learned at 2024"
draft: false
---

## **2024-08-06**

- 샌드박스 환경에서만 실제로 수정하지 않은 요소의 css가 깨지는 현상이 발생했다.
- 젠킨스 workspace가 꼬였을지도 모르니 모두 지우고 다시 빌드해봤지만 여전히 발생했다.
- 깨지는 css 내용을 각 phase마다 비교해보았지만 똑같았다.
- 빌드된 css가 제대로 매핑되어 있는지 `<head>`태그를 확인한 순간,
  - `!DOCTYPE` 위에 `<script>` 태그가 있는 것을 발견했다.
  - (서버에서 페이지 html문서를 서빙해줄 때 태그를 바깥에 그려서 주고 있었음)

### (1) `<!DOCTYPE html>`은 어디까지 영향을 주는 것인가?

```
A DOCTYPE is a required preamble.

DOCTYPE은 필수 (맨앞)서문이다.
```

```
DOCTYPEs are required for legacy reasons. When omitted, browsers tend to use a different rendering mode that is incompatible with some specifications. Including the DOCTYPE in a document ensures that the browser makes a best-effort attempt at following the relevant specifications.

DOCTYPE은 기존 호환성 이유로 인해 필요하다. **이걸 생략하면 브라우저는 일부 사양과 호환되지 않은 다른 렌더링 모드를 사용할 수도 있다. DOCTYPE을 선언해야만 브라우저가 관련 사양을 따르기 위해 최적의 방식으로 동작한다.
```

by [HTML공식 스펙문서](https://html.spec.whatwg.org/multipage/syntax.html#the-doctype)

즉, 이를 선언하지 않거나 html문서 맨 앞에 쓰지 않으면 문서 전체 렌더링에 영향을 준다!!!

### (2) 렌더링 모드란?

```
DOCTYPE은 브라우저가 문서를 렌더링 할 때 [quirks mode](https://developer.mozilla.org/en-US/docs/Web/HTML/Quirks_Mode_and_Standards_Mode)로 바뀌지 않도록하는 것이 유일한 목적입니다.
```

by [MDN문서](https://developer.mozilla.org/ko/docs/Glossary/Doctype)

- **Standard mode**
  - W3C 표준에 따라 렌더링
  - **DOCTYPE을 선언하면 이 모드로 실행됨**
  - 브라우저가 출력하려는 하는 문서가 최신이라고 판단하면 이 모드로 렌더링
- **Quirks mode**
  - 오래된 브라우저의 행동을 모방하여 렌더링
  - 브라우저가 출력하려는 하는 문서가 예전 문서라고 판단하면 이 모드로 렌더링
  - 오래된 웹 페이지들이 최신 버전 브라우저에서 깨져 보이지 않으려는 것이 목적인 모드
- **Almost Standard mode**
  - table cell에서 Quirks mode로 실행하는 것 외에는 Standard mode와 동일
  - ex) 사파리, 오페라, Gecko 기반의 모든 브라우저 (Firefox 1.0.1 + IE8)

### (3) 어떤 모드로 렌더링되었는지 어떻게 알 수 있을까?

- `document.compatMode`
- 위 값이 `BackCompat`라면 쿼크모드이고, 그 외에는 `CSS1Compat` 이다.

<br />
<hr />

## **2024-07-03**

- providers 배열에 useClass를 사용하여 서비스를 토큰으로 등록한 경우?

  - 해당 서비스를 컴포넌트로 주입(DI)할 때는 등록한 토큰 이름으로 가져와야 한다.
  - `APP_TOKEN`으로 `ServiceA`를 provider로 등록했다면, `inject(APP_TOKEN)`으로 주입해야 한다.

  ```ts
  import {NgModule} from "@angular/core";

  @NgModule({
    providers: [{provide: APP_TOKEN, useClass: ServiceA}],
  })
  export class AppModule {}
  ```

  ```ts
  import {Component, Inject} from "@angular/core";

  @Component({
    selector: "app-root",
    template: `Value: {{ value }}`,
  })
  export class AppComponent {
    value: string;

    constructor(@Inject(APP_TOKEN) private myService: ServiceA) {
      this.value = this.myService.getValue();
    }
  }
  ```

<br />
<hr />

## **2024-03-15**

- Not Allowed Attribute Filtered 이슈를 만났다!
  - a태그에 특정 링크를 걸어 서버를 한번 거쳐 저장을 한 후 프론트에서 노출하고 있었다.
  - 그런데 막상 프론트에 노출된 화면을 보니 태그에 링크가 걸려 있지 않고, a태그 위에 아래 문구가 주석으로 있었다.
    `Not Allowed Attribute Filtered`
  - 서버에서 html을 저장하는 과정에서 xss 방어를 위한 라이브러리를 사용중이었는데, 거기서 막고 있는 경우였다.
  - 걸어놓은 링크에 _script_ 라는 단어가 포함되어 있었다... (정확히는 _description_ 이었음)
  - 그래서 파악한 원인을 서버와 논의하여 해결할 수 있었다. 굿.

<br />
<hr />

## **2024-02-27**

- position: relative > position: absolute에 right:0도 없는데 맨 뒤에 붙는다면?
  ```html
  <ul style="position: relative;">
    <li style="display: inline-block;"></li>
    <li style="display: inline-block;"></li>
    <li style="position: absolute;"></li>
  </ul>
  ```
  - 위 구조를 봤을 때, 맨 마지막 li에 따로 `right: 0` 스타일을 주지 않았으므로 ul 아래 맨 왼쪽에 붙을 줄 알았다.
  - 그러나 현실은 각 li들을 지나서 맨 오른쪽에 붙었다.
  - `position: absolute`로 설정한 요소는 위치를 결정하기 위해 상위 요소 중에서 `position: relative`, `position: absolute`, `position: fixed` 중 하나를 기준으로 삼는다.
  - 위 상황에서 마지막 외의 다른 li 요소들에는 명시적으로 position 속성을 주지 않았으므로, 주어지지 않았으므로, 기본적으로 문서 흐름에 따라 배치되는 static 위치를 갖는다. 그래서 마지막 li 요소가 `position: absolute`로 설정되어 있어도 다른 요소들과 겹치지 않게 하지 않는다.
  - 참고로 `display: inline-block`으로 설정된 요소는 기본적으로 텍스트 흐름에 따라 배치된다.
  - 따라서 마지막을 제외한 li들이 static이면서 좌-우, 위-아래로 흐름에 따라 배치되므로 마지막 li는 오른쪽 끝에 붙는다.
