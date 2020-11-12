
<HTML>
<HEAD><TITLE>/Techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM</TITLE>
<link href="/js/default.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="/js/AJS.js"></script>

<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({
          google_ad_client: "ca-pub-3554665142518411",
          enable_page_level_ads: true
     });
</script>

</HEAD>
<BODY onLoad='javascript:et=new Date();eol();'><SCRIPT TYPE='text/javascript'><!--
var st=new Date();					
var et=new Date();					
var avgBndWdth=0;						
function eol() {						
var s=5376;					
var i=document.images;				
 for (var j=0;j<i.length;j++) 		
  { s += parseInt(i[j].fileSize); };	
 avgBndWdth = s/((et-st)||1);			
 s= ' '+parseInt(s/1024)+'KB'; 		
 i=' ('+(document.images.length-1)+' imgs) in '+((et-st)||1)/1000+'s is ';	
 if (document.getElementById) 		
  {document.getElementById('lt').innerText=s+i+parseInt(avgBndWdth)+'KBps';}
 };						
//--></SCRIPT>
<A HREF='/techref/indexok.asp?spider=44040.2660416667' onClick='return false;'><img src='/images/null.gif' ALIGN=LEFT HEIGHT=1 WIDTH=1 BORDER=0 ALT='please dont rip this site'></A>
<H1><A href="http://www.piclist.com\techref/language/index.htm">Language</A> <A href="http://www.piclist.com\techref/language/FORTHs.htm">Forth</A> <A href="http://www.piclist.com\techref/language/FORTH/z80fig-Forth1_1g_files/index.htm">Z80FIG-FORTH1_1G_FILES</A> Discio </H1>

<PRE>;  CP/M DISC INTERFACE
;
; Last update:
;
; 881228 - EXTEND's R/W address now initialized with blanks
; 860120 - EXTEND's R/W address now HERE, was Osborne video ram
; 850511 - saved BC' in 'BDOS'
; 850227 - saved index regs. in 'BDOS'
; 840812 - added EXTEND
; 840731 - installed BDOS calls
;
;
; CP/M BDOS CALLS USED (as per Albert van der Horst, HCCH)
;
; R/W reads or writes a sector in the file specified when invoking
; Z80 fig-FORTH (A&gt;Z80FORTH d:filename.ext), using the default FCB.
; More than one disc may be accessed by temporary use of a user de-
; fined FCB.
;
;
;
DEFFCB	EQU	005CH		;default FCB
;
;	CP/M FUNCTIONS
;
OPNFIL	EQU	0FH		;open file
CLSFIL	EQU	10H		;close file
SETDMA	EQU	1AH		;set DMA address
WRTRND	EQU	22H		;write random
;
;
;	FORTH variables &amp; constants used in disc interface
;
	DEFB	83H		;FCB (current FCB address)
	DM	'FCB'
	DEFW	PTSTO-5
FCB:	DEFW	DOCON,DEFFCB
;
	DEFB	84H		;REC# (returns address of random rec.#)
	DM	'REC#'
	DEFW	FCB-6
RECADR:	DEFW	DOCOL,FCB
	DEFW	LIT,21H
	DEFW	PLUS
	DEFW	SEMIS
;
	DEFB	83H		;USE
	DM	'USE'
	DEFW	RECADR-7
USE:	DEFW	DOVAR,0		;/ initialised by CLD
;
	DEFB	84H		;PREV
	DM	'PREV'
	DEFW	USE-6
PREV:	DEFW	DOVAR,0		;/ initialised by CLD
;
	DEFB	85H		;#BUFF
	DM	'#BUFF'
	DEFW	PREV-07H
NOBUF:	DEFW	DOCON,NBUF
;
	DEFB	8AH		;DISK-ERROR
	DM	'DISK-ERROR'
	DEFW	NOBUF-08H
DSKERR:	DEFW	DOVAR,0
;
;	DISC INTERFACE HIGH LEVEL ROUTINES
;
	DEFB	84H		;+BUF
	DM	'+BUF'
	DEFW	DSKERR-0DH
PBUF:	DEFW	DOCOL
	DEFW	LIT,CO
	DEFW	PLUS,DUP
	DEFW	LIMIT,EQUAL
	DEFW	ZBRAN,PBUF1-$
	DEFW	DROP,FIRST
