! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays Battleship.server
Battleship.server.types Battleship.server.arbiter concurrency.messaging io
kernel namespaces sequences strings threads vectors assocs prettyprint ;
IN: Battleship.server.lobby

CONSTANT: players-per-game 2
SYMBOL: waiting-list
SYMBOL: games

: init-waitlist ( -- )
    players-per-game <vector> waiting-list set ;
: init-games ( -- )
    H{ } games set ;
: players-names ( game -- p1 p2 )
    [ player1>> ] [ player2>> ] bi [ name>> ] bi@ ;
: unregister-player ( player -- ) games get delete-at ;
: unregister-game ( game -- )
    players-names [ unregister-player ] bi@ ;
: register-player ( game player -- ) games get set-at ;
: register-game ( game -- )
    dup players-names
    [ register-player ] bi-curry@ bi ;
: start-game ( players -- )
    <battleship-game> [ register-game ] [ [ [ unregister-game ] curry ] keep launch-arbiter ] bi
    init-waitlist ;
: ?start-game ( waiting-list -- )
    dup length players-per-game = [ start-game ] [ drop ] if ;
: put-in-waitlist ( id -- )
    waiting-list get [ push ] [ ?start-game ] bi ;
: ?put-in-waitlist ( rqst -- )
    dup data>> protocol-new-game = [ source>> put-in-waitlist ] [ drop ] if ;
: already-waiting ( rqst -- ) drop ;
: waiting? ( id -- ? ) waiting-list get member? ;
: handle-existing-player ( rqst game -- ) arbiter>> send ;
: handle-new-player ( rqst -- )
    dup source>> waiting? [ already-waiting ] [ ?put-in-waitlist ] if ;
: playing? ( id -- game/f )
    games get at ;
: handle ( request -- )
    dup source>> >string playing? [ handle-existing-player ] [ handle-new-player ] if* ;
: init-lobby ( -- )
    init-log
    init-waitlist
    init-games ;

: log ( msg -- )
    log-stream get [ print ] with-output-stream* ;
: log-dummy-msg ( msg -- )
    [ source>> ] [ data>> ] bi "==>" glue log ;

: lobby ( -- t )
    receive "Got message" print dup .
    [ log-dummy-msg ] [ handle ] bi t ;
: start-lobby ( -- lobby-thread )
    init-lobby [ lobby ] "BattleShip Lobby" spawn-server ;
