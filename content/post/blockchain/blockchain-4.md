---
title: "Mushroomy's 4th Blockcahin Story"
date: "2018-10-18"
tags: ["blockchain"]
draft: false
---

**_참고: Pow(채굴), PoS(이자지급), PoA, DPoS(투표선출), master node(full block + 네트워크 중계)_**

<br />

## \* Make Genesis Block Now

### 1. puppeth

`geth`설치 및 환경변수 설정까지 끝났다면 `puppeth`커맨드를 쓸 수 있다.

<br />

```s
$ mkdir test
$ cd test
~test $ puppeth

+-----------------------------------------------------------+
| Welcome to puppeth, your Ethereum private network manager |
|                                                           |
| This tool lets you create a new Ethereum network down to  |
| the genesis block, bootnodes, miners and ethstats servers |
| without the hassle that it would normally entail.         |
|                                                           |
| Puppeth uses SSH to dial in to remote servers, and builds |
| its network components out of Docker containers using the |
| docker-compose toolset.                                   |
+-----------------------------------------------------------+

lease specify a network name to administer (no spaces or hyphens, please)
> MyTest

What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2

(설정 중략)

~test $ ls
> MyTest.json
```

<br />

**_Network ID_**

- `1`: Ethereum Main Network
- `2`: Modern Test Network
- `3`: Ropsten Test Network
- `4`: Rinkeby Test Network
- `42`: Kovan Test Network

<br />

### 2. geth

#### - Init

```s
~test $ geth --datadir . init MyNetwork.json
~test $ ls

MyTest.json geth keystore
```

- geth: 블록체인에 관한 정보 디렉토리
- keystore: 계정 키 디렉토리 (private key)

<br />

#### - Create and look at the accounts list

```s
~test $ geth --datadir . account new
Password:
Repeat passphrase:

~test $ cd keystore
~test keystore $ ls

UTC--2018-10-18T11-00-04.313586000Z--{key}

~test keystore $ cd ..
~test $ geth --datadir . account list

Account #0: {block-hash} keystore:///Users/test/keystore/UTC--2018-10-18T11-00-04.313586000Z--{key}
```

<br />

## \* Make Blockchain Now (macOS)

### 1. startblockchain.sh

```s
~test $ vi startblockchain.sh

geth --datadir . --networkid 9999 --nodiscover --rpc --rpcport 8545 --rpccorsdomain "*" --rpcapi "eth,web3,personal,net" --nat any --unlock 0 --password ./password.txt
~
~
~

~test $ chmod 755 startblockchain.sh
~test $ sh startblockchain.sh or ./startblockchain.sh

INFO [10-18|21:38:19.756] Starting P2P networking
INFO [10-18|21:38:19.760] IPC endpoint opened
url=/Users/test/MyTest/geth.ipc

INFO [10-18|21:38:19.761] HTTP endpoint opened
url=http://127.0.0.1:8545

cors=* vhosts=localhost
```

1. `755` means allows all W, R, E
2. W, R, E means Writing, Reading, Executing

<br />

### 2. startgethconsole.sh

```s
~test $ vi startgethconsole.sh

geth attach ipc:/Users/test/MyTest/geth.ipc
~
~
~

~test $ sh startgethconsole.sh or ./startgethconsole.sh
```

1. Directory is the IPC endpoint url of geth
2. Copy it from terminal (startblockchain.sh)

<br />

### 3. startmist.sh

```s
~test $ vi startmist.sh

/Applications/Mist.app/Contents/MacOS/Mist --rpc /Users/test/MyTest/geth.ipc
~
~
~

~test $ sh startmist.sh or ./startmist.sh
```

1. can use `--ipc` option instead of `--rpc`.
2. But! sometimes got error for `--ipc`, IDK yet!
