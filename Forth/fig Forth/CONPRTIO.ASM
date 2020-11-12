
<HTML>
<HEAD><TITLE>/Techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM</TITLE>
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
var s=2304;					
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
<A HREF='/techref/indexok.asp?spider=44040.2659606481' onClick='return false;'><img src='/images/null.gif' ALIGN=LEFT HEIGHT=1 WIDTH=1 BORDER=0 ALT='please dont rip this site'></A>
<H1><A href="http://www.piclist.com\techref/language/index.htm">Language</A> <A href="http://www.piclist.com\techref/language/FORTHs.htm">Forth</A> <A href="http://www.piclist.com\techref/language/FORTH/z80fig-Forth1_1g_files/index.htm">Z80FIG-FORTH1_1G_FILES</A> Conprtio </H1>

<PRE>;  CP/M CONSOLE &amp; PRINTER INTERFACE
;
; Last update:
;
; 850511 - Saved BC' prior to CP/M calls
; 841010 - Saved IX &amp; IY prior to CP/M calls
; 840909 - Converted all BIOS calls to BDOS calls for compatibility
;          with CP/M 3.0
;
;
;
LSTOUT	EQU	05H		;printer output
DCONIO	EQU	06H		;direct console I/O
;
RUBOUT	EQU	7FH
INPREQ	EQU	0FFH		;DCONIO input request
;
EPRINT:	DEFB	0		;printer flag
				;0=disabled, 1=enabled
;
SYSENT:	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	exx
	push	bc		;save ip (if used as such)
	exx
	CALL	BDOSS		;perform function (C)
	exx
	pop	bc		;restore ip
	exx
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	RET
;
CSTAT:	PUSH	BC
	LD	C,DCONIO	;direct console I/O
	LD	E,INPREQ	;input request
	CALL	SYSENT		;any CHR typed?
	POP	BC		;if yes, (A)&lt;--CHAR
	RET			;else    (A)&lt;--00H (ignore CHR)
;
CIN:	PUSH	BC
	LD	C,DCONIO	;direct console I/O
	LD	E,INPREQ	;request input
CINLP:	CALL	SYSENT		;(A)&lt;--CHR (or 0 if nothing typed)
	OR	A
	JR	Z,CINLP		;wait for CHR to be typed
	CP	RUBOUT
	JR	NZ,CIN1
	LD	A,BSOUT		;convert RUB to ^H
CIN1:	RES	7,A		;(MSB)&lt;--0
	POP	BC
	RET
;
COUT:	PUSH	BC
	PUSH	DE		;save (E) = CHR
	LD	C,DCONIO	;direct console output
	CALL	SYSENT		;send (E) to CON:
	POP	DE
	POP	BC
	RET
;
POUT:	PUSH	BC
	LD	C,LSTOUT
	CALL	SYSENT		;send (E) to LST:
	POP	BC
	RET
;
CPOUT:	CALL	COUT		;send (E) to console
	LD	A,(EPRINT)
	OR	A		;if (EPRINT) &lt;&gt; 0
	CALL	NZ,POUT		;send (E) to LST:
	RET
;
;	FORTH TO CP/M SERIAL I/O INTERFACE
;
PQTER:	CALL	CSTAT
	LD	HL,0
	OR	A		;CHR TYPED?
	JR	Z,PQTE1		;NO
	INC	L		;YES, (S1)&lt;--TRUE
PQTE1:	JHPUSH
;
PKEY:	CALL	CIN		;READ CHR FROM CONSOLE
	CP	DLE		;^P?
	LD	E,A
	JR	NZ,PKEY1	;NO
	LD	HL,EPRINT
	LD	E,ABL		;(E)&lt;--BLANK
	LD	A,(HL)
	XOR	01H		;TOGGLE (EPRINT) LSB
	LD	(HL),A
PKEY1:	LD	L,E
	LD	H,0
	JHPUSH			;(S1)LB&lt;--CHR
