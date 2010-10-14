! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server.socket Battleship.server.types
accessors arrays assocs calendar colors.constants
concurrency.messaging io kernel locals math math.rectangles
math.vectors models namespaces opengl prettyprint sequences
sets threads ui.gadgets ui.gadgets.tracks ui.render ;
FROM: namespaces => set ;
IN: Battleship.server

: hit? ( part -- ? ) hit?>> value>> ;
: (find-ship-part) ( pos ship -- ship-part/f )
    parts>> [ [ position>> = ] [ hit? not ] bi and ] with find nip ;
! This feels like a hack. Should use something else than find ?
: find-ship-part ( pos ships -- ship/f ship-part/f )
    [ f ] 2dip [ (find-ship-part) nip dup ] with find nip swap ;
: hit ( ship ship-part -- str )
    hit?>> t swap set-model
    parts>> [ hit? not ] filter length zero?
    "TOUCHE-COULE" "TOUCHE" ? ;
: plouf ( pos player -- )
    missed>> [ value>> adjoin ] [ notify-connections ] bi ;
: fire ( pos player -- str )
    2dup ships>> find-ship-part [ hit 2nip ] [ drop plouf "RATE" ] if* ;
: ship-dead? ( ship -- ? ) parts>> [ hit? ] all? ;
: player-dead? ( player -- ? ) ships>> [ ship-dead? ] all? ;

: player-playing? ( player game -- ? )
    [ player1>> ] [ player2>> ] bi
    [ name>> = ] bi-curry@ bi or ;
: <battleship-game> ( players -- game )
    first2 [ <player> ] bi@
    battleship-game new
    swap >>player1 swap >>player2
    dup player1>> >>current-player
    ;

QUALIFIED: xbee.dispatcher
: (dispatch) ( data dst -- )
    dup length 2 = [ xbee.dispatcher:dispatch ] [ dup . eth-clients get-global at [ send ] [
    drop ] if* ] if ;
: dispatch ( data dst -- ) 
    [ swap ":" glue print ]
    [ (dispatch) ] 2bi ;

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
