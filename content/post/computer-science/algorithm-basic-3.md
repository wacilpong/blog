---
title: "Algorithm basic 3"
date: "2020-05-13"
tags: ["computer-science"]
draft: false
---

칸아카데미의 알고리즘 코스를 들으며 정리해본 알고리즘 기초.
https://ko.khanacademy.org/computing/computer-science/algorithms

<br />

## 그래프 표현

![graph](https://cdn.kastatic.org/ka-cs-algorithms/directed_graph_for_challenge.png)

이러한 그래프가 있다고 하면, 변수에 저장할 때 3가지 방식으로 할 수 있겠다.

<br />

#### 1. _엣지리스트 (Edge List)_

엣지리스트는 두 정점(vertex)을 연결하는 변(edge)의 개수만큼의 배열이다. 매우 간단한 방식이지만 아무런 순서 없이 무작위로 들어가 있다면, 특정 edge를 찾으려면 선형 검색을 해야 한다. 따라서 O(N)만큼의 복잡도를 지니며, O(log N)으로 줄일 수 있지만 복잡하다.

```javascript
const edgeList = [
  [0, 2],
  [1, 3],
  [2, 3],
  [2, 4],
  [3, 5],
  [4, 5],
];
```

<br />

#### 2. _인접행렬_

```javascript
const adjMatrix = [
  [0, 0, 1, 0, 0, 0],
  [0, 0, 0, 1, 0, 0],
  [0, 0, 0, 1, 1, 0],
  [0, 0, 0, 0, 0, 1],
  [0, 0, 0, 0, 0, 1],
  [0, 0, 0, 0, 0, 0],
];
```

<br />

#### 3. _인접리스트_

```javascript
const adjList = [[2], [3], [3, 4], [5], [5], []];
```

...
(작성중)
