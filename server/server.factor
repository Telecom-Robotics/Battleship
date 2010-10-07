! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors.constants kernel locals math
math.rectangles math.vectors opengl sequences ui.gadgets
ui.gadgets.labels ui.gadgets.tracks ui.render
Battleship.server.types sets ;
IN: Battleship.server
FROM: namespaces => set ;


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
    "TOUCHE-COULE" "TOUCHE" ? ;
: plouf ( pos player -- )
    missed>> adjoin ;
: fire ( pos player -- str )
    2dup ships>> find-ship-part [ hit 2nip ] [ drop plouf "RATE" ] if* ;

: ship-dead? ( ship -- ? ) parts>> [ hit?>> ] all? ;
: player-dead? ( player -- ? ) ships>> [ ship-dead? ] all? ;

: width/height ( gadget -- {width,height} )
    rect-bounds nip BOARD-SIZE v/ ;
: ship-color ( ship-part -- )
    hit?>> COLOR: red COLOR: blue ? gl-color ;
: draw-position ( gadget pos -- )
    swap width/height
    [ v* ] [ nip ] 2bi gl-fill-rect ;
: draw-ship ( gadget ship -- )
    parts>> [ [ ship-color ] [ position>> draw-position ] bi ] with each ;
: draw-ships ( game -- )
    dup player>> ships>> [ draw-ship ] with each ;
: draw-missed ( gadget -- )
    dup player>> missed>> [ [ COLOR: green gl-color draw-position ] with each
    ] [ drop ] if* ;

M: battleship-board pref-dim* drop { 640 480 } ;
M: battleship-board draw-gadget*
    [ draw-grid ] [ draw-missed ] [ draw-ships ] tri ;
: player-playing? ( player game -- ? )
    [ player1>> ] [ player2>> ] bi
    [ name>> = ] bi-curry@ bi or ;
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
: <battleship-game> ( players -- game )
    first2 [ <player> ] bi@
    battleship-game new
    swap >>player1 swap >>player2
    dup player1>> >>current-player
    ;

! TODO: move this to another file
USING: accessors io io.encodings.ascii concurrency.messaging namespaces
prettyprint io.streams.string assocs
io.servers kernel threads fry calendar calendar.format system
math.parser ;
FROM: io.sockets => remote-address local-address ;

SYMBOL: eth-clients
: setup-client ( source -- )
    self swap eth-clients get-global set-at ;
: unregister-client ( source -- ) drop ;
:: handle ( source lobby-thread -- ? )
    readln dup empty? [ drop f ]
    [ [ "\n\r" member? not ] filter source dummy-message
    boa lobby-thread send t ] if ;
: client-id ( -- id )
    remote-address get host>> 
    local-address get port>> number>string
    "|" glue nano-count number>string 
    ";" glue ;
: spawn-listen-thread ( lobby-thread client-id -- )
    [ swap [ handle ] 2curry ] [ ] bi spawn-server drop ;
: spawn-send-thread ( client-id -- )
    [ setup-client [ receive print flush t ] loop ] curry
    "Sending thread toto" spawn drop ;
: handle-battleship-client ( lobby-thread -- )
    client-id
    [ spawn-listen-thread ] [ spawn-send-thread ] 
    [ receive drop unregister-client ] tri ;
    

: <Battleship-server> ( lobby-thread port -- threaded-server )
    ascii <threaded-server>
        "Battleship-server" >>name
        swap >>insecure
        f >>timeout
        swap [ handle-battleship-client ] curry >>handler ;

: start-eth-listen ( lobby-thread port -- eth-server )
    H{ } clone eth-clients set-global
    <Battleship-server> start-server ;
QUALIFIED: xbee.dispatcher
: (dispatch) ( data dst -- )
    dup length 2 = [ xbee.dispatcher:dispatch ] [ dup . eth-clients get-global at [ send ] [
    drop ] if* ] if ;
: dispatch ( data dst -- ) 
    [ swap ":" glue print ]
    [ (dispatch) ] 2bi 
    10 milliseconds sleep ;

: register-xbee-client ( lobby-thread recipient -- )
   xbee.dispatcher:register-recipient ;

! Command to launch on the XBee host:
!  socat TCP-LISTEN:4161,forever,fork,reuseaddr
!  /dev/ttyUSB0,raw,b57600
! Then, supposedly, "JH" register-xbee-client 
USING: xbee xbee.api xbee.api.simple ;
: start-xbee ( -- )
    "jonction.enst.fr" 4161 <remote-xbee> xbee set
    enter-api-mode
    ! "CC" set-my
    6 set-retries
    xbee.dispatcher:start-dispatcher ;
