---
layout: post
title: "TAMUCTF2019 Keygenme — Write-up"
date:   2019-05-03
categories: challenge
tags: CTF | RATF |  FLAG  |  CHALLENGE
description: Hello everybody! This is how I solved one of the many reversing problems at TAMUCTF 2019.
---

<small> <i> Tags: CTF | RATF | FLAG | CHALLENGE </i> </small>

Hello everybody! This is how I solved one of the many reversing problems at TAMUCTF 2019.

This one was Keygenme, a pretty standard kind of challenge but yet very fun to solve it.

Let’s go!

![ratf](/img/jekyll/1/ratf.png){:class="img-responsive"}
{:class="text-center"}

![ratf](/img/jekyll/4/code.png){:class="img-responsive"}
{:class="text-center"}

Let’s start by running the binary that was given to us and see what it says.

![ratf](/img/jekyll/4/code1.png){:class="img-responsive"}
{:class="text-center"}

Basically, when we run the binary it asks for a product key and if we give an incorrect one it simply shuts itself down. Then I searched for the strings inside the binary, sometimes they help us understand what the program is doing.

![ratf](/img/jekyll/4/code2.png){:class="img-responsive"}
{:class="text-center"}

By using rabin2 I was able to identify all the strings in the binary, all of them are very important so let’s take a look at them one by one