;
PEMIT:	DEFW	$+2		;(EMIT) orphan
	POP	DE		;(E)&lt;--(S1)LB = CHR
	LD	A,E
	CP	BSOUT
	JR	NZ,PEMIT1
	CALL	COUT		;backspace
	LD	E,ABL		;blank
	CALL	COUT		;erase CHR on CON:
	LD	E,BSOUT		;backspace
PEMIT1:	CALL	CPOUT		;send CHR to CON:
				;and LST: if (EPRINT)=01H
	JNEXT
;
PCR:	LD	E,ACR
	CALL	CPOUT		;output CR
	LD	E,LF
	CALL	CPOUT		;and LF
	JNEXT
;
;
;

</PRE>
<HR><TABLE><TR><TD><SMALL>file: /Techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM, <SPAN ID="lt">2KB, </SPAN>, updated: 1997/12/31 09:21, local time: 2020/7/28 06:22, <SCRIPT TYPE='text/javascript'><!--
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
document.write('.asp\077from=%2FTechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM">MORE<\/A> ');
// End the hiding here. -->
</SCRIPT>
<A style="color:#AF4040;text-decoration:none;" TITLE="I'm willing to pay for help, please refer me to a qualified consultant" HREF="mailto:webmaster@piclist.com?subject=I%20need%20someone%20to%20help%20me%20with%3A%20">
HELP</A>
<A style="color:#AF4040;text-decoration:none;" TITLE="Advanced search" HREF="/techref/search.asp">
FIND:</A>&nbsp;
<INPUT style="background-color:transparent;padding:0px;border-width:1px;font-size:small;border-style:solid;border-color:#AF0000" TITLE="Free text search" TYPE="TEXT" ID="search" NAME="qu" SIZE="20" MAXLENGTH="100" VALUE="Search" onClick="this.value='';">
<INPUT NAME="FreeText" TYPE="HIDDEN" VALUE="ON"> 
<INPUT NAME="from" TYPE="HIDDEN" VALUE="/Techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM">
</SUP></SMALL></DIV>
</FORM>
<DIV ID="upperleft" 
	onMouseOver="this.style.backgroundColor='#FFFF00';this.style.borderStyle='outset';" 
	onMouseOut="this.style.backgroundColor='transparent';this.style.borderStyle='none';" 
	style="position:absolute;top:0;left:0;color:gray;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=75);"><SMALL>
