---
title: "2021"
date: "2021-01-01"
description: "About what I learned at 2021"
og_description: "About what I learned at 2021"
draft: false
---

## **2021-12-13**

- [자바스크립트의 프로토타입에 관해 철학적으로 접근한 좋은 글](https://medium.com/@limsungmook/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8%EB%8A%94-%EC%99%9C-%ED%94%84%EB%A1%9C%ED%86%A0%ED%83%80%EC%9E%85%EC%9D%84-%EC%84%A0%ED%83%9D%ED%96%88%EC%9D%84%EA%B9%8C-997f985adb42)을 발견하여 정리해둔다. 아래는 결정적으로 유용한 부분 발췌!

> 프로토타입 기반 OOP 언어의 특징은 다음과 같습니다.
>
> - 개별 객체(instance) 수준에서 메소드와 변수를 추가
> - 객체 생성은 일반적으로 복사를 통해 이루어짐
> - 확장(extends)은 클래스가 아니라 위임(delegation)
> - 현재 객체가 메시지에 반응하지 못할 때 다른 객체로 메시지를 전달할 수 있게 하여 상속의 본질을 지원
> - 개별 객체 수준에서 객체를 수정하고 발전시키는 능력은 선험적 분류의 필요성을 줄이고 반복적인 프로그래밍 및 디자인 스타일을 장려
> - 프로토타입 프로그래밍은 일반적으로 분류하지 않고 유사성을 활용하도록 선택
> - 결과적으로 설계는 맥락에 의해 평가

> Javascript 에 익숙하다면 별다른 설명 없이도 이해되는 부분이 있을 것으로 보입니다.
> 다시 한번 가장 중요하다 생각되는 부분을 정리해보면
>
> - 프로토타입 언어에서는 ‘분류’를 우선하지 않는다. 생성된 객체 위주로 유사성을 정의한다.
> - 어휘, 쓰임새는 맥락(context)에 의해 평가된다.
>   - 실행 컨텍스트, 스코프 체인이 여기서 파생되었습니다
>   - 클로져, this, 호이스팅 등등. 이 모든 헬(?) 이 프로토타입의 ‘맥락’을 표현하기 위한 것입니다.

비트겐슈타인 글을 좋아했지만 이걸 자바스크립트에 연결시켜서 언어를 이해하려고 한 적은 없어서 정말 신선했고 좋았다. 큰 깨달음! 그리고 내가 좋아했던 비트겐슈타인의 전쟁일기 속 글귀도 몇개 다시 기록해본다.

- “나 외의 생명체가 하나도 없다면, 윤리가 있을 수 있는가? 만일 윤리가 근본적인 무언가이어야 한다면, 세계가 주어진 것만으로는 아직 윤리적 판단을 하기에 충분하지 않다. 그런 경우 세계는 그 자체로는 선하지도 악하지도 않다.” - [전쟁일기], 16년 8월 2일, 루트비히 비트겐슈타인
- “내 언어의 경계는 내 세계의 경계를 의미한다.” - [전쟁일기], 15년 5월 23일, 루트비히 비트겐슈타인

<br />
<hr />

## **2021-12-08**

- 자바스크립트의 문자열은 코드 유닛의 시퀀스이다. 따라서 두 문자열의 코드 유닛이 같다면 동일하다.
  ```jsx
  const firstStr = "hello";
  const secondStr = "\u0068ell\u006F";
  console.log(firstStr === secondStr); // => true
  ```
  => 정규화 필요 `str.normalize([form])`
- 정규화는 정규 표현으로 문자열을 변환하는 과정이고, 문자열이 고유한 표현을 갖도록 한다. 즉, 문자열이 결합 문자 시퀀스를 포함하는 복잡한 구조를 가질 때 표준 형식으로 정규화할 수 있다.
  ```js
  const str1 = "ça va bien";
  const str2 = "c\u0327a va bien";
  console.log(str1.normalize() === str2.normalize()); // => true
  console.log(str1 === str2); // => false
  ```
- zero width joiner
  - 복잡한 표기 체계의 컴퓨터에 따른 조판에서 사용되는 제어 문자
  - 부호 위치는 U+200D (HTML: `&#8205;`, `&zwj;`)
  - 두 이모지 사이에 ZWJ를 두면, 새로운 형태가 표시되는 것도 있다.
  - ex) 🏳️ ZWJ 🌈 = 🏳️‍🌈

