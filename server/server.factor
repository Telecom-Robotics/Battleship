! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.server.socket Battleship.server.types
accessors arrays assocs calendar colors.constants
concurrency.messaging io kernel locals math math.rectangles
math.vectors namespaces opengl prettyprint sequences sets
threads ui.gadgets ui.gadgets.tracks ui.render ;
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
    missed>> adjoin ;
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

: dispatch ( data dst -- ) 
    [ swap ":" glue print ]
    [ dup . eth-clients get-global at [ send ] [ drop ] if* ] 2bi ;