<A HREF="/techref/indexok.asp?top"> </A>
<SUP>58.84.148.197:<A style="color:#AF4040" REL="nofollow" HREF="/techref/login/default.asp?req=403%3Bhttp%3A%2F%2Fwww%2Epiclist%2Ecom%3A80%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM">LOG IN</A></SUP></SMALL></DIV><DIV ALIGN=CENTER style="position:absolute;top:0;left:20%;width:40%"><div id="fb-root"><FONT COLOR='#FF0000'><B>&copy;2020 <A TITLE='Why does RIP/GRAB/SPIDERing lead to ads and sponsors? Click here.' HREF='/dontripthissite.htm' style='color:red'>PLEASE DON'T RIP!</A></B></FONT><FONT COLOR='#008000'><B> <A TITLE="Click to copy link HTML to your clipboard" onClick="window.clipboardData.setData('Text','&lt;A HREF=&quot;http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM&quot;&gt; language FORTH z80fig-Forth1_1g_files CONPRTIO&lt;/A&gt;');">DO:&nbsp;LINK</A></B></FONT>&nbsp;/&nbsp;<a title="Digg this!" href="http://digg.com/submit?phase=2&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM&amp;title=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+CONPRTIO">DIGG!</a>&nbsp;/&nbsp;<a title="Suggest to Make!" href="http://makezine.com/cs/user/create/link?x-t=suggestlink.form&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM&amp;description=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+CONPRTIO&amp;title=www%2Epiclist%2Ecom">MAKE!</a><script src="http://connect.facebook.net/en_US/all.js#appId=128618207221084&amp;xfbml=1"></script><fb:like href="http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM" send="false" layout="button_count" width="70" show_faces="false" action="recommend" font=""></fb:like></div>
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
<HR><TABLE BGCOLOR='#F0F0F0'><TR><TD>&nbsp;</TD><TD><SMALL>&copy;2020 These pages are served without commercial sponsorship. (No popup ads, etc...).Bandwidth abuse increases hosting cost forcing sponsorship or shutdown. This server aggressively defends against automated copying for any reason including offline viewing, duplication, etc... Please respect this requirement and <FONT FACE='Comic Sans MS' COLOR='#FF0000'>DO NOT RIP THIS SITE</FONT>. <A HREF='/dontripthissite.htm'>Questions?</A><div id="fb-root">Please <I>DO</I> link to this page! <a href="http://digg.com/submit?phase=2&amp;url=http://www.piclist.com/techref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM&amp;title=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+CONPRTIO">Digg it!</a>&nbsp;/&nbsp;<a title="Suggest to Make!" href="http://makezine.com/cs/user/create/link?x-t=suggestlink.form&amp;url=http%3A%2F%2Fwww%2Epiclist%2Ecom%2Ftechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM&amp;description=+language+FORTH+z80fig%2DForth1%5F1g%5Ffiles+CONPRTIO&amp;title=www%2Epiclist%2Ecom">MAKE!</a><script src="http://connect.facebook.net/en_US/all.js"></script><fb:like href="http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM" send="false" layout="button_count" width="450" show_faces="true" action="recommend" font=""></fb:like></div><BR><TT>&lt;A HREF=&quot;http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM&quot;&gt;  language FORTH z80fig-Forth1_1g_files CONPRTIO&lt;/A&gt;</TT></SMALL></TD></TR></TABLE><HR><table style='background:#f8f8f8;'><tr><td>Did you find what you needed? From: &quot;<I><A HREF='http://www.piclist.com/techref/language/FORTH/z80fig-Forth1_1g.htm'>/language/FORTH/z80fig-Forth1_1g.htm</A></I>&quot; 
<UL>
<LI>
<SCRIPT TYPE="text/javascript">
<!--- Hide script from old browsers.
document.write('<I>&quot;Not quite. <A HREF="/techref/search.asp\077from=%2FTechref%2Flanguage%2FFORTH%2Fz80fig%2DForth1%5F1g%5Ffiles%2FCONPRTIO%2EASM"> Look for more pages like this one.&quot;<\/A><\/I> ')
// End the hiding here. -->
</SCRIPT>


<LI><FORM ACTION="/techref/search.asp#result" METHOD=POST>
<INPUT NAME="FreeText" TYPE="HIDDEN" VALUE="on"> 
<INPUT NAME="from" TYPE="HIDDEN" VALUE="/Techref/language/FORTH/z80fig-Forth1_1g_files/CONPRTIO.ASM">
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
<!--  language FORTH z80fig-Forth1_1g_files CONPRTIO -->
<!--  language FORTH z80fig-Forth1_1g_files CONPRTIO -->
<CENTER><B>Stepper motors <I>CAN</I> be smooth!</B></CENTER>
And stepper controllers can be strong and cheap. 
Roman Black's
<A HREF="http://www.piclist.com/techref/io/stepper/linistep/index.htm">Linistep
stepper controller kits</A>:
<TABLE><TR><TD>
 o 18th microstep 
<BR> o <I>Linear</I> smoothing 
</TD><TD> &nbsp; </TD><TD>
 o Open source 
<BR> o Full kit $25!
</TD></TR></TABLE>
</TD></TR></TABLE> 
<TABLE WIDTH="30%" BGCOLOR="#F0F0F0" ALIGN=RIGHT><TR><TD>&nbsp;</TD><TD>
<CENTER>
<BIG><B>Quick, <U>Easy</U> <I>and</I> <FONT FACE="Comic Sans MS" COLOR="#408040">CHEAP</FONT>! <A HREF="/techref/io/serial/RCL1.htm" target="_top">RCL-1 RS232 Level Converter in a DB9 backshell</A></B></BIG>
<BR>Ashley Roll has put together a really nice little unit here. Leave off the MAX232 and keep these handy for the few times you need true RS232!
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
