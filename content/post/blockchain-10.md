---
title: "Mushroomy's Last Blockcahin Story"
date: "2018-10-26"
tags: ["blockchain"]
draft: false
---

## Truffle Tutorial: Pet Shop
솔직히 문서가 너무 잘되어 있어서 주요 내용+커맨드만 정리한다.
<br>
https://truffleframework.com/tutorials/pet-shop

<br>
#### 1. init vs unbox
- `truffle init`: Create empty truffle project without example contracts.
- `truffle unbox`: Unpack the exising truffle project.

<br>
#### 2. pragma^ ?
- means "additional information that only the compiler cares about".
- the caret symbol (^) means "the version indicated or higher.

<br>
#### 3. Need to compile ?
- 솔리디티는 컴파일된 언어이므로, `EVM`이 이해하도록 만들어야 한다.
- 따라서 솔리디티를 바이트코드로 변환하는 과정이 필요하다.
- Translating our human-readable Solidity into something the EVM understands.

<br>
#### 4. migration
- means deployment script meant to alter the state of your application's contracts.
- 최초 한번만 하면 되고, 이후에는 데이터를 이동시키거나 새로 덮어쓴다.
- 이후 테스트:

<br>
<center>![truffle-test](/blog/truffle-test.png)</center>

<br>
#### 5. Meta Mask
- 가입할 때 wallet seed에 ganache에서 만들어진 `mnemonic`을 넣어야 한다.
- `mnemonic`: A special secret created for you by Ganache.
<br>
<center>![mnemonic](/blog/mnemonic.png)</center>

- `custom RPC (http://127.0.0.1:7545)`를 설정하는 이유는 메인넷이 아닌 private net에서 테스트하기 위함이다.

<br>
#### 6. Run dapp (pet shop)
- `npm run dev` in root dir

<br>
<center>![truffle-run](/blog/truffle-run.png)</center>

<br>
<center>![truffle-test](/blog/pet-shop.png)</center>

<br>
## Open Zeppelin
> Zeppelin Solutions, a smart contract auditing service, has recognized this need. Using their experience, they've put together a set of vetted smart contracts called OpenZeppelin.

<br>
[참고: Robust Smart Contracts with Openzeppelin](https://truffleframework.com/tutorials/robust-smart-contracts-with-openzeppelin)