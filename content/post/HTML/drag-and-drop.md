---
title: "Drag and drop API"
date: "2020-03-15"
tags: ["html"]
draft: false
og_description: "HTML5의 모든 요소에는 draggable이라는 속성을 붙일 수 있다."
---

## Draggable

HTML5의 모든 요소에는 `draggable`이라는 속성을 붙일 수 있다.

```html
<p draggable="true">drag01</p>
<h3 draggable="true">drag02</h3>
<div draggable="true">drag03</div>
...
```

<br />

이 속성이 적용된 요소를 이용해 드래그 이벤트를 활용할 수 있고 [DragEvent](https://developer.mozilla.org/ko/docs/Web/API/DragEvent), [DataTransfer](https://developer.mozilla.org/ko/docs/Web/API/DataTransfer) 와 같은 인터페이스의 메소드들도 활용해볼 수 있다.

<br />

## DragEvent

DragEvent는 [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent)를 상속받고, 아래와 같은 이벤트들을 지정할 수 있다. 더 자세한 건 [Drag & Drop API 문서](https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API)를 보자.

| _Event Handlers_ |                                                            |
| ---------------- | ---------------------------------------------------------- |
| **ondrag**       | &nbsp;&nbsp;요소를 드래그하고 있을 때 발생                 |
| **ondragstart**  | &nbsp;&nbsp;요소를 드래그하기 시작한 시점에 발생           |
| **ondragover**   | &nbsp;&nbsp;요소가 지정한 드롭 위치에 드래그되었을 때 발생 |
| **ondrop**       | &nbsp;&nbsp;요소를 지정한 드롭 위치에 드롭했을 때 발생     |

브라우저는 기본적으로 DOM 요소에 드롭 이벤트가 발생되어도 아무 일도 일어나지 않는다. 따라서 특정 요소를 드롭 위치로 지정하고 싶다면 `ondragover` 혹은 `ondrop`을 지정해주어야 한다.

<br />

## DataTransfer

모든 DragEvent는 본인의 이벤트 데이터를 들고 있는`dataTransfer`를 가지고 있다. 이 객체를 통해 드래그하는 요소 데이터를 관리할 수 있다. 관리할 데이터는 html도 가능하며, 더 자세히는 [Recommended drag types](https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API/Recommended_drag_types)를 보자.

<br />

##### 1. 드래그가 시작되었을 때 해당 요소의 value를 관리할 text data로 추가

```javascript
function dragStart(event) {
  event.dataTransfer.setData("text/plain", event.target.id);
}
```

<br />

##### 2. 드래그하는 중에 마우스 포인터가 드롭 위치로 이동했을 때의 효과 주기

```javascript
function dragOver(event) {
  event.preventDefault();
  event.dataTransfer.dropEffect = "move";
}
```

<br />

##### 3. 드롭했을 때 dataTransfer에 넣었던 데이터를 꺼내서 활용하기

```javascript
function drop(event) {
  event.preventDefault();

  const data = event.dataTransfer.getData("text");
  event.target.appendChild(document.querySelector(`#${data}`));
}
```