PBUF1:	DEFW	DUP,PREV
	DEFW	AT,SUBB
	DEFW	SEMIS
;
	DEFB	86H		;UPDATE
	DM	'UPDATE'
	DEFW	PBUF-07H
UPDAT:	DEFW	DOCOL,PREV
	DEFW	AT,AT
	DEFW	LIT,8000H
	DEFW	ORR
	DEFW	PREV,AT
	DEFW	STORE,SEMIS
;
	DEFB	8DH		;EMPTY-BUFFERS
	DM	'EMPTY-BUFFERS'
	DEFW	UPDAT-9
MTBUF:	DEFW	DOCOL,FIRST
	DEFW	LIMIT,OVER
	DEFW	SUBB,ERASEE
	DEFW	SEMIS
;
	DEFB	83H		;DR0
	DM	'DR0'
	DEFW	MTBUF-10H
DRZER:	DEFW	DOCOL
	DEFW	ZERO
	DEFW	OFSET,STORE
	DEFW	SEMIS
;
	DEFB	83H		;DR1
	DM	'DR1'
	DEFW	DRZER-6
DRONE:	DEFW	DOCOL
	DEFW	LIT,1600	;Osborne DD
DRON2:	DEFW	OFSET,STORE
	DEFW	SEMIS
;
	DEFB	86H		;BUFFER
	DM	'BUFFER'
	DEFW	DRONE-6
BUFFE:	DEFW	DOCOL,USE
	DEFW	AT,DUP
	DEFW	TOR
BUFF1:	DEFW	PBUF		;won't work if single buffer
	DEFW	ZBRAN,BUFF1-$
	DEFW	USE,STORE
	DEFW	RR,AT
	DEFW	ZLESS
	DEFW	ZBRAN,BUFF2-$
	DEFW	RR,TWOP
	DEFW	RR,AT
	DEFW	LIT,7FFFH
	DEFW	ANDD,ZERO
	DEFW	RSLW
BUFF2:	DEFW	RR,STORE
	DEFW	RR,PREV
	DEFW	STORE,FROMR
	DEFW	TWOP,SEMIS
;
	DEFB	85H		;BLOCK
	DM	'BLOCK'
	DEFW	BUFFE-9
BLOCK:	DEFW	DOCOL,OFSET
	DEFW	AT,PLUS
	DEFW	TOR,PREV
	DEFW	AT,DUP
	DEFW	AT,RR
	DEFW	SUBB
	DEFW	DUP,PLUS
	DEFW	ZBRAN,BLOC1-$
BLOC2:	DEFW	PBUF,ZEQU
	DEFW	ZBRAN,BLOC3-$
	DEFW	DROP,RR
	DEFW	BUFFE,DUP
	DEFW	RR,ONE
	DEFW	RSLW
	DEFW	TWOMIN		;/
BLOC3:	DEFW	DUP,AT
	DEFW	RR,SUBB
	DEFW	DUP,PLUS
	DEFW	ZEQU
	DEFW	ZBRAN,BLOC2-$
	DEFW	DUP,PREV
	DEFW	STORE
BLOC1:	DEFW	FROMR,DROP
	DEFW	TWOP,SEMIS
;
	DEFB	84H		;BDOS  (CP/M function call)
	DM	'BDOS'
	DEFW	BLOCK-8
BDOS:	DEFW	$+2
	EXX			;SAVE IP
	POP	BC		;(C) &lt;-- (S1)LB = CP/M function code
	POP	DE		;(DE) &lt;-- (S2)  = parameter
	push	ix		;/
	push	iy		;/
	exx
	push	bc		;/ save ip
	exx
	CALL	BDOSS		;return value in A
	exx
	pop	bc		;restore ip
	exx
	pop	iy		;/
	pop	ix		;/
	EXX			;restore IP
	LD	L,A
	LD	H,00H
	JHPUSH			;(S1) &lt;-- (HL) = returned value
;
	DEFB	83H		;R/W
	DM	'R/W'
	DEFW	BDOS-07H