<br />
<hr />

## **2021-11-16**

- **css-in-js vs css-in-css**
  - css preprocessor는 이제 필수이지만, 선택사항이 두가지 있을 수 있다.
  - 전자의 대표는 `styled-component`, 후자는 `SASS(SCSS)`가 있다.
  - `css-in-js` 방식은 다음과 같은 장단점이 있다.
    - js로 작성하므로 css 스타일링 코드 또한 컴포넌트화 해서 개발할 수 있다.
    - 클래스네임을 난수화해서 붙여주기 때문에 중복/오타 버그가 없다.
    - 그러나 별도 의존성 설치로 용량이 커지고 js 해석과정이 필요하기에 비교적 성능이 떨어진다.
  - `css-in-css` 방식은 다음과 같은 장단점이 있다.
    - js -> css 트랜스파일 과정이 없으므로 비교적 성능이 낫다.
    - 변수/함수/상속 등의 프로그래밍 기법을 활용해 스타일링 코드를 작성한다.
    - 그러나 결국 css로의 트랜스파일링이 필요하므로 `postCSS`같은 도구가 필요하다.
- **css-module-in-js**, [vanilla-extract.style](https://github.com/seek-oss/vanilla-extract)
  - 위의 두가지 방식을 적절히 섞어놓은 방식이라고 할 수 있다.
  - css-in-js와 비슷하게 js/ts 안에서 스타일링 코드를 작성하므로 스코프를 가진다.
  - css-in-css처럼 빌드타임에 css로 변환하므로 성능이 좋다. _aka. zero-runtime_
  - 그러나 스타일링 코드를 컴포넌트 단위로 관리할 수는 없다.

개인적으로 `styled-component`처럼 스타일링 코드를 컴포넌트화해서 얻는 이점보다 단점이 더 커서 별로 좋아하지 않는다. **css는 당연히 HTML요소와 강결합되는게 맞지만, 코드를 작성할 때부터 그러면 마크업 요소가 눈에 잘 들어오지 않기 때문이다.** 그래서 css-in-css방식을 좋아하지만, css코드 안에서 변수/상속 등을 활용한다는 것 자체가 러닝커브이고 묘하게 이질감이 들 때가 많았는데 두가지를 적절하게 조합한 라이브러리가 나와서 기대된다. 다들 잘만 쓰길래 나만 별로인가 싶었는데, 이런 취향도 있다고!

<br />
<hr />

## **2021-10-01**

- 타입스크립트 커버리지 추적해서 타입 안정성을 유지할 수도 있다.
  - npm type-cover-age 패키지로 단순 any를 추적할 수 있다.
  - `npx type-coverage` -> 9985 / 10117 98.69%
  - 10,117개 심벌 중 9,985개가 any가 아니거나 any별칭이 아닌 타입이다.
  - `--detail` 플래그를 붙이면 any타입이 있는 곳을 모두 출력해준다.

<br />
<hr />

## **2021-09-16**

- `async`는 언제나 암묵적으로 promise를 반환한다.

  - async 함수의 반환값이 프로미스가 아니어도 프로미스로 래핑된다.

    ```js
    // 반환타입은 Promise<number>
    const getNumber = async () => 42;
    ```

- `await`은 resolve 혹은 reject 된 값을 반환한다.

  - await을 해야만 프로미스가 동작하는 것이 아니다.
  - await은 이미 fulfilled된 각 비동기 태스크들의 완료 값을 동기적으로 반환하는 키워드이다.
  - 즉, 아래처럼 await을 하지 않고 프로미스 함수를 실행하는 것만으로 내부 동작을 수행한다.

    ```js
    const promise1 = () =>
      new Promise((resolve) => {
        console.log("항상 출력");
        setTimeout(() => {
          resolve(1);
        }, 1000);
      });

    const promise2 = async () => {
      console.log("항상 출력");
      return promise1();
    };

    // 프로미스는 fulfilled 상태의 객체로 가지고 있으며
    // 완료여부만 모를뿐 내부 로직 모두 수행한 상태
    const res = promise2();

    // resolve/reject된 값을 출력함
    (async () => {
      const res = await promise2();
      console.log(res);
    })();
    ```

<br />
<hr />

## **2021-08-11**

- 인덱스 시그니처 대신 명확하게 동적 객체를 타이핑하고 싶다면?

  - `Record`: 키 타입을 유연하게 지정할 수 있는 표준 제네릭

    ```ts
    type ABC = Record<"a" | "b" | "c", number>;
    ```

  - `Mapped type`: 키마다 별도의 타입을 사용하여 매핑

    ```ts
    type ABC = {[k in "a" | "b" | "c"]: number};
    type DEF = {[k in "d" | "e" | "f"]: k extends "e" ? string : number};
    ```

<br />
<hr />

## **2021-08-06**

- template literal types

  - 타입스크립트에서도 템플릿 리터럴 스트링 구문을 사용할 수 있다.
  - 아래처럼 문자열에서 어떤 값이 반복되어 사용될 때 활용할 수 있겠다.

    ```ts
    type PlusFriend = `${string}_FRIEND`;
    ```

  - 완전 확장하면 어떤 문자열의 첫번째 문자를 추론하는 타입을 만들 수도 있다.

    ```ts
    // First의 타입은 'a'
    type FirstLetter<S> = S extends `${infer C}${string}` ? C : "";
    type First = FirstLetter<"abcde">;
    ```

<br />
<hr />

## **2021-07-26**

- 인터페이스의 배열을 인덱싱할 때

  - 인덱싱을 통해 어떠한 타입의 부분집합으로 타입을 정의할 수 있다.
  - 이때 배열의 요소 중 하나를 인덱싱해서 명시할 수도 있다.
  - 이때 배열의 index는 number니까 아래처럼 `[number]`로 명시한다.
  - 따라서 `NavState['key']`의 타입은 string이 된다.

    ```ts
    interface State {
      arr: string[];
    }

    type NavState = {
      key: State["arr"][number];
    };

    const nav: NavState = {
      key: "one",
    };
    ```

<br />
<hr />

## **2021-07-15**

- javascript의 `throw`에 대하여

  > Execution of the current function will stop (the statements after throw won't be executed), and control will be passed to the first catch block in the call stack. If no catch block exists among caller functions, the program will terminate.

  - throw 다음 구문은 실행되지 않고, catch 블록이 없으면 프로그램이 종료된다.
  - throw를 던져도 이전 비동기 작업들은 각각 따로 실행되고, throw도 블록단위로 실행된다.
  - **즉, throw는 지역적이어서 아래를 실행하면 그 비동기 작업 내 throw도 모두 실행된다.**
  - 그리고 해당 블록의 throw 다음 구문은 실행되지 않는다.

    ```js
    function testPromise() {
      return new Promise((resolve, reject) => {
        resolve();
        console.log("excuted");
      });
    }

    testPromise().then(() => {
      throw "헹";
    });
    throw "error";
    testPromise();

    // 출력결과
    // excuted
    // Uncaught error
    // Uncaught (in promise) 헹
    ```

<br />
<hr />

## **2021-07-09**

- [Labeled Tuple](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-0.html#labeled-tuple-elements)

  > While these have no impact on type-checking, the lack of labels on tuple positions can make them harder to use - harder to communicate our intent.

  - 타입스크립트 4.0에서 제공되는데, 튜플에 좀더 의미있는 멤버명을 정할 수 있다.
  - 이때 튜플의 멤버는 모두 이름을 짓거나, 짓지 말아야 한다.

    ```ts
    // O
    type Range = [start: number, end: number];
    type Code = [number, number];

    // X
    type Bar = [first: string, number];
    ```

<br />

- [trackBy](https://angular.io/api/common/NgForOf#change-propagation)

  > trackBy takes a function that has two arguments: index and item. If trackBy is given, Angular tracks changes by the return value of the function.

  - angular의 NgForOf(\*ngFor) 디렉티브에서 사용하는 옵션이다.
  - 지정한 함수의 값으로 CD를 일으킬 수 있는데, 즉 변화에 해당하는 DOM만 다시 계산한다.
  - 따라서 trackBy는 고유한 값이어야 한다.

    ```ts
    @Component({
      selector: "my-app",
      template: `
        <li *ngFor="let item of list; trackBy: trackKey">
          {{ item.name }}
        </li>
      `,
    })
    export class App {
      list: [
        {id: 1; name: "first"},
        {id: 2; name: "second"},
        {id: 3; name: "third"},
        {id: 4; name: "fourth"}
      ];

      trackKey(index, item) {
        return item.id;
      }
    }
    ```

<br />
<hr />

## **2021-06-30**

- Referrer-Policy
  - 최근 회사에서 레퍼러를 수집하는데 사내 도메인에서만 남지 않는 현상을 발견했는데, 보니까 이 정책을 바꾼 것이 원인이었다.
  - http 헤더의 하나로, 해당 페이지가 어디서 열렸는지 알 수 있는 레퍼러(referrer) 정책을 설정한다.
    - `no-referrer`: 레퍼러 정보를 전혀 넘기지 않는다.
    - `origin`: 뒤에 경로는 빼고 도메인만 넘긴다.
    - `no-referrer-when-downgrade`: 넘기는 프로토콜 보안레벨이 같거나 더 높을 때 넘긴다.
      - ex) http -> http, http -> https
    - `same-origin`: 도메인과 프로토콜 보안레벨이 같을 때만 넘긴다.
    - `strict-origin`: 이동하는 페이지가 https일 때만 넘긴다.
    - `strict-origin-when-cross-origin`: 디폴트. 동일 도메인 혹은 교차 허용된 도메인에서 동일한 프로토콜 보안레벨로 이동시킬 때 넘긴다.
    - `unsafe-url`: 조건 없이 전체 주소를 넘긴다.

<br />
<hr />

## **2021-06-23**

- 덕 타이핑 (duck typing)은 덕 테스트 (duck test)에서 유래한 것으로, 아래 명제에서 시작한다.

  > 만약 어떤 새가 오리처럼 걷고, 헤엄치고, 꽥꽥거리는 소리를 낸다면 나는 그 새를 오리라고 부를 것이다.

  - 객체의 변수와 메서드의 집합이 그 객체의 타입을 결정하는 것을 의미한다.
  - 타입을 미리 지정하지 않고 런타임에 해당 메서드들을 확인해 타입을 정하는 동적 타이핑의 한 종류다.
  - **ts 또한 결국 덕 타이핑 기반의 js의 런타임 동작을 모델링해 타입을 체크한다.**
  - 따라서 아래에서 Vector2D와 NamedVector의 관계를 선언하지 않아도 타입에러가 발생하지 않는다.
  - 즉, NamedVector타입인 param을 Vector2D타입의 인자를 받는 caculateLength로 실행해도 정상적이다.
  - 좋든 싫든 ts의 타입 시스템에서 타입은 확장될 수 있도록 '열려' 있다.

    ```ts
    interface Vector2D {
      x: number;
      y: number;
    }

    interface NamedVector {
      name: string;
      x: number;
      y: number;
    }

    function caculateLength(v: Vector2D) {
      return Math.sqrt(...);
    }

    const param: NamedVector = {x: 3, y: 4, name: 'haha'}
    caculateLength(param)
    ```

<br />
<hr />

## **2021-05-05**

- **colon(:) in vim**
  옛날에는 터미널로 모든 상호작용을 해야 했으므로, ex(extended)라는 짧은 니모닉 명령으로 구성되었다. `:substitute/foo/bar`와 같은 명령으로 상호작용했다. 하지만 시간이 지나면서 vi가 ex commands를 통합하고 `i`, `x`와 같이 더 많은 대화형 명령들을 도입했다. 따라서 콜론(:)은 ex모드로 전환하는 명령어이다. 참고로 [vim의 모드](http://vimdoc.sourceforge.net/htmldoc/intro.html#Normal)는 아래 6가지이다.
  - **normal mode**: 모든 편집기 명령을 할 수 있는 모드, command mode
  - visual mode: 문자열 혹은 라인을 하이라이팅할 수 있는 모드, "v" 혹은 "V"로 시작
  - select mode: 커서로 문자열 혹은 라인을 하이라이팅할 수 있는 모드, "gh"로 시작
  - **insert mode**: 가장 자주 쓰이고 텍스트를 삽입 혹은 대체할 수 있는 모드, "i"로 시작이 일반적
  - ex mode: ex 명령어들을 사용할 수 있는 모드로 vi 자체가 비주얼된 ex, ":"으로 시작
  - command-line mode: ex commands를 사용할 수 있기 위한 모드
    - Ex commands (`:`)
    - search patterns (`/` and `?`)
    - filter commands (`!`)

<br />
<hr />

## **2021-04-14**

- **npm ci**
  - 상태를 클린하게 유지하기 위해 `node_modules`를 모두 지움
  - `package-lock.json`으로 명시된 버전으로 의존성을 설치함
  - package-lock.json 파일을 수정하지 않는데, 이 파일이 없으면 설치도 안됨
  - 따라서 CI에서 배포 전 의존성 설치로 사용하기에 적합
- **npm install**
  - 모든 의존성을 설치하거나 기존 dependency를 업데이트
  - 설치 후 변경사항이 있으면 그에 맞게 package-lock.json를 수정함

<br />
<hr />

## **2021-03-26**

- [border-radius 속성](https://www.w3.org/TR/css-backgrounds-3/#border-radius)은 각 모서리에 지정한 반지름을 가진 원으로 라운딩 처리를 한다. 이때 radius를 50%, 100%, 999px 이런 식으로 줘도 일정 비율 이상 커브가 생기지 않는데 그 이유는 각 원이 겹치지 않게 처리하기 떄문이다. 아래는 공식문서에 적힌 내용이다.

  > Let f = min(Li/Si), where i ∈ {top, right, bottom, left}, Si is the sum of the two corresponding radii of the corners on side i, and Ltop = Lbottom = the width of the box, and Lleft = Lright = the height of the box. If f < 1, then all corner radii are reduced by multiplying them by f.

  **각 코너에 준 값에 대한 비율을 계산해 그 중 최소비율값을 곱하면 각 radii끼리 겹치지 않게 된다.** 그래서 999px, 10px, 999px, 10px 이런 식으로 주면 일정 비율을 곱하기 때문에 직사각형 왼쪽의 원이 필요한 것보다 줄어들게 된다. [이 문서 - what-happens-when-border-radii-overlap](https://css-tricks.com/what-happens-when-border-radii-overlap/)가 설명을 잘 해놨더라.

<br />
<hr />

## **2021-03-24**

- angular 프레임워크를 사용할 때 생성자 메서드를 주의하자. constructor는 단지 ES6 클래스 문법에서 객체를 생성하는 시점에 호출되므로 angular가 초기화 작업을 수행하기 전이다. 따라서 앵귤러 컴포넌트에서 바인딩한 속성이나 부모 컴포넌트로부터 전달받은 속성 등의 초기화를 보장하지 않는다. 생성자에는 순수하게 객체의 생성 시점에 필요한, static한 값을 초기화할 때만 사용하자.
- **Angular Application Bootstrap: 모듈 셋업 외에는 모두 component bootstrap이다.**
  - Module setup - 모듈 초기화, 의존성 주입 등
  - View creation - 템플릿 코드를 실제 DOM으로 생성
  - Change detection

<br />
<hr />

## **2021-02-24**

- cmd에서 작업하던 소스를 단위(hunk)별로 stage에 올리고 싶으면 `--patch` 옵션 사용하면 된다.

  ```sh
  $ git add --patch
  ```

- 반영할지 말지 선택하는 옵션들은 아래와 같다. 보통 y로 반영하고, n으로 반영하지 않는다.

  ```txt
  y - stage this hunk
  n - do not stage this hunk
  q - quit; do not stage this hunk or any of the remaining ones
  a - stage this hunk and all later hunks in the file
  d - do not stage this hunk or any of the later hunks in the file
  g - select a hunk to go to
  / - search for a hunk matching the given regex
  j - leave this hunk undecided, see next undecided hunk
  J - leave this hunk undecided, see next hunk
  k - leave this hunk undecided, see previous undecided hunk
  K - leave this hunk undecided, see previous hunk
  s - split the current hunk into smaller hunks
  e - manually edit the current hunk
  ? - print help
  ```

<br />
<hr />

## **2021-02-10**

- 타입을 export하지 않고 있는 3rd party library 등을 ts에서 사용할 때 `d.ts` 파일에 모듈을 선언해두는 과정이 필요한데, 모호성 때문인지 이걸 Ambient declarations 부르더라. 그래서 타입스크립트 내에는 이 이름 그대로 [TypeScript/ambients.d.ts](https://github.com/microsoft/TypeScript/blob/master/scripts/types/ambient.d.ts) 파일이 있다. 외부 모듈을 declare해서 tsc가 이해할 수 있도록 한다.

<br />
<hr />

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