{% highlight cmd %}

	[OIonU2_<__nK<KsK

{% endhighlight %}

A pretty odd string that at the start don’t get our attention as the others, but it’s gonna be important in a moment.

{% highlight cmd %}

\nPlease Enter a product key to continue:

{% endhighlight %}

That’s the string we just saw.

{% highlight cmd %}

flag.txt

{% endhighlight %}

A string that everybody likes to see, but I don’t have a flag.txt? Do you?

{% highlight cmd %}
Too bad the flag is only on the remote server!
{% endhighlight %}

String, even if we bypassed the checking functions using the disassembler locally we would not be able to retrieve our flag because it’s been hosted remotely.

So with this quick overview of the strings, we now know that we have to create our own keygen to beat this challenge.

![ratf](/img/jekyll/4/code3.png){:class="img-responsive"}
{:class="text-center"}

Analyzing the binary with hopper disassembler there are 3 functions that get our attention

{% highlight cmd %}

0x92a P enc
0x9da P verify_key
0xa46 P main

{% endhighlight %}

It’s pretty clear what each function is doing so I’m gonna skip that whole explanation and focus on the verify_key function first.

![ratf](/img/jekyll/4/code4.png){:class="img-responsive"}
{:class="text-center"}

That part is at the beginning of the function verify_key and its job is to get our input, our “KEY”, and checks if its size is bigger than 0x9 in hexa aka 9 in decimal xd.

So, important information, we must supply a key that is longer than 9 digits, noted.

Right after this block, there’s a check to see if our input is larger than 0x40 bytes, since we will no be providing a key this long, I’m gonna skip it.

![ratf](/img/jekyll/4/code5.png){:class="img-responsive"}
{:class="text-center"}

There are a few import things we must consider on this part of the function.

<ol>
	<li>The enc function is called by verify_key and not by main.</li>
	<li>Right after enc function is called our modified key is compared to [OIonU2_<__nK<KsK
	</li>
</ol>

Now it’s clear that we have to provide some input that after it passes the enc function it has to be equal to that strange string we saw early on.

Now we have to go through the enc function and figure what it is doing with our input and reverse it.

{% highlight cmd %}
0000000000000960         mov        eax, dword [rbp+var_10]    ; CODE XREF=enc+168
0000000000000963         movsxd     rdx, eax
0000000000000966         mov        rax, qword [rbp+var_28]
000000000000096a         add        rax, rdx
000000000000096d         movzx      eax, byte [rax]
0000000000000970         movsx      eax, al
0000000000000973         lea        edx, dword [rax+0xc]
0000000000000976         movzx      eax, byte [rbp+var_11]
000000000000097a         imul       eax, edx
000000000000097d         lea        ecx, dword [rax+0x11]
0000000000000980         mov        edx, 0xea0ea0eb
0000000000000985         mov        eax, ecx
0000000000000987         imul       edx
0000000000000989         lea        eax, dword [rdx+rcx]
000000000000098c         sar        eax, 0x6
000000000000098f         mov        edx, eax
0000000000000991         mov        eax, ecx
0000000000000993         sar        eax, 0x1f
0000000000000996         sub        edx, eax
0000000000000998         mov        eax, edx
000000000000099a         imul       eax, eax, 0x46
000000000000099d         sub        ecx, eax
000000000000099f         mov        eax, ecx
00000000000009a1         lea        ecx, dword [rax+0x30]
00000000000009a4         mov        eax, dword [rbp+var_10]
00000000000009a7         movsxd     rdx, eax
00000000000009aa         mov        rax, qword [rbp+var_8]
00000000000009ae         add        rax, rdx
00000000000009b1         mov        edx, ecx
00000000000009b3         mov        byte [rax], dl
00000000000009b5         mov        eax, dword [rbp+var_10]
00000000000009b8         movsxd     rdx, eax
00000000000009bb         mov        rax, qword [rbp+var_8]
00000000000009bf         add        rax, rdx
00000000000009c2         movzx      eax, byte [rax]
00000000000009c5         mov        byte [rbp+var_11], al
00000000000009c8         add        dword [rbp+var_10], 0x1
loc_9cc:
00000000000009cc         mov        eax, dword [rbp+var_10]         ; CODE XREF=enc+52
00000000000009cf         cmp        eax, dword [rbp+var_C]
00000000000009d2         jl         loc_960
{% endhighlight %}

using this part and the hopper pseudo code:

{% highlight c %}

int enc(int arg0) {
    var_28 = arg0;
    var_8 = malloc(0x40);
    var_C = strlen(var_28);
    var_11 = 0x48;
    for (var_10 = 0x0; var_10 < var_C; var_10 = var_10 + 0x1) {
            rcx = (var_11 & 0xff) * (sign_extend_64(*(int8_t *)(var_28 + sign_extend_64(var_10)) & 0xff) + 0xc) + 0x11;
            *(int8_t *)(var_8 + sign_extend_64(var_10)) = (rcx - ((SAR(HIDWORD(rcx * 0xffffffffea0ea0eb) + rcx, 0x6)) - (SAR(rcx, 0x1f))) * 0x46) + 0x30;
            var_11 = *(int8_t *)(var_8 + sign_extend_64(var_10)) & 0xff;
    }
    rax = var_8;
    return rax;
}

{% endhighlight %}


I managed to write this whole process in python and I noticed that the next key’s value always depends on its previous neighbor. So to discover what key generates this [OIonU2_<__nK<KsK, I simply brute forced it XD.



{% highlight python %}


#!/usr/bin/env python 

enckeyFINAL = "[OIonU2_<__nK<KsK" #G>
base = 0x48
flagfinal = ""
flag2 = ""
cont = 0
chars= "'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&'()*+,-./0123456789:;<=>?@[]^_`{|}~'"
while True:
	try:		
		for i in range(len(chars)):
			rcx = (base*(int(ord(chars[i])) + 0xc)) + 0x11
			rax = hex(rcx*0xffffffffea0ea0eb)
			rax = rax[-17:]
			rax = rax[:-9]
			rax = int(rax,16)
			rax += rcx
			rax = int(hex(rax)[-5:],16)
			rax = rax >> 0x6
			ecx = rcx >> 0x1f
			rax *= 0x46
			rax = rcx - rax
			rax += 0x30
			flag2 = str(chr(rax))
			if flag2 == enckeyFINAL[cont]:
				flagfinal = flagfinal + chars[i]
				cont = cont + 1
				base = rax
				if cont == 16:
					break
	except:
    			break
print flagfinal
		 
	

	

{% endhighlight %}

[LINK BASE GITHUB][link1]{:class="btn btn-blue"}
{:class="text-center"}

[link1]: https://gist.githubusercontent.com/D4nPs/7c71f549298b7e64101133b45df4cdeb/raw/94d7270e776c192477b23393f54b11a6244fa9c8/test.py

By running this script I got

{% highlight cmd %}
GHZxSZcfov09<GNRB
{% endhighlight %}

Let’s send to the server and get our FLAG!

![ratf](/img/jekyll/4/code6.png){:class="img-responsive"}
{:class="text-center"}

Well…Maybe not 😢.

Let’s use gdb-PEDA to find out why we did not get our deserved flag.

I set up a breakpoint right before my input and that awful string are compared and I got this.

![ratf](/img/jekyll/4/code7.png){:class="img-responsive"}
{:class="text-center"}

So the program adds this “\n” and I’m not sure why.

That thing made me wonder for a while why that’s there and how to bypass it.

Then I found the solution to be very simple (and a bit of luck maybe?). This “\n” is changing into “i” because it’s after a “B”, so I have to find a character that change “\n” into “K”.

![ratf](/img/jekyll/4/code8.png){:class="img-responsive"}
{:class="text-center"}

And the “R” was there all along to save me.

![ratf](/img/jekyll/4/code9.png){:class="img-responsive"}
{:class="text-center"}

Hope you guys enjoyed it!

by me