RSLW:	DEFW	DOCOL
	DEFW	TOR		;store R/W flag
	DEFW	RECADR,STORE
	DEFW	ZERO,RECADR	;set record #
	DEFW	TWOP,CSTOR
	DEFW	LIT,SETDMA
	DEFW	BDOS,DROP	;set DMA address
	DEFW	LIT,WRTRND
	DEFW	FROMR,SUBB	;select READ or WRITE
	DEFW	FCB,SWAP
	DEFW	BDOS		;do it
	DEFW	DSKERR,STORE	;store return code
	DEFW	SEMIS
;
	DEFB	85H		;FLUSH
	DM	'FLUSH'
	DEFW	RSLW-6
FLUSH:	DEFW	DOCOL
	DEFW	NOBUF,ONEP
	DEFW	ZERO,XDO
FLUS1:	DEFW	ZERO,BUFFE
	DEFW	DROP
	DEFW	XLOOP,FLUS1-$
	DEFW	SEMIS
;
;
	defb	86h			;/ EXTEND
	dm	'EXTEND'
	defw	flush-08h
extend:
	defw	docol
	defw	here			;/ fill with b/buf blanks
	defw	bbuf
	defw	blank
	defw	lit
	defw	0008h
	defw	star
	defw	zero
extnd1:
	defw	onep			; begin
	defw	here			;/ was lit,f000h (Osborne video ram)
	defw	over
	defw	one
	defw	rslw
	defw	dskerr
	defw	at
	defw	zbran
	defw	extnd1-$		; until
	defw	swap
	defw	over
	defw	plus
	defw	swap
	defw	xdo			; do
extnd2:
	defw	here			;/ was lit,f000h (Osborne video ram)
	defw	ido
	defw	zero
	defw	rslw
	defw	xloop
	defw	extnd2-$		; loop
	defw	fcb
	defw	lit
	defw	clsfil
	defw	bdos			; close file
	defw	drop			; discard return code
	defw	fcb
	defw	lit
	defw	opnfil
	defw	bdos			; &amp; re-open
	defw	drop			; discard return code
	defw	semis
;
;
	DEFB	84H		;LOAD
	DM	'LOAD'
	DEFW	EXTEND-09H
LOAD:	DEFW	DOCOL,BLK
	DEFW	AT,TOR
	DEFW	INN,AT
	DEFW	TOR,ZERO
	DEFW	INN,STORE
	DEFW	BSCR,STAR
	DEFW	BLK,STORE	;BLK &lt;-- SCR * B/SCR
	DEFW	INTER		;INTERPRET FROM OTHER SCREEN
	DEFW	FROMR,INN
	DEFW	STORE
	DEFW	FROMR,BLK
	DEFW	STORE,SEMIS
;
	DEFB	0C3H		;--&gt;
	DM	'--&gt;'
	DEFW	LOAD-7
ARROW:	DEFW	DOCOL,QLOAD
	DEFW	ZERO
	DEFW	INN,STORE
	DEFW	BSCR,BLK
	DEFW	AT,OVER
	DEFW	MODD,SUBB
	DEFW	BLK,PSTOR
	DEFW	SEMIS
;
;
;

</PRE>
<HR><TABLE><TR><TD><SMALL>file: /Techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM, <SPAN ID="lt">5KB, </SPAN>, updated: 1997/12/31 09:21, local time: 2020/7/28 06:23, <SCRIPT TYPE='text/javascript'><!--
 eol();
 for (var j=0;j<document.images.length;j++) 		
  { document.images[j].onload = new Function('eol();'); };	
//-->
</SCRIPT>

</SMALL><FORM ACTION="/techref/search.asp#result" METHOD=POST>
<DIV ID="upperright" 
	onMouseOver="this.style.backgroundColor='#FFFF00';this.style.borderStyle='outset';" 
	onMouseOut="this.style.backgroundColor='#FFFFFF';this.style.borderStyle='ridge';" 
	style="position:absolute;top:0;right:0;width:200px;text-align:right;color:gray;background-color:#FFFFFF;border-width:2px;"><SMALL><SUP>
<A style="color:#AF4040;text-decoration:none;" TITLE="Go to the top page" HREF="/techref/index.htm">TOP</A> 
<A style="color:#AF4040;text-decoration:none;" TITLE="Monthly Change Log for the site" HREF="/techref/new202007.txt">NEW</A>

