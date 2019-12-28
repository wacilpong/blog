---
title: "Mushroomy's 3rd Blockcahin Story"
date: "2018-10-17"
tags: ["blockchain"]
draft: false
---
***추신: 이더리움 창시자 비탈릭 부테린(Виталик Бутерин)은 31. Jan. 1994 로, 나랑 생년월일이 똑같다 헉!***

<br />

## 3G blockchain: EOS
: Steemit, bitshare를 만든 댄 라리머가 리딩하는 암호화폐이다.

#### 1. Governance Process
- 21명의 대표를 투표를 통해 선출해 `Governance`를 진행한다.
- 비트코인이나 이더리움은 Foundation을 통해 관리되는 반면, EOS는 21명(팀)의 BP(Block Producer)들이 한다.
- 진정한 `Decentralization`을 표방한다.
- 지만 21명(팀)의 BP가 진정한 탈중앙화인가? 고민.
- 대의 민주주의라는 점은 훌륭해보이지만 실제 국회는 그렇지 않다. 고민.
- 막강한 중국파워 때문에 EOS 공식 언어는 영어이지만, 중국 BP들은 중국어를 사용한다. 고민.

#### 2. BP (Block Producer)
- 121명의 BP 후보가 있으며, 이중 21명(팀)이 BP가 되고 100명(팀)은 백업 BP가 된다.
- EOS 홀더들의 투표로 BP가 선정된다.
- EOS 보유량에 따라 투표권이 생성된다.
- 한번에 30명(팀)에게 투표 가능하며, 몰표는 불가능하다.

#### 3. DPos (Delegated Proof of Stake)
- 지분을 위임하여 관리하는 시스템이다.
- 그래서 BP 21명(팀)만이 해당 블록체인의 안건에 대해 투표해 결정할 수 있다.
- Steem, Bitshares, EOS 가 해당된다.

#### 4. Private Blockchain
- EOS는 public과 private의 중간에 위치한 블록체인이다.
- public blockchain: Bitcoin, Ethereum
- private blockchain: Ripple, Hyper Ledger (IBM)

#### 5. TPS
- 속도가 굉장히 빠르다. 거의 2초만에 트랜잭션 처리가 완료된다.
- 그래서 현재 EOS메인넷인 `eosflare.io`에 있는 주사위 굴리기 ~~(도박...)~~ 게임을 이더리움으로 시작했다가 EOS로 바꾸기도 하였다.

<br />

## Install Guide
#### (1) Ganache : [download](https://truffleframework.com/ganache)
: 스마트컨트랙트 개발을 위한 CLI가 아닌 GUI 도구

<br />

#### (2) Geth (Geth & Tools) : [download](https://ethereum.github.io/go-ethereum/downloads/)
: 이더리움을 CLI로 제어, `golang`으로 쓰여졌다.

```bash
$ cd geth-alltools-darwin-amd64-1.8.17-8bbe7207/
$ pwd
$ vi ~/.bash_profile

# geth path
export PATH=$PATH:/Users/roomy/dev/geth/geth-alltools-darwin-amd64-1.8.17-8bbe7207
~
~
~

$ source ~/.bash_profile
```

<br />

#### (3) Truffle : [download](https://www.trufflesuite.com/truffle)
: 이더리움 개발환경부터 테스팅 및 배포까지 편하게 할 수 있도록 돕는 툴이다.
> A development environment, testing framework and asset pipeline for Ethereum, aiming to make life as an Ethereum developer easier. With Truffle, you get: Built-in smart contract compilation, linking, deployment and binary management.

```bash
$ npm  install  -g  truffle”
$ truffle version
```

<br />

#### (4) VS Code Solidity Plugin
: Ethereum Solidity Language for Visual Studio Code, by Juan Blanco

<br />

#### (5) Metamask : [download](https://metamask.io/)
: 브라우저에서 이더리움 트랜잭션을 처리하기 위한 플러그인이다. 실제 주소값을 가진 지갑이다.
> A bridge that allows you to visit the distributed web of tomorrow in your browser today. It allows you to run Ethereum dApps right in your browser without running a full Ethereum node.

<br />

#### (6) Mist : [download](https://github.com/ethereum/mist/releases)
: 이더리움은 가스비용이 있기 때문에 디버깅 및 테스트를 위해 private network에 붙어서 지갑 역할을 수행하려고 만들어진 개발자용 지갑이다.
