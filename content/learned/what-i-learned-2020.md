---
title: "2020"
date: "2020-01-01"
description: "About what I learned at 2020"
og_description: "About what I learned at 2020"
draft: false
---

## **2020-12-23**
- rxjs `animationFrameScheduler`는 window.requestAnimationFrame가 실행될 때 작업을 수행하는 오퍼레이터이다. 이를 활용해 브라우저가 repaint 하기 전에 스타일을 지정할 수도 있다.
  ```ts
  import { animationFrameScheduler } from 'rxjs';
  import { observeOn } from 'rxjs/operators';

  someObservable.pipe(
    observeOn(animationFrameScheduler)
  ).subscribe(v => {
    someDiv.style.height = `${v}px`;
  })
  ```
- 다른 rxjs의 스케줄러는 아래와 같다.
  - `asapScheduler`: 비동기 작업들 중에서 높은 우선순위를 가져간다. microtask와 동일한 큐로 스케줄링한다.
  - `asyncScheduler`: 일반적인 setTimeout(task, duration)처럼 작업을 수행한다.
  - `queueScheduler`: 동기적인 방식으로 스케줄링한다. async / await를 생각하면 쉽다.
- debounceTime, delay, throttleTime, timeInterval, windowTime과 같은 시간 관련 오퍼레이터들이 마지막 인자로 스케줄러를 받을 수 있다.
  - **지정하지 않을 경우 asyncScheduler를 기본으로 사용한다.**

<br />
<hr />

