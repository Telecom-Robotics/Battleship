! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays Battleship.server
Battleship.server.types Battleship.server.arbiter concurrency.messaging io
kernel namespaces sequences strings threads vectors prettyprint ;
IN: Battleship.server.lobby

CONSTANT: protocol-new-game "NEWGAME"
CONSTANT: players-per-game 2
SYMBOL: waiting-list
SYMBOL: games

: init-waitlist ( -- )
    players-per-game <vector> waiting-list set ;
: init-games ( -- )
    10 <vector> games set ;

: unregister-game ( game -- ) games get remove! drop ;
: register-game ( game -- ) games get push ;
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
    games get [ player-playing? ] with find nip ;
: handle ( request -- )
    dup source>> >string playing? [ handle-existing-player ] [ handle-new-player ] if* ;
SYMBOL: log-stream
: init-log ( -- )
    output-stream get log-stream set ;
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
