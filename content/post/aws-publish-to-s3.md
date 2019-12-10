---
title: "Publish to aws s3 with s3cmd"
date: "2018-02-09"
tags: ["aws", "deploy"]
draft: false
---

## Create S3 bucket

Create S3 bucket with public access in aws S3 console, because it is just for testing. And add static website hosting property with `index.html` (entry point).

<br><br>

## Create CloudFront Distributions

Create in aws CloudFront console. And Just keep all settings.

<br><br>

## Connect domain with CloudFront

If you don't have routing domain in aws Route 53 console, create it first like `test.example.com`. It just depends on your url rules. Then connect with IPv4 with the CloudFront that you created.

<br><br>

## Install s3cmd

s3cmd is a command line for s3 client or backup in linux and mac. s3express is for windows user, check it. I installed it using homebrew.

```
brew install s3cmd
```

<br>
Type `s3cmd` on command line, then command list (help) will be appear.

<br><br>

## Configure s3cmd (.s3cfg)

We need to set aws access key to s3cmd to access s3 bucket.

```
s3cmd --configure
```

<br>
Many properties can be set. but now we just need to type aws access key and secret key that can be generated in aws. Then check s3 buckets that connected with your key.
```
s3cmd ls
```

<br><br>

## Publish to S3 from local

First of all, we need to build our source code. I am dealing with angular5 project, so I am using `ng` command.

```
ng build : --env prod --aot
s3cmd { put, sync } --cf-invalidate -P -r project-path/dist/* s3://test.example.com
```

<br>
If you publish for the first time, use `put` command. It will publish all files and directories. And `sync` command will publish the files and directories that only be changed. And `:` means builds all our files. `--aot`(<-> `jit`) option means ahead-of-time;build files during the build phase before the browser downloads and runs that code. `--cf` means remove all chached files in CloudFront.