<SCRIPT  TYPE='text/javascript'>
<!--- Hide script from old browsers.
document.write('<A style="color:#AF4040;text-decoration:none;" TITLE="More pages like this." HREF="/techref/search');
document.write('.asp\077from=%2FTechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM">MORE<\/A> ');
// End the hiding here. -->
</SCRIPT>
<A style="color:#AF4040;text-decoration:none;" TITLE="I'm willing to pay for help, please refer me to a qualified consultant" HREF="mailto:webmaster@piclist.com?subject=I%20need%20someone%20to%20help%20me%20with%3A%20">
HELP</A>
<A style="color:#AF4040;text-decoration:none;" TITLE="Advanced search" HREF="/techref/search.asp">
FIND:</A>&nbsp;
<INPUT style="background-color:transparent;padding:0px;border-width:1px;font-size:small;border-style:solid;border-color:#AF0000" TITLE="Free text search" TYPE="TEXT" ID="search" NAME="qu" SIZE="20" MAXLENGTH="100" VALUE="Search" onClick="this.value='';">
<INPUT NAME="FreeText" TYPE="HIDDEN" VALUE="ON"> 
<INPUT NAME="from" TYPE="HIDDEN" VALUE="/Techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM">
</SUP></SMALL></DIV>
</FORM>
<DIV ID="upperleft" 
	onMouseOver="this.style.backgroundColor='#FFFF00';this.style.borderStyle='outset';" 
	onMouseOut="this.style.backgroundColor='transparent';this.style.borderStyle='none';" 
	style="position:absolute;top:0;left:0;color:gray;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=75);"><SMALL>
<A HREF="/techref/indexok.asp?top"> </A>
<SUP>58.84.148.197:<A style="color:#AF4040" REL="nofollow" HREF="/techref/login/default.asp?req=403%3Bhttp%3A%2F%2Fwww%2Epiclist%2Ecom%3A80%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM">LOG IN</A></SUP></SMALL></DIV><DIV ALIGN=CENTER style="position:absolute;top:0;left:20%;width:40%"><div id="fb-root"><FONT COLOR='#FF0000'><B>&copy;2020 <A TITLE='Why does RIP/GRAB/SPIDERing lead to ads and sponsors? Click here.' HREF='/dontripthissite.htm' style='color:red'>PLEASE DON'T RIP!</A></B></FONT><FONT COLOR='#008000'><B> <A TITLE="Click to copy link HTML to your clipboard" onClick="window.clipboardData.setData('Text','&lt;A HREF=&quot;http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM&quot;&gt; language FORTH z80fig-Forth1_1g_files DISCIO&lt;/A&gt;');">DO:&nbsp;LINK</A></B></FONT>&nbsp;/&nbsp;<a title="Digg this!" href="http://digg.com/submit?phase=2&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM&amp;title=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+DISCIO">DIGG!</a>&nbsp;/&nbsp;<a title="Suggest to Make!" href="http://makezine.com/cs/user/create/link?x-t=suggestlink.form&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM&amp;description=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+DISCIO&amp;title=www%2Epiclist%2Ecom">MAKE!</a><script src="http://connect.facebook.net/en_US/all.js#appId=128618207221084&amp;xfbml=1"></script><fb:like href="http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM" send="false" layout="button_count" width="70" show_faces="false" action="recommend" font=""></fb:like></div>
</DIV>
<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">
<!--- Hide script from old browsers.
if (AJS) AJS.getElement("upperright").style.filter = "progid:DXImageTransform.Microsoft.Alpha(opacity=75);";

var old = 1;
var to;

function scrollHold() {
var pos=1;
	if (to) clearTimeout(to);
	if (window.innerHeight) {
		pos = window.pageYOffset;
		}
	else if (document.documentElement && document.documentElement.scrollTop) {
		pos = document.documentElement.scrollTop;
		}
	else if (document.body) {
		pos = document.body.scrollTop;
		}
	if (pos < 0) pos = 1;
	else pos += 1;
	if (pos != old) {
		AJS.getElement("upperright").style.top = pos;
		AJS.getElement("upperleft").style.top = pos;
		}
	old = pos;
	if (window.onscroll==null) {to=setInterval('scrollHold()',100);}
}

window.onscroll = scrollHold;
scrollHold();

