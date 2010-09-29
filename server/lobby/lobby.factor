! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays battleship concurrency.messaging io
kernel namespaces sequences strings threads vectors ;
IN: battleship.server

CONSTANT: protocol-new-game "NEWGAME"
CONSTANT: players-per-game 2
SYMBOL: waiting-list
SYMBOL: games

TUPLE: dummy-message data source ;

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
: init-lobby ( -- )
    init-waitlist
    init-games ;
: lobby ( -- t )
    receive handle t ;
: start-lobby ( -- lobby-thread )
    init-lobby [ lobby ] "BattleShip Lobby" spawn-server ;
