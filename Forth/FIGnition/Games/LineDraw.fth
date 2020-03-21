: linePlot
  0 do 2dup >r >r
    rot  + >r + r>
    2dup 8 >> swap 8 >>
    swap plot r> r>
  loop
  drop drop drop drop ;

: >xp8 8 << ;
: xp8> 256 m* swap drop
 ;
: linePrep
  2dup abs swap abs max
  >r >xp8 r / swap >xp8
  r / swap >r >r >xp8
  128 + swap >xp8 128 +
  swap r> r> r> ;

: line ( x y dx dy )
  linePrep linePlot ;