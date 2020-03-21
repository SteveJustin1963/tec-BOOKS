\ Copyright 1998 Pierre Henri Michel., Abbat.
\ Anyone may use this code freely, as long as this notice is preserved.
CR
.( Bézier splines                              ) CR
.( by Pierre Abbat     Version 1.0    19980607 ) CR
NEEDS FSL_UTIL
ANEW -bezier-spline-

\ If you have a series of points x0y0 x1y1 x2y2 x3y3 with x equally spaced
\ and want to interpolate smoothly Bézier splines, the formulae for the
\ control points are:
\ z0=y0
\ z1=(2y0+y1)/3
\ z2=y1+(y0-y2)/6
\ z3=y1
\ z4=y1+(y2-y0)/6
\ z5=y2+(y1-y3)/6
\ z6=y2
\ z7=y2+(y3-y1)/6
\ z8=(2y3+y2)/3
\ z9=y3.
\ This makes the slope at a point equal to the chord through the two adjacent points.
\ The constant 6 in the above formulae can be changed to 5 by executing
\ TRUE SetBezMode. This may look better if you are interpolating in both dimensions.
\ A six-point circle with TRUE SetBezMode looks like a circle; with FALSE
\ SetBezmode, it has definite corners. With nine points, however, TRUE SetBezMode
\ produces bulges between the points. If you are interpolating in only one
\ dimension, use FALSE SetBezMode; this will interpolate a constant velocity
\ as a constant velocity.
\
\ The following words are provided for the user:
\
\ SetBezMode ( ? )
\ See above.
\
\ }BezierControlsOpen ( array1{ array2{ n )
\ Computes the Bézier control points for an open curve.
\ array1{ is assumed to have n elements and array2{ 3n-2.
\
\ }BezierControlsClosed ( array1{ array2{ n )
\ Computes the Bézier control points for a closed curve.
\ array1{ is assumed to have n elements and array2{ 3n-2.
\ The 0th and (n-1)th elements are assumed to be the same.
\
\ }FBezierControlsOpen ( array1{ array2{ n )
\ Same as }BezierControlsOpen except that the arrays are floating.
\
\ }FBezierControlsClosed ( array1{ array2{ n )
\ Same as }BezierControlsClosed except that the arrays are floating.
\
\ BezierControlsOpenXY ( array1 array2 n )
\ Computes control points for a curve in the plane.
\ This routine is intended for use with Windows, so it
\ assumes that the points are cell pairs. An FSL array or matrix
\ will work if the rows are exactly two cells long.
\
\ BezierControlsClosedXY ( array1 array2 n )
\ Same as above but for a closed curve.
\
\ BezierInterpolate ( a0 a1 a2 a3 num denom - a )
\ Interpolates num/denom of the way from a0 to a3
\ with a1 and a2 as Bézier control points.
\ FBezierInterpolate ( f: a0 a1 a2 a3 t - a )
\ Interpolates t of the way from a0 to a3
\ with a1 and a2 as Bézier control points. )
\
\  ANS Forth Program Label
\
\ This is an ANS Forth program with environmental dependencies
\ requiring the Floating-Point and Locals Extension word set.
\
\  Nonstandard and non-core, non-float, non-local(ext) words:
\
\ \                     CORE EXT
\ NEEDS                 Includes a file if it hasn't been included already.
\ ANEW -<name>-         Creates a marker, if it doesn't exist, or forgets
\                       everything after it, if it does.
\ TRUE                  CORE EXT
\ FALSE                 CORE EXT
\ TUCK                  CORE EXT
\ FPI                   % 3.1415926535897932384 ( test code only )
\ FSINCOS               FLOATING EXT ( test code only )
\ FSIN                  FLOATING EXT ( test code only )
\ [IF]                  TOOLS EXT
\ [THEN]                TOOLS EXT
\ S" (interpretive)     FILE
\ CELLS+                CELLS +
\
\ The window section of the program contains many nonstandard words,
\ but all compilers except Win32Forth ignore it.


INTEGER DARRAY BezPnt{
INTEGER DARRAY BezCtrl{

: 3/ ( n - n )
( Divides by 3, rounding )
  S>D 3 FM/MOD SWAP 2/ + ;

: 5/ ( n - n )
( Divides by 5, rounding )
  S>D 5 FM/MOD SWAP 2 > - ;

: 3* ( n - n )
  DUP 2* + ;

: 6/ ( n - n )
( Divides by 6, rounding to closest or even )
  S>D 6 FM/MOD TUCK 1 AND + 3 > - ;

FALSE VALUE BezMode
FVARIABLE BezDiv

: SetBezMode ( ? )
( Use FALSE when interpolating along the y-axis with the x-axis being
  the parameter. Use TRUE when interpolating in both dimensions. )
  DUP TO BezMode
  IF 5 ELSE 6 THEN S>F BezDiv F! ;

FALSE SetBezMode

: 5|6/ ( n - n )
  BezMode IF 5/ ELSE 6/ THEN ;

: }BezierControlsOpen ( array1{ array2{ n )
( Computes the Bézier control points for an open curve.
  array1{ is assumed to have n elements and array2{ 3n-2. )
  LOCALS| N A2{ A1{ |
  N 0 ?DO
    A1{ I } @ A2{ I 3* } !
  LOOP
  N 1- 1 MAX 1 ?DO
    A1{ I } @ A1{ I 1+ } @ A1{ I 1- } @ - 5|6/
    2DUP + A2{ I 3* 1+ } !
    - A2{ I 3* 1- } !
  LOOP
  N 1 > IF
    A1{ 0 } @ 2* A1{ 1 } @ + 3/ A2{ 1 } !
    A1{ N 1- } @ 2* A1{ N 2 - } @ + 3/ A2{ N 3* 4 - } !
  THEN ;

: }BezierControlsClosed ( array1{ array2{ n )
( Computes the Bézier control points for a closed curve.
  The first and last points are assumed to be the same. )
  3DUP }BezierControlsOpen
  LOCALS| N A2{ A1{ |
  N 2 > IF
    A1{ 0 } @ A1{ 1 } @ A1{ N 2 - } @ - 5|6/
    2DUP + A2{ 1 } !
    - A2{ N 3* 4 - } !
  THEN ;

: }FBezierControlsOpen ( array1{ array2{ n )
( Computes the Bézier control points for an open curve.
  array1{ is assumed to have n elements and array2{ 3n-2. )
  LOCALS| N A2{ A1{ |
  N 0 ?DO
    A1{ I } F@ A2{ I 3* } F!
  LOOP
  N 1- 1 MAX 1 ?DO
    A1{ I } F@ A1{ I 1+ } F@ A1{ I 1- } F@ F- BezDiv F@ F/
    F2DUP F+ A2{ I 3* 1+ } F!
    F- A2{ I 3* 1- } F!
  LOOP
  N 1 > IF
    A1{ 0 } F@ 2* A1{ 1 } F@ F+ 3E0 F/ A2{ 1 } F!
    A1{ N 1- } F@ 2* A1{ N 2 - } F@ F+ 3E0 F/ A2{ N 3* 4 - } F!
  THEN ;

: }FBezierControlsClosed ( array1{ array2{ n )
( Computes the Bézier control points for a closed curve.
  The first and last points are assumed to be the same. )
  3DUP }FBezierControlsOpen
  LOCALS| N A2{ A1{ |
  N 2 > IF
    A1{ 0 } F@ A1{ 1 } F@ A1{ N 2 - } F@ F- BezDiv F@ F/
    F2DUP F+ A2{ 1 } F!
    F- A2{ N 3* 4 - } F!
  THEN ;

: )BezierControlsXY ( array1 array2 n bezfunc )
( Computes control points for n pairs of points.
  Array1 and array2 are not assumed to be FSL arrays;
  rather they are assumed to be arrays of cell pairs.
  This function is intended for use in Windows 95 and NT
  prior to calling PolyBezier. )
  LOCALS| }Bez N A2 A1 |
  & BezPnt{ N }malloc
  & BezCtrl{ N 3* 2 - }malloc
  N 0 ?DO
    A1 I 2* CELLS+ @ BezPnt{ I } !
  LOOP
  BezPnt{ BezCtrl{ N }Bez EXECUTE
  N 3* 2 - 0 ?DO
    BezCtrl{ I } @ A2 I 2* CELLS+ !
  LOOP
  N 0 ?DO
    A1 I 2* 1+ CELLS+ @ BezPnt{ I } !
  LOOP
  BezPnt{ BezCtrl{ N }Bez EXECUTE
  N 3* 2 - 0 ?DO
    BezCtrl{ I } @ A2 I 2* 1+ CELLS+ !
  LOOP
  & BezPnt{ }free
  & BezCtrl{ }free ;

: BezierControlsOpenXY ( array1 array2 n )
  USE( }BezierControlsOpen )BezierControlsXY ;

: BezierControlsClosedXY ( array1 array2 n )
  USE( }BezierControlsClosed )BezierControlsXY ;

: BezierInterpolate ( a0 a1 a2 a3 num denom - a )
( Interpolates num/denom of the way from a0 to a3
  with a1 and a2 as Bézier control points.
  The repeated star-slashing is bound to introduce some roundoff errors,
  which the negating attempts to counter.
  Source for the formula: Programming Windows 95, page 122.
  Note: This code will return garbage if a1 or a2 makes an overflow when
  multiplied by 3. If this happens, move the 3* after the third */
  on the line. This will however reduce accuracy. )
  2DUP SWAP -
  LOCALS| mun denom num |
  num denom */ num denom */ num denom */ SWAP NEGATE
  3* num denom */ num denom */ mun denom */ 2SWAP
  3* num denom */ mun denom */ mun denom */ SWAP NEGATE
  mun denom */ mun denom */ mun denom */ - - - ;

: FBezierInterpolate ( f: a0 a1 a2 a3 t - a )
( Interpolates t of the way from a0 to a3
  with a1 and a2 as Bézier control points. )
  1E0 FOVER F-
  FRAME| a b c d e f |
  c b F* b F* b F*
  d b F* b F* a F* 3e0 F* F+
  e b F* a F* a F* 3e0 F* F+
  f a F* a F* a F* F+
  |FRAME ;
 
TEST-CODE? [IF]

23 INTEGER ARRAY SinePts{    ( 7/2 cycles )
23 FLOAT   ARRAY FSinePts{
67 INTEGER ARRAY SineCtrlPts{
67 FLOAT   ARRAY FSineCtrlPts{
12 INTEGER ARRAY RealSine{
43 INTEGER ARRAY BezSine{

DOUBLE DARRAY CardioidPts{
DOUBLE DARRAY CardioidCtrlPts{

    0 RealSine{  0 } !
  500 RealSine{  1 } !
  866 RealSine{  2 } !
 1000 RealSine{  3 } !
  866 RealSine{  4 } !
  500 RealSine{  5 } !
    0 RealSine{  6 } !
 -500 RealSine{  7 } !
 -866 RealSine{  8 } !
-1000 RealSine{  9 } !
 -866 RealSine{ 10 } !
 -500 RealSine{ 11 } !

    0 BezSine{  0 } ! \ These are the values computed by DegreeSine
  490 BezSine{  1 } ! \ in Win32Forth, as a test comparison.
  862 BezSine{  2 } ! \ If your Forth uses floored division,
  978 BezSine{  3 } ! \ you should get the same values.
  870 BezSine{  4 } !
  480 BezSine{  5 } !
   15 BezSine{  6 } !
 -503 BezSine{  7 } !
 -852 BezSine{  8 } !
 -986 BezSine{  9 } !
 -864 BezSine{ 10 } !
 -480 BezSine{ 11 } !
  -15 BezSine{ 12 } !
  511 BezSine{ 13 } !
  845 BezSine{ 14 } !
  994 BezSine{ 15 } !
  855 BezSine{ 16 } !
  487 BezSine{ 17 } !
    6 BezSine{ 18 } !
 -506 BezSine{ 19 } !
 -845 BezSine{ 20 } !
-1002 BezSine{ 21 } !
 -847 BezSine{ 22 } !
 -506 BezSine{ 23 } !
    5 BezSine{ 24 } !
  490 BezSine{ 25 } !
  855 BezSine{ 26 } !
  996 BezSine{ 27 } !
  844 BezSine{ 28 } !
  510 BezSine{ 29 } !
  -15 BezSine{ 30 } !
 -480 BezSine{ 31 } !
 -864 BezSine{ 32 } !
 -985 BezSine{ 33 } !
 -851 BezSine{ 34 } !
 -504 BezSine{ 35 } !
   14 BezSine{ 36 } !
  482 BezSine{ 37 } !
  870 BezSine{ 38 } !
  979 BezSine{ 39 } !
  862 BezSine{ 40 } !
  492 BezSine{ 41 } !
    0 BezSine{ 42 } !

: FillSinePts
  23 0 DO
    I S>F FSIN FDUP 1E3 F* F>S SinePts{ I } !
    FSinePts{ I } F!
  LOOP ;

: DegreeSine ( n - n )
  355 20340 */MOD ( fraction-of-radian radians )
  SWAP >R
  3 * SineCtrlPts{ OVER } @ SWAP
  1+  SineCtrlPts{ OVER } @ SWAP
  1+  SineCtrlPts{ OVER } @ SWAP
  1+  SineCtrlPts{ SWAP } @
  R> 20340 BezierInterpolate ;

: FDegreeSine ( f: n - n )
  FPI F* 18E1 F/ FDUP FLOOR FSWAP FOVER F- ( radians fraction-of-radian )
  FSWAP F>S
  3 * FSineCtrlPts{ OVER } F@ FSWAP
  1+  FSineCtrlPts{ OVER } F@ FSWAP
  1+  FSineCtrlPts{ OVER } F@ FSWAP
  1+  FSineCtrlPts{ SWAP } F@ FSWAP
  FBezierInterpolate ;

: SineTest
  43 0 DO
    CR
    I 30 * DUP DegreeSine 6 .R
    BezSine{ I } @ 6 .R
    S>F FDegreeSine 1E3 F* F>S 6 .R
    RealSine{ I 12 MOD } @ 6 .R
  LOOP ;

: SineSmoothTest
( Compute the second differential to estimate the inaccuracy. )
  1260 1 DO
    I DegreeSine 2* I 1- DegreeSine - I 1+ DegreeSine - .
  LOOP ;

0 VALUE #CardioidCtrlPts
VARIABLE Printing  TRUE Printing !
( Turn Printing OFF for faster display in a window. )

: Cardioid ( n )
\ Calculates control points for a cardioid with roll center at (200,200)
\ and coin diameter 96.
  1 MAX
  & CardioidPts{ OVER 1+ }malloc
  & CardioidCtrlPts{ OVER 3* 1+ }malloc
  DUP 1+ 0 ?DO
    I 2* S>F DUP S>F F/ FPI F* FDUP FSINCOS
    FROT 2E0 F* FSINCOS
    FROT 2E0 F* F+ FROT 2E0 F* FROT F+
    48E0 F* F>S 200 + 48E0 F* F>S 200 +
    CardioidPts{ I } 2!
  LOOP
  CardioidPts{ CardioidCtrlPts{ 2 PICK 1+ BezierControlsClosedXY
  3* 1+ DUP TO #CardioidCtrlPts 0 DO
    Printing @ IF
      CR CardioidCtrlPts{ I } 2@ 4 .R 4 .R
    THEN
  LOOP
  ;

: Circle ( n )
( Calculates control points for a circle. )
  1 MAX
  & CardioidPts{ OVER 1+ }malloc
  & CardioidCtrlPts{ OVER 3* 1+ }malloc
  DUP 1+ 0 ?DO
    I 2* S>F DUP S>F F/ FPI F* FSINCOS
    96E0 F* F>S 200 + 96E0 F* F>S 200 +
    CardioidPts{ I } 2!
  LOOP
  CardioidPts{ CardioidCtrlPts{ 2 PICK 1+ BezierControlsClosedXY
  3* 1+ DUP TO #CardioidCtrlPts 0 DO
    Printing @ IF
      CR CardioidCtrlPts{ I } 2@ 4 .R 4 .R
    THEN
  LOOP
  ;

( Output of FALSE SetBezMode 17 Cardioid, FALSE SetBezMode 17 Circle,
  TRUE SetBezMode 17 Cardioid, and TRUE SetBezMode 17 Circle:

 344 200   200 296   344 200   200 296
 344 222   212 296   344 227   214 296
 337 248   224 294   339 245   222 295
 325 267   235 290   325 267   235 290
 313 286   246 286   311 289   248 285
 293 302   257 279   297 301   255 280
 275 312   265 271   275 312   265 271
 257 322   273 263   253 323   275 262
 233 325   281 253   237 326   280 255
 214 324   286 243   214 324   286 243
 195 323   291 233   191 322   292 231
 176 314   295 221   178 315   295 223
 162 304   296 209   162 304   296 209
 148 294   297 197   146 293   297 195
 139 279   295 185   140 282   296 187
 133 267   292 174   133 267   292 174
 127 255   289 163   126 252   288 161
 128 240   284 151   128 242   285 153
 129 230   277 142   129 230   277 142
 130 220   270 133   130 218   269 131
 136 213   261 124   136 214   263 125
 140 208   251 118   140 208   251 118
 144 203   241 112   144 202   239 111
 148 201   230 108   148 202   232 108
 150 200   218 106   150 200   218 106
 152 199   206 104   152 198   204 104
 152 201   194 104   152 202   196 104
 150 200   182 106   150 200   182 106
 148 199   170 108   148 198   168 108
 144 197   159 112   144 198   161 111
 140 192   149 118   140 192   149 118
 136 187   139 124   136 186   137 125
 130 180   130 133   130 182   131 131
 129 170   123 142   129 170   123 142
 128 160   116 151   128 158   115 153
 127 145   111 163   126 148   112 161
 133 133   108 174   133 133   108 174
 139 121   105 185   140 118   104 187
 148 106   103 197   146 107   103 195
 162  96   104 209   162  96   104 209
 176  86   105 221   178  85   105 223
 195  77   109 233   191  78   108 231
 214  76   114 243   214  76   114 243
 233  75   119 253   237  74   120 255
 257  78   127 263   253  77   125 262
 275  88   135 271   275  88   135 271
 293  98   143 279   297  99   145 280
 313 114   154 286   311 111   152 285
 325 133   165 290   325 133   165 290
 337 152   176 294   339 155   178 295
 344 178   188 296   344 173   186 296
 344 200   200 296   344 200   200 296   )

C" WM_WIN32FORTH" FIND NIP [IF]
( This code is specific to Win32Forth and presents the same
  cardioid test graphically. )

:Object CardioidWindow <Super Window
int Curve/Poly

: ShowPoly
  1 TO Curve/Poly
  Paint: self ;

: ShowCurve
  0 TO Curve/Poly
  Paint: self ;

: ShowControl
  2 TO Curve/Poly
  Paint: self ;

:m On_Init:
  On_Init: super
  ['] ShowPoly SetClickFunc: self
  ['] ShowCurve SetUnclickFunc: self
  ['] ShowControl SetDblClickFunc: self ;m

:m StartSize:
  400 400 ;m

\ Note: DC.F contains a bug. The word swap was inserted erroneously
\ in PolyBezier: and PolyBezierTo: .
\
\ :M PolyBezier:  ( ptr cnt -- )          \ rls - new *** Note: NOT in Win32S!
\                 swap rel>abs ( swap ) hDC Call PolyBezier   ?win-error ;M
\
\ I have also added the following method.
\
\ :m Polygon: ( ptr cnt - )
\   swap rel>abs hDC Call Polygon ?win-error ;m

:m On_Paint:
  #CardioidCtrlPts IF
    BLUE PenColor: dc
    Curve/Poly CASE ( Draw curve or control points depending on mouse clicks )
      0 OF CardioidCtrlPts{ #CardioidCtrlPts PolyBezier: dc ENDOF
      1 OF CardioidPts{ #CardioidCtrlPts 3/ 1+ Polygon: dc ENDOF
      2 OF CardioidCtrlPts{ #CardioidCtrlPts Polygon: dc ENDOF
    ENDCASE
  THEN
  ;m

;Object

: Cardioid ( n )
  Cardioid
  Start: CardioidWindow
  Paint: CardioidWindow
  S" Cardioid" SetTitle: CardioidWindow
  WinPause ;

: Circle ( n )
  Circle
  Start: CardioidWindow
  Paint: CardioidWindow
  S" Circle" SetTitle: CardioidWindow
  WinPause ;

: Cardioids ( n )
  0 ?DO
    I 1+ Cardioid
    100 MS
  LOOP ;

: Circles ( n )
  0 ?DO
    I 1+ Circle
    100 MS
  LOOP ;

[THEN] ( if Win32Forth )

FillSinePts
SinePts{ SineCtrlPts{ 23 }BezierControlsOpen
FSinePts{ FSineCtrlPts{ 23 }FBezierControlsOpen
CR 23 SinePts{ }iprint
CR 23 FSinePts{ }fprint
CR 67 SineCtrlPts{ }iprint
CR 67 FSineCtrlPts{ }fprint

( Output of preceding lines:
0 841 909 141 -757 -959
-279 657 989 412 -544 -1000
-537 420 991 650 -288 -961
-751 150 913 837 -9
.000000 .841471 .909297 .141120 -.756802 -.958924
-.279415 .656987 .989358 .412118 -.544021 -.999990
-.536573 .420167 .990607 .650288 -.287903 -.961397
-.750987 .149877 .912945 .836656 -.008851
0 280 689 841 993 1026
909 792 419 141 -137 -574
-757 -940 -1039 -959 -879 -548
-279 -10 446 657 868 1030
989 948 668 412 156 -309
-544 -779 -1001 -1000 -999 -774
-537 -300 165 420 675 953
991 1029 863 650 437 -20
-288 -556 -884 -961 -1038 -936
-751 -566 -127 150 427 799
913 1027 991 837 683 273
-9
.000000 .280490 .689921 .841471 .993021 1.02602
.909297 .792572 .418803 .141120 -.136563 -.573462
-.756802 -.940143 -1.03849 -.958924 -.879360 -.548734
-.279415 -.010097 .445524 .656987 .868449 1.03017
.989358 .948547 .667682 .412118 .156555 -.308670
-.544021 -.779373 -1.00123 -.999990 -.998749 -.773266
-.536573 -.299880 .165637 .420167 .674697 .952254
.990607 1.02896 .863373 .650288 .437203 -.019289
-.287903 -.556518 -.884217 -.961397 -1.03858 -.936200
-.750987 -.565775 -.127445 .149877 .427199 .798482
.912945 1.02741 .990288 .836656 .683023 .275935
-.008851 )

[THEN] ( if test code )

