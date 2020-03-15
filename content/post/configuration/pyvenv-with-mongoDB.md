---
title: "To set virtual python environment with mongoDB"
date: "2018-02-09"
tags: ["configuration"]
draft: false
---

### Step 1. Install python and mongoDB

I am using homebrew. So it can be possible to use `brew` command. Oh, and macOS actually has a python(2.x), but I need 3.x version so I installed it.

맥에는 파이썬 2.x 버전으로 이미 설치되어 있지만, 나는 3.x버전이 필요해서 따로 설치했다. 그리고 모든 설치는 homebrew로 했다.

<br />

```s
brew install python3
```

And install mongoDB too.

<br />

```s
brew install mongodb
```

<br /><br />

### Step 2. Run mongoDB

Now we can use `mongod` command which is a command to run mongoDB ! but there is no dbpath on mongoDB, so we need to set dbpath, and it needs to contain `data/db`.

여기까지 하면 몽고디비를 실행할 수 있는 `mongod` 커맨드를 사용할 수 있다. 근데 아직 디비경로를 설정하지 않아서 에러가 뜰 것이다. 그래서 `data/db`를 포함한 디비경로를 설정해주어야 한다.

<br />

```s
mkdir your/path/data/db
```

There are many ways to set dbpath. I just set alias when running it in my case.

되게 많은 방법이 있는데, 나는 그냥 해당 커맨드에 alias를 지정해줬다.

<br />

```s
alias mongod="mongod --dbpath ~/your/path/data/db"
```

And just type `mongod` command. Now your db is running.

이제 `mongod` 커맨드를 실행하면 db가 동작될 것이다.

<br />

```s
echo "alias mongod='mongod --dbpath ~/your/path/data/db' > ~/.bashrc
source ~/.bashrc
mongod
```

That command can be set in `.bashrc` file, and it will be loaded whenever bash command is executed. Command `source` if you want to execute it.
<br />

위의 커맨드를 배쉬가 실행될 때마다 커맨드가 로드되는 `.bashrc`파일에 써도 된다. 이에 대한 실행은 `source` 커맨드를 날리면 된다.

<br />

Then mongodb will be running.

<br /><br />

### Step 3. Set up the virtual python environmemt

First of all, clone your project to local. and make directory which will be used the virtual env.

먼저, 로컬로 자기 프로젝트를 받아오자. 그 후에 그 프로젝트의 가상환경으로 사용할 폴더를 하나 만들어준다.

<br />

```s
~/dev $ git clone blahblahblah/grape
~/dev $ mkdir ~/dev/pyvenv/grape
~/dev $ python3 -m venv ~/dev/pyvenv/grape
```

Now, `grape` folder is a virtual environment. So, we can run the python project with the command in virtual env folder. In addition to, '-m' option means that run library module as a script.

이제, `grape` 폴더는 가상환경으로 쓰일 것이다. 참고로 `-m`은 스크립트로 해당 모듈을 실행하라는 옵션이다.

<br />

```s
~/dev $ cd grape
~/dev/grape $ ~/dev/pyvenv/grape/bin/python app.py
```

<br /><br />

### Step 4. Set up auto environment to the project

Thoese makes a bit annoying us, so I set up the autoenv. you need `.env` in your project directory and `.bash_profile` in your root(~).

위의 과정들은 좀 짜증나니까 이제 자동으로 우리가 설정한 가상환경으로 프로젝트를 접속할 수 있는 커맨드를 써보자. 먼저 `.env` 파일이 실제 프로젝트 경로에 있어야 하고, `.bash_profile` 파일이 루트에 있어야 한다.

- real cloned project path: ~/dev/grape
- virtual project environment path: ~/dev/pyvenv/grape

<br />

```s
~/dev/grape $ brew install autoenv
~/dev/grape $ echo "source $(brew --prefix autoenv)/activate.sh" >> ~/.bash_profile
~/dev/grape $ cd ..
~/dev $ echo "source $(pwd)/pyvenv/grape/bin/activate" >> ~/dev/grape/.env
```

Go to the real cloned project path, then you can generate autoenv now.

실제 프로젝트 경로로 가보자. 이제 자동으로 가상환경을 통해 그 프로젝트를 들어갈 수 있을 것이다.

<br />

```s
~/dev $ cd grape
~/dev $
~/dev $
autoenv: This is the first time you are about to source /Users/roomy/dev/grape/.env:
autoenv:
autoenv:   --- (begin contents) ---------------------------------------
autoenv:     $ source /Users/roomy/dev/pyvenv/grape/bin/activate $
autoenv:
autoenv:   --- (end contents) -----------------------------------------
autoenv:
autoenv: Are you sure you want to allow this? (y/N) y
(grape) Roomyui-MacBook-Pro:grape roomy $
```

If you want to exit the env, type `deactivate`.

가상환경을 끄고 싶으면 `deactivate` 커맨드를 날리면 된다.

<br /><br />

### AND... DONE !
