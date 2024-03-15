---
title: "2024"
date: "2024-01-01"
description: "About what I learned at 2024"
og_description: "About what I learned at 2024"
draft: false
---

## **2024-03-15**

- Not Allowed Attribute Filtered 이슈를 만났다!
  - a태그에 특정 링크를 걸어 서버를 한번 거쳐 저장을 한 후 프론트에서 노출하고 있었다.
  - 그런데 막상 프론트에 노출된 화면을 보니 태그에 링크가 걸려 있지 않고, a태그 위에 아래 문구가 주석으로 있었다.
    `Not Allowed Attribute Filtered`
  - 서버에서 html을 저장하는 과정에서 xss 방어를 위한 라이브러리를 사용중이었는데, 거기서 막고 있는 경우였다.
  - 걸어놓은 링크에 _script_ 라는 단어가 포함되어 있었다... (정확히는 _description_ 이었음)
  - 그래서 파악한 원인을 서버와 논의하여 해결할 수 있었다. 굿.

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