// End the hiding here. -->
</SCRIPT>
</TD></TR>
</TABLE>
<HR><TABLE BGCOLOR='#F0F0F0'><TR><TD>&nbsp;</TD><TD><SMALL>&copy;2020 These pages are served without commercial sponsorship. (No popup ads, etc...).Bandwidth abuse increases hosting cost forcing sponsorship or shutdown. This server aggressively defends against automated copying for any reason including offline viewing, duplication, etc... Please respect this requirement and <FONT FACE='Comic Sans MS' COLOR='#FF0000'>DO NOT RIP THIS SITE</FONT>. <A HREF='/dontripthissite.htm'>Questions?</A><div id="fb-root">Please <I>DO</I> link to this page! <a href="http://digg.com/submit?phase=2&amp;url=http://www.piclist.com/techref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM&amp;title=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+DISCIO">Digg it!</a>&nbsp;/&nbsp;<a title="Suggest to Make!" href="http://makezine.com/cs/user/create/link?x-t=suggestlink.form&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM&amp;description=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+DISCIO&amp;title=www%2Epiclist%2Ecom">MAKE!</a><script src="http://connect.facebook.net/en_US/all.js"></script><fb:like href="http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM" send="false" layout="button_count" width="450" show_faces="true" action="recommend" font=""></fb:like></div><BR><TT>&lt;A HREF=&quot;http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM&quot;&gt;  language FORTH z80fig-Forth1_1g_files DISCIO&lt;/A&gt;</TT></SMALL></TD></TR></TABLE><HR><table style='background:#f8f8f8;'><tr><td>Did you find what you needed? From: &quot;<I><A HREF='http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g.htm'>/language/FORTH/z80fig-Forth1_1g.htm</A></I>&quot; 
<UL>
<LI>
<SCRIPT TYPE="text/javascript">
<!--- Hide script from old browsers.
document.write('<I>&quot;Not quite. <A HREF="/techref/search.asp\077from=%2FTechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FDISCIO%2EASM"> Look for more pages like this one.&quot;<\/A><\/I> ')
// End the hiding here. -->
</SCRIPT>


<LI><FORM ACTION="/techref/search.asp#result" METHOD=POST>
<INPUT NAME="FreeText" TYPE="HIDDEN" VALUE="on"> 
<INPUT NAME="from" TYPE="HIDDEN" VALUE="/Techref/language/FORTH/z80fig-Forth1_1g_files/DISCIO.ASM">
 <I>&quot;No. I'm looking for: 
<INPUT TYPE="TEXT" NAME="SearchString" SIZE="40" MAXLENGTH="100" VALUE=""><INPUT TYPE="SUBMIT" NAME="Action" VALUE="Fetch">&quot;</I></FORM>
<LI><A HREF="/techref/search.asp">
<I>&quot;No. Take me to the search page.&quot;</I></A>
<LI><A HREF="/techref/index.htm">
<I>&quot;No. Take me to the top so I can drill down by catagory&quot;</I></A>
<LI><A HREF="mailto:webmaster@piclist.com?subject=I%20need%20someone%20to%20help%20me%20with%3A%20">
<I>&quot;No. I'm willing to pay for help, please refer me to a qualified consultant&quot;</I></A>

</UL>
</td></tr></table>


<HR STYLE="clear:both;">
<TABLE WIDTH="30%" BGCOLOR="#F0F0F0" ALIGN=LEFT><TR><TD>&nbsp;</TD><TD>
<!-- piclist.com -->
<!--  language FORTH z80fig-Forth1_1g_files DISCIO -->
<!--  language FORTH z80fig-Forth1_1g_files DISCIO -->
<CENTER>
  <FONT COLOR="#ff0000"><B><I><BIG>BUY OUR STUFF!</BIG></I></B></FONT> 
	<BR> We sell 
  <A HREF="http://massmind.ecomorder.com/techref/ecomprice.asp">a few items</A> to support this site
</CENTER>
</TD></TR></TABLE> 
<TABLE WIDTH="30%" BGCOLOR="#F0F0F0" ALIGN=RIGHT><TR><TD>&nbsp;</TD><TD>
<CENTER>
Here is a great gift for computer geeks or widows:
<BR><A HREF="http://www.amazon.com/exec/obidos/ASIN/0964997215/jamesnewtonspers" target="_top">The Backwoods Guide to Computer Lingo</A>
</CENTER>
</TD></TR></TABLE>
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
<P>&nbsp;
.


</BODY>
</HTML>
