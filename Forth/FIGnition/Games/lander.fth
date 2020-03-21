( Block 0)

1000 var fuel
10 var x
5 var y
0 var ox
0 var oy
1 var vel
0 var gameover
17 var platform
32 const thrust
8 const left
9 const right
65 128 + const ship






( Block 1)
5 var seed
: rnd ( range -- random )
  seed @ 1+ 75 * dup seed
  ! u* swap drop
;














( Block 2)
: peak
  3 rnd dup 0= if
    drop 47 emit  1 -
  else
    1 = if 95 emit
    else  1+ over over
      at 92 emit
    then
  then
  swap drop 1
;

: doplat
  ." ****"
  4
;



( Block 3)
: landscape
   23 4 rnd - ( scr bot)
   25 0 do
      i over at
      i platform @ = if
        doplat
      else  i swap
         peak
      then
   +loop
;

: status
  0 0 at ." Fuel "
  fuel @ .  4 spaces
;



( Block 4)
: init
   500 500 rnd + fuel !
   ( rand fuel 500-999 )
   25 rnd x ! 5 y !
   20 rnd platform !
   0 gameover !
   0 vel !
;

: mvship
   x @ y @ at ship emit
   x @ ox @ = y @ oy @ =
   and 0= if
     ox @ oy @ at space
   then
   x @ ox !
   y @ oy !
;

( Block 5)
: decFuel
  vel @ 3 - vel !
  fuel @ 1 - fuel !
  fuel @ 0< if
    1 gameover !
  then
  x @ y @ 1+ at 118 emit
;

: wrapx ( x -- wrapped x)
  dup 0< if
      drop 25
  else
      dup 25 > if
          drop 0
      then
  then
  x !
;
( Block 6)
: nothrust
  x @ y @ 1+ at 32 emit
;

: doKey
   inkey dup thrust
   =  if
        decFuel
   else nothrust
   then
   dup left = if
       x @ 1 - wrapx
   then
   right = if
        x @ 1+ wrapx
   then
;


( Block 7)
: landing
  y @ 25 * x @ + vram +
  ( current vram loc )
  ic@ dup 47 = over 95 =
  or over 92 = or if
    drop 1 gameover !
  else
    42 = if
      2 gameover ! ( win)
    then
  then
;







( Block 8)
: doVel
   vel @ y @ + y !
   vel @ 1+ vel !
   y @ 22 > if
     1 gameover !
     else
       y @ 0< if
         1 gameover !
       else
         landing
       then
   then
;

: frame
  doKey doVel mvship
  status
;

( Block 9)
: timeout
   clock i@ + ( 10 fps)
   begin
      dup clock i@ - 0<
   until  drop
;

: lander
  init landscape mvship
  begin
    frame
    12 timeout
  gameover @ until
  gameover @ 2 = if
    10 0 at
    ." WELL DONE!"
  then
;
