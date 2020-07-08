---
title: "2020"
description: "what i learned"
og_description: "What I Learned"
draft: false
---

#### **2020-07-01**

- **angular entryComponent**
  : 진입 컴포넌트로, 2가지 상황에서 사용된다. 앵귤러는 `@NgModule.bootstrap`에 지정된 컴포넌트를 자동으로 인식하고 진입 컴포넌트로 등록하기 때문에 직접 지정해줄 필요는 없지만, 모듈을 동적으로 로드 하는 경우에는 `entryComponents` 배열에 지정해야 한다.

  1. NgModule이 시작될 때 (부트스트랩 되는 컴포넌트, AppComponent)
  2. 라우팅 되면서 접속 주소가 변경될 때 (라우팅 대상 컴포넌트)

<br />

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
<hr />

#### **2020-07-03**

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

#### **2020-07-08**
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
      - GPU Rasterization을 사용하면 빨라진다.
      - 크롬 브라우저에서 `<meta>` viewport를 설정하거나, css `@viewport`를 설정해 사용할 수 있다.
        ```html
        <meta name="viewport" content="width=device-width, minimum-scale=1.0">
        ```
      - `minimum-scale`를 "yes"로 설정하면 안되고, "1.0"으로 해야 한다.
      - `initial-scale`과 `user-scalable`는 고려 대상이 아니라서 상관없다.
  - Javascript의 **requestAnimationFrame** 메서드는 브라우저에게 다음 repaint가 진행되기 전에 해당 애니메이션을 업데이트하는 함수를 호출하도록 한다. 따라서 화면에 새로운 애니메이션을 업데이트할 준비가 될때마다 이 메소드를 호출하는것이 좋다.

  