## **2020-12-03**
- http request의 `Referer` 헤더는 실제 단어 referrer의 오타이다. 이를 [정의할 때 철자를 빼먹어서](https://tools.ietf.org/html/rfc1945#section-10.13) 그대로 표준이 되었다. 그래서 document객체는 `document.referrer`라고 명시되어 있다. 표준은 한번 정해지면 함부로 바꿀 수 없는 것의 좋은 예시이기도 하다.

<br />
<hr />

## **2020-11-25**
- 타입스크립트 컴파일러가 이해하기 쉽게 코드를 작성하면(Easy-to-Compile), ts 성능을 높일 수도 있다.
- [자세한 문서는 여기 - microsoft/TypeScript WIKI](https://github.com/microsoft/TypeScript/wiki/Performance)
- 인터섹션 타입(intersection type)보다는 인터페이스(interface)로 작성하자.
  ```
  - type Foo = Bar & Baz & {
  -     someProp: string;
  - }

  + interface Foo extends Bar, Baz {
  +     someProp: string;
  + }
  ```
- 타입 어노테이션, 특히 메서드 등이 반환할 타입을 지정해주면 컴파일러의 비용을 절약할 수 있다.
  ```ts
  export function func(): otherType {
      return otherFunc();
  }
  ```
- 유니온(Unions)을 만들기 보다는 서브타입(subtypes)을 만들자. 유니온으로 명시된 타입의 중복 멤버를 제거하려면 쌍으로 비교해야 하므로 비용이 많이 들기 때문이다. 아래처럼 간단한 것은 상관 없지만 12개 이상을 가진 유니온은 체감하는 속도에도 영향을 준다고 한다. 
  ```ts
  // before
  interface WeekdaySchedule {
    day: "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday";
    wake: Time;
    startWork: Time;
    endWork: Time;
    sleep: Time;
  }

  interface WeekendSchedule {
    day: "Saturday" | "Sunday";
    wake: Time;
    familyMeal: Time;
    sleep: Time;
  }

  declare function printSchedule(schedule: WeekdaySchedule | WeekendSchedule);
  ```

  ```ts
  // after
  interface Schedule {
    day: "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday" | "Saturday" | "Sunday";
    wake: Time;
    sleep: Time;
  }

  interface WeekdaySchedule extends Schedule {
    day: "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday";
    startWork: Time;
    endWork: Time;
  }

  interface WeekendSchedule extends Schedule {
    day: "Saturday" | "Sunday";
    familyMeal: Time;
  }

  declare function printSchedule(schedule: Schedule);
  ```

<br />
<hr />

## **2020-11-12**
- 리액트의 `setState()` 메서드는 **state의 변경 사항을 대기열에 넣어** 상태를 변경하라고 React에 요청한다. 따라서 즉시 state를 변경하지 않으므로 상태를 변경하고 그 상태를 바로 호출하면 의도한 대로 동작하지 않는다. 같은 setState를 한번에 여러번 호출하면 안되는 이유이기도 하다. 아래는 setData를 count만큼 실행하고 있는데, map 메서드를 통해 다음 data를 받아서 setData를 한번만 호출하도록 바꾸는 것이 낫겠다.
  ```ts
  const getRandom = (max: number) => Math.random() * max;
  const count = Math.floor(getRandom(100));

  const [data, setData] = useState<IData[]>([]);
  
  useEffect(() => {
    for (let i = 0; i <= count; i++) {
      setData((prevState) => [
        ...prevState,
        {
          totalCount: Math.floor(getRandom(1500)),
          satisfaction: getRandom(5).toFixed(2),
        },
      ]);
    }
  }, []);
  ```
- 리액트 훅은 함수형 컴포넌트의 최상위에서만 호출해야 한다. 반복문, 조건문, 혹은 중첩된 함수 내에서 호출하면 안된다. 리액트는 hook이 호출되는 순서에 의존하기 때문이다. [React hooks를 자바스크립트로 구현한 예제](https://medium.com/humanscape-tech/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8-%ED%81%B4%EB%A1%9C%EC%A0%80%EB%A1%9C-hooks%EA%B5%AC%ED%98%84%ED%95%98%EA%B8%B0-3ba74e11fda7)를 참고해보자.

<br />
<hr />

## **2020-09-23**
- rxjs에서 어떠한 이벤트 스트림의 inner 옵저버블을 그저 특정 순서에 실행하고 구독했을 때 순서를 보장한 채로 값을 emit하려면 pipe 내에 필요한 위치에 `concatMapTo`를 사용하자. 아래는 구독여부에 관한 옵저버블을 실행 후 emit된 값이 `true`인 경우만 구독 옵저버블을 실행한다.
  ```ts
  stream.pipe(
    switchMap(() => testService.subscribed$),
    filter(isTrue => isTrue),
    concatMapTo(testService.subscribe())
  ).subscribe();
  ```

<br />
<hr />

## **2020-09-14**

- git 환경설정은 3가지 방식으로 할 수 있으며, 각 설정은 역순으로 우선시 된다. 따라서 global 설정이 있어도 어떤 프로젝트에 로컬 옵션을 줬다면 그 옵션이 적용될 것이다. 
  1. `/etc/gitconfig`: 시스템의 모든 사용자와 모든 저장소에 적용된다.

      ```sh
      $ git config --system
      ```
  2. `~/.gitconfig`: 특정 사용자에게만 적용된다.

      ```sh
      $ git config --global
      ```
  3. `.git/config`: 특정 저장소, 혹은 현재 작업 중인 프로젝트에만 적용된다.

      ```sh
      $ git config --local
      ```

<br />
<hr />

## **2020-09-09**

- `vscode` 에디터에서 갑자기 탭이 사라지고 파일 하나씩만 뜨는 경우가 있는데, 이때 아래 옵션을 확인해본다.

  ```sh
  "workbench.editor.showTabs": false
  ```

<br />
<hr />

## **2020-09-05**

- rxjs에서 Subject를 프로미스로 만들고 싶다면 아래처럼 `take`, `first` 등등을 통해 emit할 개수를 명시해야만 한다. 그렇지 않으면 어떠한 값도 발생되지 않는다. Subject가 옵저버블이면서 옵저버이기 때문에 멀티 리스너를 가질 수 있어서 그런 것 같다.

  ```ts
  // test.component.ts
  ...
  async () => {
    this.testService.updateTest();

    // get data after test$.next()
    const data = (await this.testService.testPromise()).data;
  }


  // test.service.ts
  ...
  const test$ = new Subject<boolean>();

  function testPromise(): Promise<boolean> {
    return this.test$.pipe(take(1)).toPromise();
  }

  function updateTest(): void {
    this.httpClient.get("/test").subscribe(
      (data) => this.test$.next(data),
      (data) => this.test$.error(data)
    );
  }
  ```

<br />

- 위에 내용에 대해 버그가 아니냐고 issue에 올라오고 있고, Rxjs v7부터 `toPromise`가 deprecated되어 v8에서는 사라진다고 하니 최신 버전에서는 `firstValueFrom`, `lastValueFrom`으로 쉽게 async await 패턴을 사용할 수 있겠다. 근데 지금 날짜 기준으로는 v7도 베타인 상태다. 관련 문서는 [여기!](https://indepth.dev/rxjs-heads-up-topromise-is-being-deprecated/)

<br />
<hr />

## **2020-08-09**

- 크롬 콘솔에서 lodash와 같은 라이브러리를 테스트하고 싶으면, 직접 script injection 하면 된다.

  ```ts
  const el = document.createElement("script");

  el.src = "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.js";
  document.getElementsByTagName("head")[0].appendChild(el);

  _.VERSION;
  ```

<br />
<hr />

## **2020-07-26**

- 현재 작업중이었던 브랜치를 특정 브랜치를 기준으로 log를 쌓고 싶을 때는 `git rebase`를 통해 하며, 리베이스 도중 충돌이 일어나면 머지 마킹하고 `git rebase --continue`를 통해 계속 진행한다.

  ```text
  Q. master <- hotfix/test PR에 충돌이 많아서, 현재 기준의 master에서 새로 딴 브랜치로 옮기고 싶다면?

  git pull master
  git checkout hotfix/test
  git rebase master
  (after resolve conflicts)
  git rebase --continue
  git log --graph --decorate
  ```

<br />
<hr />

## **2020-07-17**

- `ln` 리눅스 명령을 통해 어떤 파일의 바로가기를 만들 수 있다. `-s` 옵션을 지정하면 symlink(symbolic link)를 만들어준다. 이것이 일반적으로 의미하는 바로가기이며, **원본이 지워지면 해당 파일도 접근할 수 없다.** 아래 예시에서 hello.txt에 쓴 텍스트는 dest.txt에서도 보인다. hello.txt 원본을 지우면 hard link 방식일 때는 dest.txt에 접근할 수 있지만, soft link 방식일 때는 접근할 수 없다.

  ```sh
  $ touch hello.txt

  # 1. hard link
  $ ln hello.txt dest.txt

  # 2. soft link
  # -f means, If the target file exists, then unlink.
  $ ln -fs hello.txt dest.txt

  $ echo hello > hello.txt
  $ cat dest.txt
  $ rm hello.txt

  ```

<br />
<hr />

## **2020-07-15**

- `git cherry-pick` 명령을 통해 특정 커밋을 반영해올 때, `--no-commit, -n` 옵션을 붙이면 커밋을 하지 않는다. 따라서 어떠한 커밋에서 특정 파일들만 반영하고 나머지는 이전으로 되돌린 후에 반영할 수 있다.

  ```text
  Q. master <- hotfix/test PR에 충돌이 많아서, 현재 기준의 master에서 딴 브랜치로 옮기고 싶다면?

  1. master에서 temp 브랜치를 새로 딴다.
  2. temp에서 hotfix/test의 커밋들을 cherry-pick 한다.
  3. cherry-pick 하는 도중 충돌이 일어난 커밋들이 있다!
  4. 3번의 커밋들은 git cherry-pick -n {hash} 으로 가져온다.
  5. 충돌이 일어났거나 반영하고 싶지 않은 파일들은 이전 상태로 돌린다.
  ```

<br />
<hr />

## **2020-07-08**

- `JSON`은 데이터 포맷이지 자바스크립트만의 문법이 아니다. `YAML`과 비슷하지만, JSON에는 주석을 달 수 없다. (by Douglas Crockford)

<br />

- **VSync (Vertical synchronization)**
  - GPU가 처리하는 프레임으로, 모니터의 화면 업데이트는 VSync에 의해 이루어진다.
  - 일정한 시간 간격(60Hz)으로, 그래픽 메모리의 front buffer에 저장된 프레임으로 swap되며 화면이 업데이트된다.
  - 가끔 화면이 깨져 보이는 현상을 Tearing이라고 한다.
    - VSync가 진행되는 동안 모니터 refresh가 진행되며, 60Hz 모니터는 16.6ms마다 VSync pulse가 발생한다.
    - Tearing 방지를 위해 VSync pulse 동안은 buffer swap이 불가능하다.
    - 즉, VSync를 사용하면 Tearing이 일어나지 않는다.
  - 이러한 VSync를 기반으로 프레임 타이밍을 잘 제어해야 화면이 매끄럽게 보일 수 있다.
  - 프레임은 픽셀 데이터, 프레임 타이밍은 프레임 생성을 위한 시간 제어라고 할 수 있다.
  - 크롬 브라우저의 프레임 렌더링은 다음과 같다.
    ![frame-rendering](https://v8.dev/_img/free-garbage-collection/frame-rendering.png)

<br />

- **Browser rendering pipeline**
  - 렌더링은 다음의 파이프라인으로 이루어진다.
    - [참고: performance rendering](https://developers.google.com/web/fundamentals/performance/rendering)
    - | JS
    - | Layout: width, height, font... (reflow)
    - | Paint: color, background... (repaint)
    - | Composite: opacity, transform...
    - **참고로 Paint 과정에서 GPU Rasterization을 사용하면 빨라진다.**
      - 크롬 브라우저에서 `<meta>` viewport를 설정하거나, css `@viewport`를 설정해 사용할 수 있다.
        ```html
        <meta name="viewport" content="width=device-width, minimum-scale=1.0" />
        ```
      - `minimum-scale`를 "yes"로 설정하면 안되고, "1.0"으로 해야 한다.
      - `initial-scale`과 `user-scalable`는 고려 대상이 아니라서 상관없다.
  - Javascript의 **requestAnimationFrame** 메서드는 브라우저에게 다음 repaint가 진행되기 전에 해당 애니메이션을 업데이트하는 함수를 호출하도록 한다. 따라서 화면에 새로운 애니메이션을 업데이트할 준비가 될때마다 이 메소드를 호출하는것이 좋다.

<br />
<hr />

## **2020-07-03**

- webpack 번들에는 if~else 혹은 switch 구문으로 dynamic import해도, 번들에는 모두 포함된다. 관련 분석 도구는 [webpack-bundle-analyzer](https://coryrylan.com/blog/analyzing-bundle-size-with-the-angular-cli-and-webpack)를 참고하자. 번들링 결과는 stats.json 파일로 확인할 수 있고, 참고로 앵귤러에서는 `npx ng build --statsJson`를 통해 확인 가능하다.

  ```js
  // 지연 로딩될 뿐, 모두 번들링에 포함된다.
  // just lazy loaded, all included in bundle.
  if (production) {
    await import("path/sdk.prod.js");
  } else {
    await import("path/sdk.dev.js");
  }
  ```

<br />

- ssh 접속할 때 그 호스트의 FingerPrint를 등록할 것인지 물어보는데, yes를 하면 그 호스트는 `~/.ssh/known_hosts` 파일에 등록된다. 예를 들면 github에 처음 접근(checkout, commit...)할 때도 그렇다. 만약 기록이 없는데 미리 등록하려면 해당 파일에 직접 호스트를 추가해주거나, 접근할 주소를 안다면 터미널을 강제 할당할 수도 있다.

  ```sh
  # 1. 직접 호스트명 추가
  $ ssh-keyscan -t rsa host명 >> ~/.ssh/known_host

  # 2. 터미널 강제 할당 (-T 옵션)
  # -> 접근하는 ssh의 터미널에 명령어를 보내고 받는 등, interactive scripts(shell) 허용
  $ ssh -vT git@github.******.com
  $ vim ~/.ssh/known_hosts
  ```

<br />
<hr />

## **2020-07-01**

- **/etc/hosts**
  : `cat /etc/hosts`를 실행하면 본인(host)의 컴퓨터에서 매핑된 ip주소와 도메인 이름을 확인할 수 있다. 브라우저나 터미널에서 도메인 이름을 치면 네임서버에서 ip를 얻게 되는데, 호스트 컴퓨터가 네임서버에 접근할 수 없는 상황에서는 해당 파일에 매핑된 도메인 이름과 ip주소를 이용한다.

  ```sh
  ##
  # Host Database
  #
  # localhost is used to configure the loopback interface
  # when the system is booting.  Do not change this entry.
  ##
  127.0.0.1       localhost
  255.255.255.255 broadcasthost
  ::1             localhost
  ```

<br />

- 현재 터미널에 특정 스크립트를 실행해 환경변수 등을 적용하는 `source` 커맨드는 `.`와 같다.

  ```sh
  $ source ~/.zshrc
  $ . ~/.zshrc
  ```

<br />

- oh my zsh을 사용할 때 git 관련 명령어를 alias로 사용할 수 있는 이유는 수많은 플러그인 덕분이다.

  ```sh
  vim .oh-my-zsh/plugins/git/git.plugin.zsh

  #
  # Functions
  #

  # The name of the current branch
  # Back-compatibility wrapper for when this function was defined here in
  # the plugin, before being pulled in to core lib/git.zsh as git_current_branch()
  # to fix the core -> git plugin dependency.
  function current_branch() {
    git_current_branch
  }

  # Pretty log messages
  function _git_log_prettily(){
    if ! [ -z $1 ]; then
      git log --pretty=$1
    fi
  }
  compdef _git _git_log_prettily=git-log

  # Warn if the current branch is a WIP
  function work_in_progress() {
    if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
      echo "WIP!!"
    fi
  }

  #
  # Aliases
  # (sorted alphabetically)
  #

  alias g='git'

  alias ga='git add'
  alias gaa='git add --all'
  alias gapa='git add --patch'
  ...
  ```

<br />

- **angular entryComponent**
  : 진입 컴포넌트로, 2가지 상황에서 사용된다. 앵귤러는 `@NgModule.bootstrap`에 지정된 컴포넌트를 자동으로 인식하고 진입 컴포넌트로 등록하기 때문에 직접 지정해줄 필요는 없지만, 모듈을 동적으로 로드 하는 경우에는 `entryComponents` 배열에 지정해야 한다.

  ```text
  1. NgModule이 시작될 때 (부트스트랩 되는 컴포넌트, AppComponent)
  2. 라우팅 되면서 접속 주소가 변경될 때 (라우팅 대상 컴포넌트)
  ```

<br />
<hr />
