! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators io io.encodings.ascii
io.sockets kernel literals math math.parser memoize
namespaces random sequences sequences.product sets splitting assocs
Battleship.client.factor.protocol Battleship.client.factor.strategies
Battleship.client.factor.strategies.all ;
FROM: namespaces => set ;
IN: Battleship.client.factor


<PRIVATE

SYMBOL: my-ships
SYMBOL: shots

: send ( str -- ) print flush ;
: receive ( -- str ) readln ;

: ship>string ( ship -- str )
    [ drop protocol-ship ] [ [ x>> ] [ y>> ] bi [ number>string ] bi@ ] [ orientation>> ] tri 4array ";" join ;
: ship-error ( ship -- ) throw ;
: handle-ship-ack ( obj -- )
    receive
    protocol-OK = [ my-ships get adjoin ] [ ship-error ] if ;
: synchronous-place-ship ( new-ship-size -- )
    [ my-ships get ] dip place-ship
    [ ship>string send ] [ handle-ship-ack ] bi ;



: remember-shot ( shot -- )
    [ answer>> ] [ {x,y}>> ] bi shots get set-at ;
: fire>string ( {x,y} -- str )
    [ number>string ] map protocol-fire prefix protocol-separator join ;
: store-fire-answer ( {x,y} -- fire )
    shot new swap >>{x,y} receive >>answer ;
: shot-error ( shot -- ) throw ;
: handle-fire-ack ( obj -- )
    receive
    protocol-OK = [ store-fire-answer remember-shot ] [ shot-error ] if ;
: synchronous-fire ( -- )
    shots get fire [ fire>string send ] [ handle-fire-ack ] bi ;

: win ( -- ) ;
: lose ( -- ) ;

DEFER: handle-next-line
: handle ( opts str -- )
    {
        { $ protocol-fire [ drop synchronous-fire handle-next-line ] }
        { $ protocol-ship [ string>number synchronous-place-ship handle-next-line ] }
        { $ protocol-win [ drop win ] }
        { $ protocol-lose [ drop lose ] }
        [ 2drop ]
    } case ;
: handle-next-line ( -- )
    receive protocol-separator split1 swap handle ;

: init-variables ( -- )
    { { V{ } my-ships }
      { H{ } shots } }
    [ first2 [ clone ] [ set ] bi* ] each ;
: start-game ( -- ) protocol-start send ;

PRIVATE>
: play-battleship ( -- )
    [ init-variables start-game handle-next-line ] with-scope ;
: with-ascii-client ( host port quot -- )
    [ <inet> ascii ] dip with-client ; inline
