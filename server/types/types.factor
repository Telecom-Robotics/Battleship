! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences ui.gadgets models ;
IN: Battleship.server.types

CONSTANT: BOARD-SIZE { 10 10 }

TUPLE: ship-part position hit? ;
TUPLE: ship parts ;
TUPLE: player name ships missed ;
TUPLE: battleship-game player1 player2 arbiter current-player ;
TUPLE: battleship-board < gadget player ;

TUPLE: dummy-message data source ;
SINGLETON: forfeit

: <ship-part> ( pos -- ship-part )
    f <model> ship-part boa ;
: <ship> ( ship-parts -- ship )
    ship boa ;
: <test-ships> ( -- ships )
    { 1 1 } t <model> ship-part boa
    { 1 2 } f <model> ship-part boa
    { 1 3 } t <model> ship-part boa 3array ship boa 1array ;
: register-ships ( board -- )
    dup player>> ships>> [ parts>> [ hit?>> add-connection ] with each ] with each ; 
: register-ploufs ( board -- )
    dup player>> missed>> add-connection ;
: register-elements ( board -- ) [ register-ships ] [ register-ploufs ] bi ;
: <battleship-board> ( player -- board ) battleship-board new
    swap >>player dup register-elements ;
: <test-player> ( -- player )
    player new
    "Player-name" >>name
    <test-ships> >>ships ;

: players-list ( game -- list )
    [ player1>> ] [ player2>> ] bi [ name>> ] bi@ "," glue ;

: <test-game> ( -- game )
    battleship-game new
    <test-player> >>player1 <test-player> >>player2 ;
: <player> ( name -- player )
    player new swap >>name V{ } clone <model> >>missed ;

CONSTANT: ship-config { 5 4 3 3 2 }
CONSTANT: protocol-new-game "NEWGAME"
CONSTANT: protocol-fire "FIRE"
CONSTANT: protocol-win "YOU WIN"
CONSTANT: protocol-lose "YOU LOSE"
CONSTANT: protocol-ship "SHIP"
CONSTANT: protocol-horizontal "H"
CONSTANT: protocol-separator ";"

SYMBOL: log-stream
: init-log ( -- )
    output-stream get log-stream set ;
: log ( msg -- )
    log-stream get [ print ] with-output-stream* ;
: plog ( obj -- )
    log-stream get [ . ] with-output-stream* ;
: log-dummy-msg ( msg -- )
    [ source>> ] [ data>> ] bi "==>" glue log ;


