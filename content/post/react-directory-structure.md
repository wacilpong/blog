---
title: "Directory structure with React"
date: 2019-04-22
tags: ["web-development", "react", "directory-structure", "javascript"]
draft: false
---

## Why I am considering it

`앵귤러 5+`로 프로젝트를 진행하다가 리액트를 쓰게 되었는데, 앵귤러는 처음 1.x버전부터 본인을 `MVW(Model-View-Whatever)`와 같은 패턴을 지원하는 `Declarative Template`이라고 지칭한다. 그리고 `angular-cli` 커맨드를 사용하게 되면, 컴포넌트 1개당 관련 .css/.ts/.test.js/.html 파일들이 폴더로 생성되는 구조이다. 따라서 비교적 폴더구조에 대해서는 크게 고민하지 않았는데, 리액트를 해보니 굉장히 자유도가 높았고 폴더 구조도 쓰는 사람마다 천차만별이었다. 그러다보니 이에 대해 자연스럽게 고민하고 찾아봤다.

I was dealing with angular framwork that calls `Declarative Template` itself, supports the patterns like `MVW(Model-View-Whatever)`, and I recently start to managing react project. Moreover `angular-cli` command generates .css/.ts/.test.js/.html files to each components. So I didn't considering about directory structure deeply, but now I move to react and it much more depends on programmer.

## What React says about it ?

기본적으로 리액트는 다음과 같이 말한다.

> React doesn’t have opinions on how you put files into folders. That said there are a few common approaches popular in the ecosystem you may want to consider.
