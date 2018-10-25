---
title: "Mushroomy's 9th Blockcahin Story"
date: "2018-10-25"
tags: ["blockchain"]
draft: false
---

## Truffle Command
1. 설치 및 버전 확인: 아래의 버전내용이 뜨지 않으면 `npm i -g truffle`로 설치하자.

<br>
```
test $ truffle --version

Truffle v4.1.14 (core: 4.1.14)
Solidity v0.4.24 (solc-js)
```

<br>
2. 트러플 프로젝트 초기화 과정
```
test $ truffle init

Downloading...
Unpacking...
Setting up...
Unbox successful. Sweet!

Commands:

Compile:        truffle compile
Migrate:        truffle migrate
Test contracts: truffle test

test $ ls -al

drwxr-xr-x  7 test  staff   224B Oct 25 19:54 .
drwxr-xr-x  4 test  staff   128B Oct 25 19:31 ..
drwxr-xr-x  3 test  staff    96B Oct 25 19:54 build
drwxr-xr-x  4 test  staff   128B Oct 25 19:54 contracts
drwxr-xr-x  4 test  staff   128B Oct 25 19:44 migrations
drwxr-xr-x  2 test  staff    64B Oct 25 19:31 test
-rw-r--r--  1 test  staff   545B Oct 25 19:31 truffle-config.js
-rw-r--r--  1 test  staff   545B Oct 25 19:31 truffle.js
```

<br>
3. 스마트 컨트랙트 생성
```
test $ cd contracts
contracts $ vi MyName.sol


pragma solidity ^0.4.24;

contract MyName {
    string myName = "JongKwang Coin";

    function getMyName() constant public returns(string) {
        return myName;
    }

    function setMyName(string newMyName) public {
        myName = newMyName;
    }
}
~
~
~
~
:wq

contracts $ ls -al

drwxr-xr-x  4 test  staff  128 Oct 25 19:54 .
drwxr-xr-x  7 test  staff  224 Oct 25 20:05 ..
-rw-r--r--  1 test  staff  507 Oct 25 19:31 Migrations.sol
-rw-r--r--  1 test  staff  244 Oct 25 19:54 MyName.sol
```

<br>
4. 마이그레이션 파일 생성 (for deploying)
```
test $ cd migrations
migrations $ vi 2_deploy_myname.js

var myName = artifacts.require("./MyName.sol");
module.exports = function(deployer) {
        deployer.deploy(myName);
};
~
~
~
~
~
:wq

migrations $ ls -al

drwxr-xr-x  4 test  staff  128 Oct 25 20:09 .
drwxr-xr-x  7 test  staff  224 Oct 25 20:05 ..
-rw-r--r--  1 test  staff  129 Oct 25 19:31 1_initial_migration.js
-rw-r--r--  1 test  staff  116 Oct 25 19:44 2_deploy_myname.js
```

<br>
- 마이그레이션 파일은 반드시 순서대로 만들어져야 한다. `1, 2, 3...`
- 대소문자는 상관없지만 `under bar(_)`로 이루어져야 한다.

<br>
5. 개발환경 구성
```
test $ truffle develop

Truffle Develop started at http://127.0.0.1:9545/

Accounts:
{10개 생성됨}

Private Keys:
{10개 생성됨}

Mnemonic: candy maple cake sugar pudding cream honey rich smooth crumble sweet treat

⚠️  Important ⚠️  : This mnemonic was created for you by Truffle. It is not secure.
Ensure you do not use it on production blockchains, or else you risk losing funds.

truffle(develop)>
truffle(develop)>
```

<br>
6. 배포 (한 번만 하면 됨)
```
truffle(develop)> migrate

Compiling ./contracts/Migrations.sol...
Compiling ./contracts/MyName.sol...
Writing artifacts to ./build/contracts

Using network 'develop'.

Running migration: 1_initial_migration.js
  Deploying Migrations...
  ... {hash}
  Migrations: {hash}
Saving successful migration to network...
  ... {hash}
Saving artifacts...
Running migration: 2_deploy_myname.js
  Deploying MyName...
  ... {hash}
  MyName: {hash}
Saving successful migration to network...
  ... {hash}
Saving artifacts...
```

<br>
## Truffle (with Web3 API)
```
ttruffle(develop)> web3.eth

Eth {
  _requestManager:
   RequestManager {
     provider:
      HttpProvider {
        host: 'http://127.0.0.1:9545/',
        timeout: 0,
        user: undefined,
        password: undefined,
        headers: undefined,
        send: [Function],
        sendAsync: [Function],
        _alreadyWrapped: true },
     polls: {},
     timeout: null },
  getBalance:

  ... (생략)...

```

<br>

- truffle은 `web3` API를 사용하므로 해당 명령어 사용가능
- command ex)

```
1. MyName.deployed().then(function(instance) { app = nstance; })
2. web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]), "ether")
3. app.setMyName("Han", {from: web3.eth.accounts[1]})
4. app.getMyName()
```

- MyName 컨트랙트를 `app`이라는 전역변수로 설정
- 두번째 지갑 잔액 보기
- 컨트랙트 내부 함수설정 + 가스비 지불은 2번째 지갑에서
- 컨트랙트 내부 함수호출

<br>
## Ganache
<center>![ganache](/blog/ganache.png)</center>