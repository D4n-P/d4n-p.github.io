---
layout: post
title: "TAMUCTF2019 Hello World Write-up"
date:   2019-05-03
categories: challenge
tags: CTF | RATF |  FLAG  |  CHALLENGE
description: Hey guys! This post I’ll be showing you how I solved the Hello World Challenge from TAMUCTF2019.
---

Hey guys! This post I’ll be showing you how I solved the Hello World Challenge from TAMUCTF2019.

This was a MISC challenge rated as medium difficulty by the CTF organizers.

![ratf](/img/jekyll/1/ratf.png){:class="img-responsive"}
{:class="text-center"}

![ratf](/img/jekyll/5/code.png){:class="img-responsive"}
{:class="text-center"}

I downloaded the file and used the cat command on it.

![ratf](/img/jekyll/5/code.png){:class="img-responsive"}
{:class="text-center"}

It showed something like that. That made me think, what are those blank spaces?

{% highlight cmd %}

00000000: 2020 2009 0920 2009 0909 0a20 2020 0909     ..  ....   ..                                                                                                                                                                    
00000010: 2009 2020 090a 2020 2009 0920 2009 0909   .  ..   ..  ...                                                                                                                                                                    
00000020: 0a20 2020 0909 2020 0920 090a 2020 2009  .   ..  . ..   .                                                                                                                                                                    
00000030: 0920 0909 2009 0a20 2020 0909 0909 2009  . .. ..   .... .                                                                                                                                                                       
00000040: 090a 2020 2009 0920 2020 200a 2020 2009  ..   ..    .   .                                                                                                                                                                        
00000050: 0920 0920 2020 0a20 2020 0920 0909 0909  . .   .   . .... 
00000060: 090a 2020 2009 0920 0909 2009 0a20 2020  ..   .. .. ..    
00000070: 0909 0909 2020 090a 2020 2009 2009 0909  ....  ..   . ... 
00000080: 0909 0a20 2020 0909 0920 0909 090a 2020  ...   ... ....   
00000090: 2009 0920 0920 2020 0a20 2020 0909 2009   .. .   .   .. . 
000000a0: 2020 0a20 2020 0909 0920 0920 200a 2020    .   ... .  .   
000000b0: 2009 2009 0909 0909 0a20 2020 0909 0920   . ......   ...  
000000c0: 2009 090a 2020 2009 0909 2020 2020 0a20   ...   ...    .  
000000d0: 2020 0909 2009 2020 0a20 2020 0909 2020    .. .  .   ..   
000000e0: 2009 090a 2020 2009 0920 2020 090a 2020   ...   ..   ..   
000000f0: 2009 0920 0909 0920 0a20 2020 0909 2020   .. ... .   ..   
00000100: 0909 090a 2020 2009 2009 0909 0909 0a20  ....   . ......  
00000110: 2020 0909 0909 2020 090a 2020 2009 0920    ....  ..   ..  
00000120: 2020 200a 2020 2009 0909 2009 2009 0a20     .   ... . ..  
00000130: 2020 0920 0909 0909 090a 2020 2009 0920    . ......   ..  
00000140: 0920 2020 0a20 2020 0909 2009 2020 0a20  .   .   .. .  .  
00000150: 2020 0909 0920 0909 200a 2020 2009 0920    ... .. .   ..  
00000160: 2009 090a 2020 2009 0909 0909 2009 0a20   ...   ..... ..  
00000170: 2020 0920 2020 2009 0a20 2020 0909 2020    .    ..   ..   
00000180: 0920 090a 2020 2009 0920 2020 0909 0a20  . ..   ..   ...  
00000190: 2020 0909 2020 2020 090a 2020 2009 0909    ..    ..   ... 
000001a0: 2020 2020 0a20 2020 0909 0920 2009 090a      .   ...  ... 
000001b0: 2020 2009 0920 2009 2009 0a20 2020 0909     ..  . ..   .. 
000001c0: 0920 0920 200a 2020 2009 0920 0920 2009  . .  .   .. .  . 
000001d0: 0a20 2020 0909 2009 2020 200a 2020 2009  .   .. .   .   . 
000001e0: 0909 2009 0909 0a20 2020 0920 2020 2020  .. ....   .      
000001f0: 0a20 2020 0909 2020 0909 200a 2020 2009  .   ..  .. .   . 
00000200: 0920 0909 0909 0a20 2020 0920 2020 2020  . .....   .      
00000210: 0a20 2020 0909 0920 0920 200a 2020 2009  .   ... .  .   . 
00000220: 0920 0909 0909 0a20 2020 0909 2009 0920  . .....   .. ..  
00000230: 200a 2020 2009 2020 2020 200a 2020 2009   .   .     .   . 
00000240: 0920 2020 2009 0a20 2020 0920 2020 2020  .    ..   .      
00000250: 0a20 2020 0909 0920 2009 090a 2020 2009  .   ...  ...   . 
00000260: 0920 0920 2009 0a20 2020 0920 2020 2020  . .  ..   .      
00000270: 0a20 2020 0909 2020 0920 090a 2020 2009  .   ..  . ..   . 
00000280: 0909 2020 0920 0a20 2020 0909 0920 0920  ..  . .   ... .  
00000290: 090a 2020 2009 0909 2020 0909 0a20 2020  ..   ...  ...    
000002a0: 0920 2020 2020 0a20 2020 0909 0920 0920  .     .   ... .  
000002b0: 200a 2020 2009 0920 2020 2009 0a20 2020   .   ..    ..    
000002c0: 0909 2009 2020 200a 2020 2009 0909 2009  .. .   .   ... . 
000002d0: 2020 0a20 2020 0920 2020 2020 0a20 2020    .   .     .    
000002e0: 0920 0909 2020 0a20 2020 0909 2020 0920  . ..  .   ..  .  
000002f0: 090a 2020 2009 0920 2009 2009 0a20 2020  ..   ..  . ..    
00000300: 0909 2020 0909 090a 2020 2009 2020 2020  ..  ....   .     
00000310: 200a 2020 2009 0909 0920 2009 0a20 2020   .   ....  ..    
00000320: 0909 2009 0920 200a 2020 2009 0920 0909  .. ..  .   .. .. 
00000330: 2020 0a20 2020 0909 2009 0909 090a 2020    .   .. .....   
00000340: 2009 0920 2009 0909 0a20 2020 0920 2020   ..  ....   .    
00000350: 2020 0a20 2020 0909 0920 0920 200a 2020    .   ... .  .   
00000360: 2009 0920 2009 2009 0a20 2020 0909 2020   ..  . ..   ..   
00000370: 0920 090a 2020 2009 0909 2009 0909 0a20  . ..   ... ....  
00000380: 2020 0909 0920 2009 090a 2020 2009 2020    ...  ...   .   
00000390: 2020 200a 2020 2009 0920 0909 2020 0a20     .   .. ..  .  
000003a0: 2020 0909 2009 0920 200a 2020 2009 0920    .. ..  .   ..  
000003b0: 2009 2009 0a20 2020 0920 0920 0909 090a   . ..   . . .... 
000003c0: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
000003d0: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
000003e0: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
000003f0: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000400: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000410: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000420: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000430: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000440: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000450: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000460: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000470: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000480: 090a 2020 090a 2020 090a 2020 090a 2020  ..  ..  ..  ..   
00000490: 090a 2020 090a 2020 090a 2020 0a0a 0a23  ..  ..  ..  ...# 
000004a0: 696e 636c 7564 6520 3c69 6f73 7472 6561  include <iostrea 
000004b0: 6d3e 0a75 7369 6e67 206e 616d 6573 7061  m>.using namespa 
000004c0: 6365 2073 7464 3b0a 0a69 6e74 206d 6169  ce std;..int mai 
000004d0: 6e28 290a 7b0a 0963 6f75 7420 3c3c 2022  n().{..cout << " 
000004e0: 4865 6c6c 6f2c 2057 6f72 6c64 7321 5c6e  Hello, Worlds!\n 
000004f0: 223b 0a09 7265 7475 726e 2030 3b0a 7d0a  ";..return 0;.}.

{% endhighlight %}

Using the xxd command and the hexadecimal of this file was shown.

Those strange ‘20’ and ‘09’ and ‘0a’ gotta mean something. After analyzing for a couple of minutes I noticed that the ‘0a’ repeats itself always after 10 spaces.

So I imagined this should be a binary encoded string where ‘20’ = 0 , ‘09’ = 1 and ‘0a’ = space. So I wrote a small python script to extract the flag!

{% highlight python %}

#!/usr/bin/env python

flagenc = open("flagenc.txt", "rwa")
support=""
support2 = ""
for line in flagenc.readlines():
	line = line[10:-17]
	line = line.replace("20", "0")
	line = line.replace("09", "1")
	line = line.replace(" ", "")
	line = line.replace("0a", " ")
	support = support + line	
support = support.split(" ")

for i in range(0,136):
	flagenc2 = int(support[i],2)
	if flagenc2 == 1:
		break
	flagenc3 = str(chr(flagenc2))
	support2 = support2 + flagenc3

print "[+]FLAG:"+ support2

{% endhighlight %}

[LINK BASE GITHUB][link1]
{:class="text-center"}

[link1]:https://gist.githubusercontent.com/D4nPs/e206fcf9109159b823041e25452263d6/raw/7a564de46c45724270c41f1e7a4f12c4c0553a24/hello.py

![ratf](/img/jekyll/5/code2.png){:class="img-responsive"}
{:class="text-center"}

Hope you guys enjoyed it!

by me