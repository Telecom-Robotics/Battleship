! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors.constants kernel locals math
math.rectangles math.vectors opengl sequences ui.gadgets
ui.gadgets.labels ui.gadgets.tracks ui.render
Battleship.server.types ;
IN: Battleship.server


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
    "TOUCHÉ-COULÉ!!!" "TOUCHÉ" ? ;
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
: <battleship-game> ( players -- game )
    first2 [ <player> ] bi@
    battleship-game new
    swap >>player1 swap >>player2
    dup player1>> >>current-player
    ;

! TODO: move this to another file
USING: accessors io io.encodings.ascii concurrency.messaging namespaces
prettyprint io.streams.string assocs
io.servers kernel threads fry ;
FROM: io.sockets => remote-address ;

SYMBOL: eth-clients

: setup-client ( source -- )
    self swap eth-clients get-global set-at ;
: handle-quot ( source lobby-thread -- quot )
    '[ readln _ dummy-message boa _ send t ] ; inline
: handle-battleship-client ( lobby-thread -- a )
    remote-address get host>> dup setup-client
    [ swap handle-quot ] [ ] bi
    spawn-server [ receive print flush t ] loop ;

: <Battleship-server> ( lobby-thread -- threaded-server )
    ascii <threaded-server>
        "Battleship-server" >>name
        12345 >>insecure
        swap [ handle-battleship-client ] curry >>handler ;

: start-eth-listen ( lobby-thread -- eth-server )
    H{ } clone eth-clients set-global
    <Battleship-server> start-server ;

: dispatch ( data dst -- ) 
    [ swap ":" glue print ]
    [ dup . eth-clients get-global at [ send ] [ drop ] if* ] 2bi ;

    


