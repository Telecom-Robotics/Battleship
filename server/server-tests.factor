! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: Battleship.client.factor
Battleship.client.factor.strategies
Battleship.client.factor.strategies.all
Battleship.client.factor.strategies.attack.tomo
Battleship.client.factor.strategies.placement.tomo
Battleship.server Battleship.server.lobby
Battleship.server.socket Battleship.server.types accessors
calendar concurrency.messaging io.servers kernel math memoize
namespaces threads tools.test ;
IN: Battleship.server.tests

CONSTANT: test-port 24847
CONSTANT: number-of-players 10
MEMO: test-player ( -- test-player ) <test-player> ;
: start-test-server ( -- server )
    [ start-lobby test-port start-eth-listen ] with-scope ;
: notify ( thread-id -- )
    f swap send ;
: wait-for-notifications ( -- )
    number-of-players [ 10 seconds receive-timeout drop ] times ;
: start-test-player ( -- )
    [ "localhost" test-port [ tomo-attack [ tomo-placement [ play-battleship ] with-placement-strategy ] with-attack-strategy ] with-ascii-client ]
    self [ notify ] curry compose
    "Battleship Player" spawn drop ;

[ t ] [ { 1 2 } test-player ships>> find-ship-part drop >boolean ] unit-test
[ f ] [ { 1 1 } test-player ships>> find-ship-part drop >boolean ] unit-test
[ f ] [ { 1 1 } test-player ships>> find-ship-part drop >boolean ] unit-test

[ t ] [ start-test-server 
        [ number-of-players [ start-test-player ] times
        wait-for-notifications t ]
        [ drop f ] recover swap stop-server ] unit-test
