---
title: "How to set virtual python environment with mongoDB"
date: 2018-02-09
tags: ["web-development", "python", "mongoDB", "configuration"]
draft: false
---

## Step 1. Install python and mongoDB
I am using homebrew. So it can be possible to use `brew` command. Oh, and macOS actually has a python(2.x), but I need 3.x version so I installed it.

```
brew install python3
```

<br>
And install mongoDB too.
```
brew install mongodb
```

<br><br>
## Step 2. Run mongoDB
Now we can use `mongod` command which is a command to run mongoDB ! but there is no dbpath on mongoDB, so we need to set dbpath, and it needs to contain `data/db`.

```
mkdir your/path/data/db
```

<br>
There are many ways to set dbpath. I just set alias when running it in my case.
```
alias mongodb="mongod --dbpath ~your/path/data/db"
```

<br>
And just type `mongod` command. Now your db is running.

<br><br>
## Step 3. Set up the virtual python environmemt
First of all, clone your project to local. and make directory which will be used the virtual env. example is like this :

```
~/dev $ git clone blahblahblah/grape
~/dev $ mkdir ~/dev/pyvenv/grape
~/dev $ python3 -m venv ~/dev/pyvenv/grape
```

<br>
Now, `grape` folder is a virtual environment. So, we can run the python project with the command in virtual env folder. In addition to, '-m' option means that run library module as a script.
```
~/dev $ ~/dev/pyvenv/grape/bin/python app.py
```

<br><br>
Writing...