---
layout: post
title:  "TAMUCTF2019 PWN3 Write-up"
date:   2019-05-03
categories: challenge
tags: CTF RATF FLAG CHALLENGE
description: Hey Guys! This post i’ll be showing you how I managed to solve PWN3 challenge from TAMUCTF2019! Let’GO!
---

Hey Guys! This post i’ll be showing you how I managed to solve PWN3 challenge from TAMUCTF2019!
This was a standard stack execution where we had to insert our shellcode in the stack and point ou EIP there to execute it. Let’GO!

![ratf](/img/jekyll/1/ratf.png){:class="img-responsive"}

![code example](/img/jekyll/1/example.png){:class="img-responsive"}

Let’s execute the binary locally to see what happens.

![code example](/img/jekyll/1/code1.png){:class="img-responsive"}

After sending a lot of bytes we get a “seg fault” and that’s what we want. Using GDB let’s find out how many bytes we must send to control EIP.

{% highlight ruby %}

gdb-peda$ pattern_create 400
'AAA%AAsAABAA$AAnAACAA-AA(AADAA;AA)AAEAAaAA0AAFAAbAA1AAGAAcAA2AAHAAdAA3AAIAAeAA4AAJAAfAA5AAKAAgAA6AALAAhAA7AAMAAiAA8AANAAjAA9AAOAAkAAPAAlAAQAAmAARAAoAASAApAATAAqAAUAArAAVAAtAAWAAuAAXAAvAAYAAwAAZAAxAAyAAzA%%A%sA%BA%$A%nA%CA%-A%(A%DA%;A%)A%EA%aA%0A%FA%bA%1A%GA%cA%2A%HA%dA%3A%IA%eA%4A%JA%fA%5A%KA%gA%6A%LA%hA%7A%MA%iA%8A%NA%jA%9A%OA%kA%PA%lA%QA%mA%RA%oA%SA%pA%TA%qA%UA%rA%VA%tA%WA%uA%XA%vA%YA%wA%ZA%xA%y'

Legend: code, data, rodata, value
Stopped reason: SIGSEGV
0x25416825 in ?? ()
gdb-peda$ pattern_search
Registers contain pattern buffer:
EBX+0 found at offset: 294
EBP+0 found at offset: 298
EIP+0 found at offset: 302
Registers point to pattern buffer:
[EAX] --> offset 0 - size ~203
[ESP] --> offset 306 - size ~94

{% endhighlight %}


Using pattern_search we discover that offset is 302 bytes long. Cool valuable information there, but where is our ESP? Since that value keeps changing when we connect via netcat ASLR is on, so it gets hard to know where to point to. So we need to discover what is the address that pops up when the program is executed.

Running a few times in different environments I noticed that we can use this address to determine the exact position of our ESP, because that address + 0x132 = $ESP


{% highlight ruby %}

Starting program: /root/ctf/tamu/pwn3/pwn3 
Take this, you might need it on your journey 0xffffd01e!

gdb-peda$ x/5wx $esp
0xffffd150: 0x4d254137 0x41692541 0x25413825 0x6a25414e

So, by doing 0xffffd150 - 0xffffd01e = 0x132

{% endhighlight %}

Cool! Now we have everything set, let’s create our exploit.

Got my shellcode from shellstorm.com

![code example](/img/jekyll/1/code2.png){:class="img-responsive"}

Hope you guys enjoyed it!

by me