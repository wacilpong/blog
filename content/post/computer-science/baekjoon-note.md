---
title: "백준 알고리즘을, 특히 파이썬으로 풀면서 참고할 것들 정리"
date: "2024-01-20"
tags: ["computer-science"]
draft: false
---

## 입력 참고
```python
input = sys.stdin.readline

# 정수 하나를 받을 때
a = int(input())

# 띄어쓰기한 두 정수를 받을 때
a, b = map(int, input().split())

# 띄어쓰기한 두 정수를 받아서 마지막 수만큼 배열로 채울 때
arr = [list(map(int, input().split())) for _ in range(b)]
```

## 파이썬 문법과 내장함수
```python
# 파이썬은 문자열도 곱셈이 된다.
>>> a = "python"
>>> a * 2
'pythonpython'

# 파이썬의 전개연산(ex. [...memo_result, number])은 더하면 된다.
memo_result + [number]

# 반복문에서 index, value 동시 접근하고 싶을 때: 튜플
for i, value in enumerate(arr):

# 배열 슬라이싱
>>> a = [1, 2, 3, 4, 5]

>>> b = a[0:2] # 0번째부터 2번째 인덱스 전까지
[1, 2]

>>> c = a[:2] # 2번째 인덱스 전까지 전부
[1, 2]

>>> d = a[2:] # 2번째 인덱스부터 전부
[3, 4, 5]
```