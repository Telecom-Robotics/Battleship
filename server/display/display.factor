! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server Battleship.server.types accessors
arrays colors.constants kernel locals math math.rectangles
math.vectors models opengl sequences ui.gadgets
ui.gadgets.labels ui.gadgets.tracks ui.render ;
IN: Battleship.server.display

: line ( n len -- {p1,p2} )
    0 swap [ 2array ] bi-curry@ bi 2array ;
:: (calc-lines) ( dim n -- lines )
    dim second :> len
    n 1 + iota dim first n / [ * len line ] curry map ;
: rotate ( lines -- lines' )
    [ [ reverse ] map ] map ;
: calc-lines ( dim size -- lines )
    [ dup reverse 2array ] dip
    [ (calc-lines) ] 2map
    [ [ 1 ] dip [ rotate ] change-nth ] keep concat ;

: draw-line ( {p1,p2} -- )
    COLOR: black gl-color
    first2 gl-line ;
: draw-grid ( gadget -- )
    rect-bounds nip BOARD-SIZE calc-lines [ draw-line ] each ;

: width/height ( gadget -- {width,height} )
    rect-bounds nip BOARD-SIZE v/ ;
: ship-color ( ship-part -- )
    hit? COLOR: red COLOR: blue ? gl-color ;
: draw-position ( gadget pos -- )
    swap width/height
    [ v* ] [ nip ] 2bi gl-fill-rect ;
: draw-ship ( gadget ship -- )
    parts>> [ [ ship-color ] [ position>> draw-position ] bi ] with each ;
: draw-ships ( game -- )
    dup player>> ships>> [ draw-ship ] with each ;
: draw-missed ( gadget -- )
    dup player>> missed>> value>> [ [ COLOR: green gl-color draw-position ] with each
    ] [ drop ] if* ;

M: battleship-board pref-dim* drop { 640 480 } ;
M: battleship-board draw-gadget*
    [ draw-grid ] [ draw-missed ] [ draw-ships ] tri ;
M: battleship-board model-changed nip relayout-1 ;

: <upper-track> ( player1 player2 -- track )
    [ name>> <label> ] bi@ horizontal <track>
    swap 0.5 track-add swap 0.5 track-add ;
: <lower-track> ( player1 player2 -- track )
    [ <battleship-board> ] bi@
    horizontal <track>
    swap 0.5 track-add swap 0.5 track-add
    { 10 10 } >>gap ;
: <battleship-gadget> ( game -- gadget )
    [ player1>> ] [ player2>> ] bi [ <lower-track> ] [ <upper-track> ] 2bi
    vertical <track> swap 0.1 track-add swap 0.9 track-add ;

