---
title: "Algorithm basic 3"
date: "2020-05-24"
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

**[그래프에 대한 기본 용어]**
- `정점(vertex)`: 그래프를 이루고 있는 어떠한 꼭짓점
- `변(edge)`: vertex를 연결하는 선
- `차수(degree)`: edge의 수

#### 1. **_엣지리스트 (Edge List)_**

엣지리스트는 두 vertex을 연결하는 edge의 개수만큼의 배열로 그래프를 저장하는 방식이다. 매우 간단한 방식이지만 아무런 순서 없이 무작위로 들어가 있다면, 특정 edge를 찾기 위해 선형 검색을 해야 하고 이는 O(N)만큼의 복잡도를 지닌다.

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

#### 2. **_인접행렬_**

인접행렬은 모든 vertex에 인접한 각 vertex를 0으로 표시하고 edge가 있는 경우 1로 표시한 배열로 그래프를 저장하는 방식이다. 즉, vertex by vertex로써 저장되므로 edge가 별로 없는 희소 그래프이더라도 공간을 N^2만큼 차지한다. 게다가 특정 `i`의 인접한 `j`를 찾기 위해서는 i행의 모든 vertex를 검색해야 한다.

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

#### 3. **_인접리스트_**

인접리스트는 각 vertex의 edge로 연결된 vertex로 이루어진 배열로 그래프를 저장하는 방식이다. 따라서 edge `(i, j)`가 그래프에 있는지 찾으려면 `graph[i][j]`로 검색해야 한다. 이 검색은 최악의 경우에는 정점 i의 edge 개수만큼 걸린다. 즉, O(degree)만큼의 복잡도를 지닌다.

```javascript
const adjList = [
  [2],
  [3],
  [3, 4],
  [5],
  [5],
  []
];
```

<br /><hr />

## 너비우선탐색 (Breadth First Search), 거대한 그래프 횡단해보기!

...(작성중)