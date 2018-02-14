---
title: "How to configure https with AWS"
date: 2018-02-09
tags: ["web-development", "https", "aws", "configuration"]
draft: false
---

## flow
1. Request a certification for SSL/TLS in ACM (AWS Certificate Manager).
2. Create ELB (Elastic Load Balancer) from EC2 management console.
3. Create EC2 instance, and connect to ELB.
4. Create record set or new hosted zone, and set alias the ELB in Route53.
5. Access SSH with the keypair that created while creating EC2 instance.
6. Now we can access public IP if we didn't configure anything in AWS console. So, connect that IP in shell.
7. Create server, routing configuration and mar-kup files.
8. DONE

<br><br>
## Step 1. Get certification for SSL/TLS
writing...