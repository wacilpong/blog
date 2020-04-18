---
title: "When we connect ssh with .pem"
date: "2018-04-03"
tags: ["configuration"]
draft: false
og_description: "We sometimes need to connect to computer in other network. It is necessary the key like pem(Private Enhanced Mail) When we connect."
---

We sometimes need to connect to computer in other network. It is necessary the key like pem(Private Enhanced Mail) When we connect. I will just write the flow about it.

<br />

## _flow_

1. Generate `.pem` key (I am using AWS).
2. Change mode of `.pem` file to 400 to read it.
3. Identify file and connect to ssh (AWS linux for me).
4. DONE

<br /><hr>

## Change permission of file

I will change mode of key file and connect to ssh with it.

<br />

```s
~ $ ls -alh

drwxr-xr-x 6 roomy staff 192B Apr 3 10:09 .
drwxr-xr-x+ 41 roomy staff 1.3K Apr 3 10:10 ..
-rw-r--r--@ 1 roomy staff 1.7K Apr 3 10:54 test.pem
-r--------@ 1 roomy staff 1.7K Feb 13 18:02 dev.pem

```

`test.pem` file has -rw-r--r-- permission. It can be separated like -, rw-, r--, r--. The first `-` means a file. and `d` is for directory. Then second 3 bits are for owner, third is for group, and the last is for other. So all users can read `test.pem` file, as `r` means read, `w` means write and `x` means execute.

<br />

```s
~ $ chmod 400 test.pem
~ $ ls -alh

drwxr-xr-x 6 roomy staff 192B Apr 3 10:09 .
drwxr-xr-x+ 41 roomy staff 1.3K Apr 3 10:10 ..
-r--------@ 1 roomy staff 1.7K Apr 3 10:54 test.pem
-r--------@ 1 roomy staff 1.7K Feb 13 18:02 dev.pem

```

Now the only owner can read that private key file.

<br /><br /><hr>

## Connect to ssh

I simply connect to server with ssh command. `-i` option means identify file using key.

```s
~ \$ ssh -i ~/.ssh/test.pem ec2-user@example.com

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
\$

```
