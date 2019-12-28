---
title: "To configure https with AWS"
date: "2018-02-09"
tags: ["aws", "https"]
draft: false
---

## _flow_

1. Request a certification for SSL/TLS in ACM (AWS Certificate Manager).
2. Create ELB (Elastic Load Balancer) from EC2 management console.
3. Create EC2 instance, and connect to ELB.
4. Create record set or new hosted zone, and set alias the ELB in Route53.
5. Access SSH with the keypair that can be generated while creating EC2 instance.
6. Now we can access public IP if we didn't configure anything in AWS console. So, connect that IP in shell.
7. Create server, routing configuration and mark-up files.
8. DONE

<br /><hr>

### Step 1. Get certification for SSL/TLS

**(1)** Add domain names which would be protected. I set `asteric(*)` as I have similiar domains.

인증서를 적용할 도메인을 입력한다. 나는 `*.example.com`처럼 동일한 형식의 도메인이 있었기에 `asteric(*)`을 지정했다.

<br />

**(2)** Select validation method, but I think people usually select Email. Then AWS will send the validation email to Domain registrant, Technical contact, Administrative contact, not an IAM (Identity and Access Management) account.

입력한 도메인의 유효검사 방식을 선택하는데, 보통 이메일로 하는 것 같다. 체크한 후에는 IAM (Identity and Access Management) 계정이 아니라 도메인 등록자, 기술담당자, 관리자 계정으로 이메일이 발송되니까 유의하자.

<br />

**(3)** Check email validation, then certificate will be issued successfully.

이메일에서 유효검사를 마치면 입력한 도메인에 대한 인증서가 발급된다.

<br /><br />

### Step 2. Create Load Balancer

**(1)** writing...
