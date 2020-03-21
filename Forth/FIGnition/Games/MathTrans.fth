( Transcendental Functions)

: fabs
  $7FFF and
;

: sqrt ( x -- sqrt[x])
  dup 0< if
    2drop 1d ;s ( overflow if <0)
  then
  dup 1 >> $7F80 and $1F80 - >r ( x : exp[x]/2)
  $FF and $3F00 + 2dup fneg 2swap ( -m m : exp[x]/2)
  0d ( -m m dx : exp[x]/2)
  begin
    f- ( -m m'-dx=>m' : exp[x]/2)
    2over 2over ( -m m' -m m': exp[x]/2)
    2dup f* f+ ( -m m' m'^2-m: exp[x]/2)
    2over $80 + f/ ( -m m' [m'^2-m]/[2m']=>dx : exp[x]/2)
  dup fabs $3400 < until
  2drop 2swap 2drop ( m : exp[x]/2)
  r> +
; ( 59b+header = 68b)

create pi -1 allot
  71 c, $40C90FDBd d,
create e -1 allot
  71 c, $40ADF854d d,

: >rad ( deg -- rad)
  [ pi 180. f/ ]
  dliteral f*
;

: cheb ( Z chebData )
  >r $80 +   ( 2*Z : chebData )
  0d 0d 0d    ( 2*Z, 0.0 0.0 0.0 )
  r> 		( 2Z M2 T M1 cTable^ )
  dup 1+ swap c@ 0 do
  	>r 2drop 2swap fneg  ( 2Z T -M2 /M1/ : cTable^)
  	d>r 2over 2over f*   ( 2Z T 2Z*T : -M2 cTable^)
  	dr> r d@ r> 4 + >r    ( 2Z T 2Z*T -M2 A : cTable'^)
  	2over d>r f+ f+       ( 2Z T 2Z*T-M2+A : -M2 cTable'^)
  	dr>
  	r>        ( 2Z T 2Z*T-M2+A -M2 cTable'^)
  loop
  drop f+ d>r 2drop 2drop dr> ( T )
; ( 59b, normCycles*27+FPs*3+12 = 2.5*27 + 3*67+12 = 280.5us/loop)

create kSinTab 6 c,
  $B1E60000d d,
  $359F0B00d d,
  $B90F38EEd d,
  $3C1563BBd d,
  $BE920DCEd d,
  $40235D1Cd d,

: sin ( a -- sin[a])
  [ 0.5 pi f/ ] dliteral
  f* 2dup 0.5 f+ fint
  float f-
  $0100 + ( in range -2 to 2)
  2dup fabs
  $-40000001d d+ d0< 0= if ( abs[w]>1?)
    dup >r
    fabs fneg 2.0 f+ ( -abs[w]+2)
    r> 0< if
      fneg ( -[-abs[w]+2] = -w-2)
    then
  then
  2dup 2dup f* $80 +
  1.0 f- kSinTab cheb
  f*
; ( 79b)

: cos ( a -- cos[a] )
  [ pi 2.0 f/ ]
  dliteral f+ sin
;

: tan ( a -- tan[a] )
  2dup sin 2swap cos
  f/
;

( @Consts reverse order)
create kAtnTab 12 c,
  $AFB20000d d,
  $310E0000d d,
  $B2648D00d d,
  $33B9BC00d d,
  $B518FD00d d,
  $36803675d d,
  $B7DBE8B4d d,
  $3942C400d d,
  $BAB50937d d,
  $3C36731Bd d,
  $BDD8DE64d d,
  $3FE1A1B3d d,

: atn ( tan[a] -- a)
  dup fabs
  $4000 < if ( abs[w]<1? y=x )
    0.0 ( y 0)
  else
    -1.0 2swap f/
    dup >r
    [ pi -2.0 f/ ]
    dliteral r> $8000
    and xor
  then
  2swap ( w y)
  2dup 2dup
  f* $80 + -1.0 f+
  kAtnTab cheb
  f* f+
;

: asn ( sin[a] -- a )
  2dup 2dup f* ( x x*x)
  fneg 1.0 f+  ( x 1-x*x)
  sqrt 1.0 f+ f/
  atn 2dup f+
;

: acs ( cos[a] -- a )
  asn fneg [ pi $80 - ]
  dliteral f+
;

create kExpTab 8 c,
  $31360000d d,
  $33E56600d d,
  $36786540d d,
  $38E032C9d d,
  $3B21F7AFd d,
  $3D2FB0B0d d,
  $3EFEBB94d d,
  $403A7EF9d d,

: exp ( fx--e^fx)
  2dup 88.7228391 f< 0=
  if
    2drop 1d ;s
  then
  1.44269504 f*
  2dup fint ( y n)
  over >r float f-
  $80 + -1.0 f+
  kExpTab cheb
  r> 7 << +
;

create kLnTab 12 c,
  $B02C0000d d,
  $31890000d d,
  $B2DAA500d d,  
  $3430C500d d,
  $B590AA00d d,
  $36F06F61d d,
  $B84BDA96d d,
  $39B19FB4d d,
  $BB20FE5Dd d,
  $3C9B43CAd d,
  $BE279C7Ed d,
  $3FEE2381d d,

: ln ( fx -- ln[fx])
  dup 0< if
  	2drop 1d ;s
  then
  -3. 2swap ( -3. x )
  dup 7 >> $7F - >r ( -3. x : exp[x])
  $7F and $3F80 + ( -3. x' : e' )
  2dup $3FCCCCCDd f< if
    r> 1- >r $80 + ( -3. [x'|2x'] : e'-1)
  then
  2dup d>r 2.5 f* f+ ( -3.+[2.5|5]x' : [x'|2x'] e'-1)
  kLnTab cheb
  dr> -1.0 f+ f* ( Z'*[[x'|2x']-1] : e'-1)
  r> s->d float
  $3FB17218d f* f+
;

: ** ( fx fy)
  2swap 2dup or if
    ln f* exp
  else ( x=0)
    2drop 2dup or if
      2drop 1.0 ( 0**0=1)
    else ( -ve => overflow, else 0)
      swap drop 15 >> 0
    then
  then
;
