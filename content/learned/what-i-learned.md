---
title: "2020"
description: "what i learned"
og_description: "What I Learned"
draft: false
---

#### 2020-07-01

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
