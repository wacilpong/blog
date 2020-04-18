---
title: "Splice Array"
date: "2019-11-01"
tags: ["javascript"]
draft: false
og_description: "splice can select(remove) the item with specific index to certain index."
---

가끔 `Array.prototype.splice()`가 굉장히 헷갈릴 때가 있는데, 그게 언제냐면 이 값을 할당할 때!

Sometimes I confused about `Array.prototype.splice()` function, especially when assign the returned value from this !
<br /><br />

### Array.prototype.splice() do ... what ?

splice는 아래처럼 특정 인덱스에서 특정 개수만큼 뽑아낼 수 있는 함수이다.

splice can select(remove) the item with specific index to certain index.
<br />

```javascript
var array = [1, 2, 3, 4];
array.splice(0, 1); // array === [2,3,4]
```

<br />

### then what is confusing point ?

그런데 이 값을 어떠한 값에 할당하면 아래처럼 제거된 배열이 아니라 제거한 해당 값을 반환한다.

But, this function return the removed value with specific index.
<br />

```javascript
var array = [1, 2, 3, 4];
var array2 = array.splice(0, 1); // array2 === [1]
```

<br />
따라서 그냥 특정 인덱스 요소를 제거하고 싶으면 할당하지 말고 그냥 쓰면 되는데, 가끔 헷갈리더라... 나만 그럴수도...
