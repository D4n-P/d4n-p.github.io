---
layout: post
title: "HACKAFLAG CAMPINAS Reverse & Misc Write-up"
date:   2019-04-18
categories: challenge
tags: CTF | FLAG  |  CHALLENGE
description: Fala galera! até o dia 17/04 rolou a 1ª etapa do Hackaflag 2019.Consegui a 4ª colocação nesse etapa e os desafios foram bem legais.
---

<small> <i> Tags: CTF | RATF | FLAG | CHALLENGE </i> </small>

Fala galera! até o dia 17/04 rolou a 1ª etapa do Hackaflag 2019.Consegui a 4ª colocação nesse etapa e os desafios foram bem legais.

![image example](/img/jekyll/7/code.png){:class="img-responsive"}
{:class="text-center"}

Resolvi trazer esses dois porque foram os que achei mais divertidos de resolver.

PS: Esses foram os métodos que usei para resolver, talvez não os melhores, mas com certeza cheguei nas flags xd

![image example](/img/jekyll/1/ratf.png){:class="img-responsive"}
{:class="text-center"}

1 Desafio -> MISC

<i>Descrição: Por mais pequeno que seja, esse desafio vem com a missão de fazer você conhecer um formato de arquivo EPS e entender como ele é composto.</i>

Além dessa breve descrição nos é dado um arquivo para download. Vamos analisá-lo.


{% highlight cmd %}
[~/ctf/hackaflag/misc]$ file flag                                            
flag: DOS EPS Binary File Postscript starts at byte 30 length 68473 
TIFF starts at byte 68503 length 2317330
{% endhighlight %}


Bem como disse a descrição, temos um arquivo EPS, mas ainda não conseguimos abri-lo porque no próprio retorno do comando file ele nos diz que o EPS começa no byte 30.

![image example](/img/jekyll/7/code2.png){:class="img-responsive"}
{:class="text-center"}

Precisamos remover esses 30 primeiros bytes. Vamos usar o comando ‘dd’ para isso.

{% highlight cmd %}
dd if=flag of=flag.eps ibs=30 skip=1
{% endhighlight %}

Agora quando rodamos o comando ‘file’ novamente já nos é retornado outra coisa

{% highlight cmd %}
[~/ctf/hackaflag/misc/writeup]$ file flag.eps                                               
flag.eps: PostScript document text conforming DSC level 3.0, type 
EPS, Level 2
{% endhighlight %}

Vamos tentar abrí-lo com o programa <b>Inkscape</b>

![image example](/img/jekyll/7/code3.png){:class="img-responsive"}
{:class="text-center"}

Erro, pois ainda no arquivo há um tiff como vimos la no primeiro ‘file’ que demos.

Para retirá-lo, vamos usar o comando ‘truncate’

{% highlight cmd %}
[~/ctf/hackaflag/misc/writeup]$ truncate -s 68395 flag.eps
{% endhighlight %}

Agora ao abrí-lo com o Inkscape, temos

![image example](/img/jekyll/7/code4.png){:class="img-responsive"}
{:class="text-center"}

Essa imagem.

Essa parte é sem dúvida a pior do desafio, achar onde diabos está a flag aqui.Passei horas, cheguei a pensar que a flag não estivesse na imagem de tanto procurar, mas ela está ai. Uma parte da definição de uma EPS file diz isso:

<i>It is more like a postscript program that instructs images and drawings to be placed on a document</i>

Então pesquisei em formas de manipular essas imagens presentes e uma delas me ajudou, o XML Editor.

Até que

![image example](/img/jekyll/7/code5.png){:class="img-responsive"}
{:class="text-center"}

Ta aí a coisa.

Pegando todos os chars temos:

![image example](/img/jekyll/7/code6.png){:class="img-responsive"}
{:class="text-center"}

{% highlight cmd %}
HACKAFLAG{ESCOND_DO_NO_L_MBO}
{% endhighlight %}

O que não é a flag final, mas é fácil ver que a flag fica…

{% highlight cmd %}
HACKAFLAG{ESCONDIDO_NO_LIMBO}
{% endhighlight %}

2 desafio -> REVERSE

Desafio mais complicado dessa primeira etapa, foi o que teve menos solves. Por assumir coisas erradas demorei muito mais tempo do que precisava para resolver esse desafio, mas no fim deu tudo certo.

Descrição: Consegue me ajudar?

Além da descrição nos é dado um binário, campinas.exe. Um binário windows, vamos executá-lo.

![image example](/img/jekyll/7/code7.png){:class="img-responsive"}
{:class="text-center"}

