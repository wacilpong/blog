---
title: "Mushroomy's 5th Blockcahin Story"
date: "2018-10-19"
tags: ["blockchain"]
draft: false
---

## \* geth REPL (Read Eval Print Loop)

> REPL will be appeared to you if you start `startgethconsole.sh`. Practice these geth commands.

```s
miner.start()
eth.pendingTransactions
eth.getTransaction("{transaction-hash-id}")
eth.blockNumber
miner.stop()

personal.newAccount()
miner.setEtherbase(eth.accounts[1])
```

- `pendingTransacrtions`: Look at the list of pending transactions.
- `blockNumber`: Look at the current block number.
- `setEtherbase()`: Change the default account.

<br />

### - web3

> Ethereum javascript API, so, can manage ethereum blockchain transactions in web browser.

```s
Proxy {_requestManager: a, currentProvider: Proxy, eth: n, db: e.exports, shh: s, …}
```

<br />

## \* Solidity (language)

> A computer language for `smart contract` of blockchain.<br>[참고: remix.ethereum.org](http://remix.ethereum.org)

<br />

```s
pragma solidity ^0.4.25;

contract MyName {
    string myName = "Roomy";

    function getMyName() view public returns(string) {
        return myName;
    }

    function setMyName(string name) public {
        myName = name;
    }
}
```

<br />

#### 1. Access Modifier (접근제어자)

- `public`: Call from all internal/external/inharitance.
- `private`: Call only from internal.
- `external`: Call only from external contract. Variables can't set as this.
- `internal`: Call from internal/inharitance.

<br />

#### 2. Function Type (함수타입)

- `view`: Read-Only. Gas fee will be free.
- `pure`: Read (X). Gas fee will be free. Returned value will be define by argument.
- `constant`: It used instead of view/pure before `0.4.17v`.
- `payable`: have to set this when managing ethereum function. Gas fee will be surely paid.

<br />

: 이 타입을 쓰면 `msg`라는 객체를 받을 수 있다. 해당 트랜잭션을 발생시킨 사람이 `msg`가 된다.

```s
pragma solidity ^0.4.25;

contract account {
    uint private amount = 100;

    function plus() payable public {
        amount += msg.value;
    }
}
```

<br />

#### 3. Variable Type

- `bool`: true / false
- `int`: + / -
- `uint`: unsigned int. only positive number.
- `address`: ethereum account address. 0x + 40 characters. Object.

<br />

#### 4. Simple example: Smart contract

```s
pragma solidity ^0.4.24;

contract Bank {
    uint private balance = 100;
    address public myAddress;

    constructor() public {
        myAddress = msg.sender;
    }

    function deposit() payable public {
        balance += msg.value;
    }

    function withdraw(uint n) public {
        if ((balance >= n) && (msg.sender == myAddress)) {
            balance -= n;
            msg.sender.transfer(n);
        }
    }

    function getBalance() view public returns(uint) {
        return balance;
    }
}
```

- `constructor` must be public or internal. And it runs only once at initializing.
- `msg` is who generated the transaction.

<br />

## \* Creating token in your network

```s
pragma solidity ^0.4.24;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping (address => uint256) public balanceOf;
    event Transfer(address _from, address _to, uint _value);

    constructor(string tokenName,string tokenSymbol,uint8 decimalUnits,uint256 initialSupply) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value) public {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender,_to,_value);
    }
}
```

<br />

#### - Good Ref for ERC20Token

> [참고: Open Zeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts/token/ERC20)
