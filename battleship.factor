! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors.constants kernel locals math
math.rectangles math.vectors opengl sequences ui.gadgets
ui.gadgets.labels ui.gadgets.tracks ui.render battleship.arbiter battleship.types ;
IN: battleship


CONSTANT: BOARD-SIZE { 10 10 }
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

: (find-ship-part) ( pos ship -- ship-part/f )
    parts>> [ [ position>> = ] [ hit?>> not ] bi and ] with find nip ;
! This feels like a hack. Should use something else than find ?
: find-ship-part ( pos ships -- ship/f ship-part/f )
    [ f ] 2dip [ (find-ship-part) nip dup ] with find nip swap ;
: hit ( ship ship-part -- str )
    t >>hit? drop
    parts>> [ hit?>> not ] filter length zero?
    "TOUCHÉ-COULÉ!!!" "TOUCHÉ!" ? ;
: fire ( pos ships -- str )
    find-ship-part [ hit ] [ drop "RATÉ" ] if* ;

: ship-dead? ( ship -- ? ) parts>> [ hit?>> ] all? ;
: player-dead? ( player -- ? ) ships>> [ ship-dead? ] all? ;

: width/height ( gadget -- {width,height} )
    rect-bounds nip BOARD-SIZE v/ ;
: ship-color ( ship-part -- )
    hit?>> COLOR: red COLOR: blue ? gl-color ;
: draw-position ( gadget ship-part -- )
    position>> swap width/height
    [ v* ] [ nip ] 2bi gl-fill-rect ;
: draw-ship ( gadget ship -- )
    parts>> [ [ ship-color ] [ draw-position ] bi ] with each ;
: draw-ships ( game -- )
    dup ships>> [ draw-ship ] with each ;

M: battleship-board pref-dim* drop { 640 480 } ;
M: battleship-board draw-gadget*
    [ draw-grid ] [ draw-ships ] bi ;
: player-playing? ( player game -- ? )
    [ player1>> ] [ player2>> ] bi
    [ name>> = ] bi-curry@ bi or ;
: <upper-track> ( player1 player2 -- track )
    [ name>> <label> ] bi@ horizontal <track>
    swap 0.5 track-add swap 0.5 track-add ;
: <lower-track> ( player1 player2 -- track )
    [ ships>> <battleship-board> ] bi@
    horizontal <track>
    swap 0.5 track-add swap 0.5 track-add
    { 10 10 } >>gap ;
: <battleship-gadget> ( game -- gadget )
    [ player1>> ] [ player2>> ] bi [ <lower-track> ] [ <upper-track> ] 2bi
    vertical <track> swap 0.1 track-add swap 0.9 track-add ;
: launch-arbiter ( end-quot game -- )
    [ <arbiter> ] keep arbiter<< ;
: <battleship-game> ( players -- game )
    first2 [ <player> ] bi@
    battleship-game new
    swap >>player1 swap >>player2
    dup player1>> >>current-player
    ;