De cara já temos nossa flag em b64 somente *-* , sqn xd

Joguei o binário no Ghidra para ver do que se tratava.

![image example](/img/jekyll/7/code8.png){:class="img-responsive"}
{:class="text-center"}

Analisando as funções vemos uma bem interessante, Criptografar.

![image example](/img/jekyll/7/code9.png){:class="img-responsive"}
{:class="text-center"}

Mas está muito complicado de analisá-la assim, fui atrás de ver as strings para ver se encontrava alguma luz.

![image example](/img/jekyll/7/code10.png){:class="img-responsive"}
{:class="text-center"}

Analisando notei essa que dizia “.NET framework 4.6.1” e eu sei que consigo usar decompiler nesses sistemas, no caso usei o dotPeek da JetBrains e consegui o código descompilado da função Criptografar.

![image example](/img/jekyll/7/code11.png){:class="img-responsive"}
{:class="text-center"}

Analisando passo a passo do código

<ul>
	<li>Primeiro é feito uma requisição para essa string em hexa mas em uma formatação estranha, depois é passado outros parâmetros como método, ContentType, etc, quem não nos interessa.</li>
	<li>Depois ele pega o conteúdo recebido do servidor e joga no MD5cryptoServiceProvider, ou seja, gera um md5 do retorno.</li>
	<li>Após isso, é criado um TripleDESCryptoServiceProvider que tem como um dos parâmetros a chave, que é a hash md5 que foi gerado a pouco.</li>
	<li>Ao final retorna a flag em base64 como vimos ao rodar o programa.</li>
</ul>

Nossa primeira e mais difícil tarefa será descobrir o endereço dessa requisição para conseguir nossa chave.

Vemos que a string encodada passada está em servindo de parâmetro para outra função, vamos analisá-la, a class8_metho0, no meu caso.

No caso a class8_method0 só faz uma checagem de data e retorna a string para a class9_method0

![image example](/img/jekyll/7/code12.png){:class="img-responsive"}
{:class="text-center"}

Fiz uma pequena alteração no código e rodei a função passando a string e o inteiro que vi na função <b>Criptografa</b>.

E me é retornado isso:

{% highlight cmd %}
xdd`c*??xqs{qv|qw>s}>rb?sdv?tucqvyc?!qt(vt”tvrr qts !%t’r#%q$”rr)r()?s}}q~ts~db|>`x`
{% endhighlight %}

wtf is isso?

Notei que eu estava esperando uma url e resolvi comparar, notemos que podemos fazer <code>ascii(x) — 16 -> h ascii(d) +16 -> t ascii(`)-> p ascii(c) + 16-> s</code> daí ja conseguimos o ‘https’

Eu realmente espero do fundo do coração que haja um método melhor de resolver do que esse T.T
Ao terminarmos de decodar:

[https://hackaflag.com.br/ctf/desafios/1ad8fd2dfbb0adc015d7b35a42bb9b89/commandcontrol.php][linkhackaflag]{:class="text-white"}
{:class="text-center"}

[linkhackaflag]: https://hackaflag.com.br/ctf/desafios/1ad8fd2dfbb0adc015d7b35a42bb9b89/commandcontrol.php

Acessando esse link encontramos nossa chave.

{% highlight cmd %}
THMPV-77D6F-94376–8HGKG-VRDRQ
{% endhighlight %}

Depois disso devemos lembrar que a chave foi encodada em b64 para fazer criptografar nossa flag.

Então,

<ul>
	<li>Criptografia TripleDES</li>
	<li>Modo ECB</li>
	<li>chave = d5637a2c7e17f17947df72f5b3d3d20c</li>
	<li>flag = YMP1zrjTmr1P0wVJh7ocL55O5ZY3EYec</li>
</ul>

Já temos tudo!

Usei essa ótima ferramenta online para conseguir a flag.

![image example](/img/jekyll/7/code13.png){:class="img-responsive"}
{:class="text-center"}

[CLICK TO ACCESS 3DES Encryption][link3des]{:class="btn btn-blue"}
{:class="text-center"}

[link3des]: http://tripledes.online-domain-tools.com/

![image example](/img/jekyll/7/code14.png){:class="img-responsive"}
{:class="text-center"}

Tive que passar a flag para hex, pois a tool não suportava b64.

{% highlight cmd %}
HACKAFLAG{TripleDESneT}
{% endhighlight %}

Assim foi como resolvi essas duas flags dessa etapa, espero que alguém tenha aprendido algo, se não escrevi isso tudo pra nada xd

Obrigado!

By me