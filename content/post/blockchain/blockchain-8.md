---
title: "Mushroomy's 8th Blockcahin Story"
date: "2018-10-24"
tags: ["blockchain"]
draft: false
---

**_[해결되기 어려운 블록체인 문제, Oracle Problem?](https://steemkr.com/kr/@kblock/39)_**

## Cosmos

- `Interchain`: 수많은 코인이 있고, 이들을 연결하려고 하는 개념
- `BIA`: Blockchain Interoperablility Alliance `ex) Aion, iCon, wanchain`
- `Cosmos`: internet of interchain

<br />

### dApp

```s
---------------------------
- [dApp] [dApp]...        -
- Application(EVM)        -
- Consensus               -
- Networking              -
---------------------------
```

- 이렇게 dApp을 EVM에 올려서 만들다보니 의존성이 생긴다.
- Networking, Consensus 레이어를 만드는 것이 힘들었다.
- 이 레이어들은 자원을 투자한다고 빨리 만들 수 있는 부분이 아니다.
- 따라서 코스모스는 `1dApp = 1Blockchain`을 실현시키기 위해 만들었다.

<br />

## Tendermint

- 코스모스의 엔진으로, cosmos sdk를 제공
- `Cosmos SDK`: 쉽게 dApp을 만들 수 있도록 해주는 일종의 프레임워크
- [참고: Cosmos document - KR](https://cosmos.network/docs/resources/whitepaper-ko.html#%EC%BD%94%EC%8A%A4%EB%AA%A8%EC%8A%A4-%EA%B0%9C%EC%9A%94-cosmos-overview)

#### 1. 만들어진 이유?

- 복잡한 가상머신(VM) 블록체인

  - call stack limit (DAO bug) / DelegateCall (parity bug) / Contract suicide (parity bug)
  - 개발할 수 있는 언어가 제한적 `ex) Solidity, Serpent`

- Application 특화 블록체인
  - 코스모스로 dApp을 만들면 application 개발에만 신경쓰면 된다.
  - Networking, Consensus 레이어에 대해 고민할 필요가 없다.
  - 자연스럽게 자주적인 개발이 가능하다.
    - 그동안 자체 코인, 블록체인을 만들기 위해서는 `bitcoin`을 포크하여 작성해야 했다.
    - 하지만 코스모스를 통하면 public은 `POS`방식으로, private은 `POA`방식으로 개발하기만 하면 된다.
    - `POS`: 확률적인 블록 생산 / `POA`: Hashing power game

<br />

#### 2. Ethereum problem

**_- Nothing-at-stake problem_**

- 블록체인에 포크가 발생하여 노드가 선택할 때, 두 체인에 모두 투표해도 이 노드가 손실되는 부분이 없는 문제
- 즉, `POS`방식은 확률적으로 블록을 생산하므로 해커가 몰래 만든 블록체인에서 새 노드를 전파할 수 있다.
- 그러면 이때 포크가 발생할 수 있고, 어떤 블록체인에 투표하든 이 노드에는 불리한 점이 없다.
- 따라서 해커가 만든 블록체인과 실제 블록체인 사이의 포크상황이 쉽게 해결되지 않는다.

**_- PBFT (Practical Byzantine Fault Tolerance)_**

- 비동기 네트워크에서 배신자 노드가 f개 있다고 하자.
- 이때 총 노드 개수가 3f+1개 이상이면 해당 네트워크에서 이루어지는 합의는 신뢰할 수 있다.
- 이를 증명한 알고리즘이 바로 PBFT

<br />

-> 그러나 코스모스를 통하면 이러한 문제점, 즉 `uncle blockchain`이 발생할 수 없다.<br>
-> 코스모스는 반드시 2개의 노드 중 하나만이 선택되는 구조이다.

<br />

#### 3. Hard Spoon 개념 (<-> Hard Fork)

- 기존의 블록체인 계정 잔고를 복제하여 새로운 암호화폐 발행
- 즉, two chain + same ledger + but, the other consensus algorithm each other

<br />

#### 4. Cosmos Ecosystem

- 코스모스는 Pool 개념이다.
- 코스모스의 최초 블록체인이 곧 `Cosmos Hub`가 된다. 이후에 형성될 허브들은 `Peer Hubs`
- `Go-Ethereum`, `ZCash` 등의 임의의 블록체인 시스템으로부터 파생된 존들이 이 허브에 연결될 수 있다.
- 이러한 존들은 탈중앙화 거래소(distributed exchange)에도 매우 적합하다. `ex) 오미세고 (OMG)`
- 그래서 dApp에서 어떤 코인이 필요하든, 지갑에서 코인을 꺼내어 특정 코인으로 변환하는 과정 자체가 필요없다.
- 물론, 거래 및 환전의 경우 코스모스 생태계에 해당 코인의 물량이 있어야만 가능하다.
- `Peg Zone (Bridge Zone)`: 서로 다른 암호화폐를 코스모스 네트워크로 유통시키는 방법
  - 이더리움 자체가 코스모스 블록체인으로 쌓이는 것이지, `이더민트(Ethermint)`로 변환되는 것이 아니다.
  - 이더민트는 Tendermint 위에서 돌아가는 이더리움이다.

<br />

#### 5. Atom Token

- 코스모스 허브는 아톰토큰을 가지며, 이는 코스모스 허브의 유일한 지분토큰(staking token)이
- 아톰은 보유자가 투표 및 검증 또는 다른 검증인들에게 위임을 하기 위해 필요

<br />

#### 6. 검증인 (Validators)

- 100명(팀)
- 가지고 있는 `atom`코인 물량에 비례하여 선정

<br />

#### 7. on-chain governance

- 과반수 이상의 찬성 또는 'yea with force' 시 제안서가 통과된다.
- 그러나 1/3+는 'nay with force'를 통해 다수결을 거부할 수 있다.
- 이렇게 거부된 경우 모두가 `거부권 패널티 수수료 블록(VetoPenaltyFeeBlocks)`을 통해 수수료를 상실한다.
- 따라서 '처벌(slashing)' 받음: 디폴트 1일 가치의 블록
- 당사자는 `거부권 패널티 아톰(VetoPenaltyAtoms)`를 추가로 상실: 디폴트 0.1%

<br />

![cosmos-internet-of-interchain](/images/cosmos-interchain.png)
