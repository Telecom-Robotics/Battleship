! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences ui.gadgets ;
IN: battleship.types

TUPLE: ship-part position hit? ;
TUPLE: ship parts ;
TUPLE: player name ships ;
TUPLE: battleship-game player1 player2 arbiter current-player ;
TUPLE: battleship-board < gadget ships ;

: <test-ships> ( -- ships )
    { 1 1 } t ship-part boa
    { 1 2 } f ship-part boa
    { 1 3 } t ship-part boa 3array ship boa 1array ;
: <test-board> ( -- board )
    battleship-board new <test-ships> >>ships ;
: <battleship-board> ( ships -- board ) battleship-board new swap >>ships ;
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
    player new swap >>name ;

