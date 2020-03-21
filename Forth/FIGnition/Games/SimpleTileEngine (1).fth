( overhead: 1200b data)
25 const scr.w
24 const scr.h

0 var scr.x
0 var scr.pos
0 var scr.upPos
: cdata <builds does> ;
0 var backTiles scr.w
  scr.h * allot
0 var foreTiles scr.w
  scr.h * allot

: onscr ( -- f )
  >r dup 0< over
  [ scr.w 1- ] literal
  > or r> dup 0< over
  [ scr.w scr.h * 1- ]
  literal > or rot or ;

: tile ( t -- )
  scr.x @ scr.pos @ 2dup
  onscr if
    + backTiles  + c!
    1 scr.x +! ;s
  then
  drop drop drop ;

: >xy ( x y -- )
  scr.w * scr.pos !
  scr.x ! ;

: xy@
  scr.x @ scr.pos @ 2dup
  onscr if
    + vram + ic@ ;s
  then
  drop drop ;


: fTile ( t -- )
  scr.x @ scr.pos @ 2dup
  onscr if
    + foreTiles + c!
    1 scr.x +! ;s
  then
  drop drop drop ;

: fore ( s^ dx dy -- )
  >r swap r>
  0 do
    scr.x @ >r ( save x)
    dup 0 do
      dup i + c@ fTile
    loop
    >r scr.x ! ( restore)
    scr.w scr.pos +!
    over +
  loop ;

: clg
  backTiles
  [ scr.w scr.h * ]
  literal 32 fill ;

: backTiles>
  backTiles foreTiles
  [ scr.w scr.h * ]
  literal cmove ;

: foreTiles>
  foreTiles vram
  [ scr.w scr.h * ]
  literal cmove ;

: tilesUp ( tileMap )
  dup dup scr.w + swap
  [ scr.w scr.h 1- * ]
  literal dup >r cmove
  r> + scr.w 32 fill ;
: tilesDown
  backTiles>
  foreTiles dup >r 
  scr.w + backTiles
  [ scr.w scr.h * 1- ]
  literal cmove
  r> scr.w 32 fill ;

: vfill ( dst -- )
  scr.w swap
  scr.h 0 do
    32 over c!
    over +
  loop drop ;






: tilesLeft ( tileMap )
  dup dup 1+
  [ scr.w scr.h * 1- ]
  literal cmove
  [ scr.w 1- ] literal +
  vfill ;

: tilesRight ( tileMap )
  dup dup 1+ swap
  [ scr.w scr.h * 1- ]
  literal cmove
  vfill ;
