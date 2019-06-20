---
title: "Mushroomy's 6th Blockcahin Story"
date: "2018-10-22"
tags: ["blockchain"]
draft: false
---

## * Gas Fee
- 트랜잭션을 처리하는 데 사용되는 수수료 (송금 / 스마트컨트랙트 배포 및 수정)
- 채굴자가 받게 된다.
- `GWEI`라는 단위를 사용한다.
- 사용한 gas x gas price, 하지만 gas limit이 존재하여 이를 넘지 못한다.

<br>
***채굴자가 받는 보상 ?***

1. 블록 생성 보상
2. 엉클 블록 보상
3. gas fee

<br>
## * Token
#### 1. ERC20
- 이더리움의 토큰으로서 지녀야 할 필수 기능들을 정의한 것이다.
- 대체 가능하다. 즉, 두 사람이 `ERC20` 토큰을 갖고 있다면 서로 교환가능하다.

<br>
```
Methods: name, symbol, decimals, totalSupply, balanceOf, transfer, transferFrom, approve, allowance
Events: Transfer, Approval
```

<br>
### 2. ERC721
- 대체 불가능하다. 즉, 두 사람이 `ERC721` 토큰을 갖고 있어도 서로 교환할 수 없다.
- 유니크한 수집품을 블록체인에 담을 때 사용할 수 있다.
  - ex) 예술품, [Crypto Kitties](https://www.cryptokitties.co/) 등...

<br>
## Ganache
> 지금까지 geth, puppeth 등의 커맨드를 통해 개발했던 것을 통합적으로 관리할 수 있게 해주는 GUI

<br>
## Open Source
- 공개된 source code
- 코드 뿐만 아니라 기획 및 의도, 매뉴얼, 사후관리까지 모두 공개되어 있어야 한다.

<br>
***오픈 소스를 하는 이유?***

- 개발의 패러다임이 바뀌고 있다.
- '나의 코드를 더 많은 사람이 쓰는 것'이 좋다.
- 1명보다 10억 명이 보는 것이 더 정확, `집단지성`의 힘!
- `Github`의 오픈소스 사례
  - [서울 정보소통광장 행정정보](https://github.com/seoul-opengov/opengov)
  - [백악관 각종 정보](https://github.com/WhiteHouse/budgetdata)
  - [고위 공부원 재산정보](https://github.com/codenamu/official-assets-explorer-2017)